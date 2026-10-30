import 'dart:async';
import 'dart:convert';
import 'package:archive_shared/archive_schema.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../auth/archive_credentials.dart';
import '../archive/archive_record_writer.dart';
import '../generated/protocol.dart';
import 'archive_events.dart';
import '../updates/windows_client_policy.dart';

Duration get archiveSessionLifetime =>
    AuthServices.getTokenManager<JwtTokenManager>()
        .jwt
        .config
        .refreshTokenLifetime;

/// Counts live connections per user, including connections sharing one token.
/// Saved sign-ins without a live presence lease do not count.
Future<Map<String, Map<String, dynamic>>> archiveSessionStatus(
  Session session,
) async {
  final now = DateTime.now().toUtc();
  final rows = await session.db.unsafeQuery(
    'SELECT p."userId", COUNT(*) '
    'FROM archive_presence p '
    'JOIN serverpod_auth_core_jwt_refresh_token t '
    'ON p."authId" = t.id::text AND p."userId" = t."authUserId"::text '
    'WHERE p."expiresAt" > @now AND t."lastUpdatedAt" > @cutoff '
    'GROUP BY p."userId"',
    parameters: QueryParameters.named({
      'now': now,
      'cutoff': now.subtract(archiveSessionLifetime),
    }),
  );
  return {
    for (final row in rows)
      row[0] as String: {
        'activeSessions': row[1] as int,
        'online': (row[1] as int) > 0,
      },
  };
}

Future<ArchiveMember> _streamMember(Session session) async {
  final member = await authenticatedArchiveMember(session);
  if (member.role == 'deleted') {
    throw ArchiveAuthException(message: 'Обліковий запис видалено.');
  }
  return member;
}

Future<void> _validateStreamToken(Session session, ArchiveMember member) async {
  final valid = await session.db.unsafeQuery(
    'SELECT 1 FROM serverpod_auth_core_jwt_refresh_token WHERE id = @id::uuid '
    'AND "authUserId" = @user::uuid AND "lastUpdatedAt" > @cutoff',
    parameters: QueryParameters.named({
      'id': session.authenticated!.authId,
      'user': member.userId,
      'cutoff': DateTime.now().toUtc().subtract(archiveSessionLifetime),
    }),
  );
  if (valid.isEmpty) {
    throw ArchiveAuthException(message: 'Сеанс завершено. Увійдіть знову.');
  }
}

class ArchiveSyncEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// afterId=-1 reads a starting watermark BEFORE the initial snapshot.
  /// throughId pins each catch-up run, so concurrent imports cannot starve it.
  Future<String> changes(
    Session session,
    int afterId,
    int throughId,
  ) => archiveTransaction(session, (tx) async {
    final resetCursor = await archiveResetCursor(session, transaction: tx);
    final member = await _streamMember(session);
    final journalHead =
        (await ArchiveAudit.db.findFirstRow(
          session,
          orderBy: (t) => t.id.desc(),
          transaction: tx,
        ))?.id ??
        0;
    final head = journalHead > resetCursor ? journalHead : resetCursor;
    if (afterId < -1 ||
        throughId < 0 ||
        (throughId > 0 && throughId < afterId)) {
      throw ArchiveAuthException(message: 'Оновіть локальну копію архіву.');
    }
    if (afterId > head || (afterId >= 0 && afterId < resetCursor)) {
      return jsonEncode({
        'ok': true,
        'data': {'reset': true},
      });
    }
    if (afterId == -1) {
      return jsonEncode({
        'ok': true,
        'data': {'cursor': head},
      });
    }
    final until = throughId == 0 || throughId > head ? head : throughId;
    final rows = await ArchiveAudit.db.find(
      session,
      where: (t) => (t.id > afterId) & (t.id <= until),
      orderBy: (t) => t.id,
      limit: 200,
      transaction: tx,
    );
    final modules = ArchiveModule.values
        .where((m) => canReadModule(archiveMemberJson(member), m))
        .map((m) => m.name)
        .toSet();
    final items = <Map<String, dynamic>>[];
    var processed = afterId;
    var encodedBytes = 0;
    for (final event in rows) {
      final visible = modules.contains(event.module);
      final record = visible && event.action.startsWith('record.');
      final document = visible && event.action.startsWith('document.');
      final attachment = visible && event.action.startsWith('attachment.');
      if (member.role != 'admin' && !record && !document && !attachment) {
        processed = event.id!;
        continue;
      }
      final item = <String, dynamic>{
        'id': event.id,
        'action': event.action,
        if (record) 'record': jsonDecode(event.afterJson),
        if (document) 'documentsChanged': true,
        if (attachment ||
            (record &&
                [
                  'record.merge',
                  'record.delete',
                  'record.restore',
                ].contains(event.action)))
          'filesChanged': true,
        if (event.action.startsWith('member.')) 'membersChanged': true,
        if (member.role == 'admin')
          'audit': {
            ...archiveAuditJson(event),
            'before': jsonDecode(event.beforeJson),
            'after': jsonDecode(event.afterJson),
            'details': jsonDecode(event.detailsJson),
          },
      };
      final bytes = utf8.encode(jsonEncode(item)).length;
      // Bound transfer pages, never discard a large card or cap total imports.
      if (items.isNotEmpty && encodedBytes + bytes > 1024 * 1024) break;
      encodedBytes += bytes;
      items.add(item);
      processed = event.id!;
    }
    return jsonEncode({
      'ok': true,
      'data': {
        'cursor': rows.isEmpty ? until : processed,
        'head': until,
        'hasMore': rows.isNotEmpty && processed < until,
        'items': items,
      },
    });
  });

  /// Bidirectional websocket: small liveness frames, no repeated archive reads.
  /// The lease also expires after an unclean disconnect/server crash.
  Stream<String> watch(
    Session session,
    Stream<int> heartbeat, {
    String? clientPlatform,
    int? clientBuild,
  }) {
    final output = StreamController<String>();
    StreamSubscription<int>? beats;
    StreamSubscription<ArchiveSignal>? events;
    Timer? timeout;
    ArchivePresence? lease;
    bool closed = false;
    Future<void> pending = Future.value();
    void send(String kind) {
      if (!closed) output.add(kind);
    }

    Future<void> cleanup() async {
      if (closed) return;
      closed = true;
      timeout?.cancel();
      await beats?.cancel();
      await events?.cancel();
      await pending.catchError((Object _) {});
      if (lease != null) {
        await ArchivePresence.db.deleteWhere(
          session,
          where: (t) => t.id.equals(lease!.id!),
        );
        await notifyArchive(session, 'presence');
      }
    }

    output.onCancel = cleanup;
    void queue(Future<void> Function() action) {
      pending = pending.then((_) async {
        if (closed) return;
        try {
          await action();
        } catch (e, st) {
          if (!closed) {
            output.addError(e, st);
            unawaited(output.close());
          }
        }
      });
    }

    void armTimeout() {
      timeout?.cancel();
      timeout = Timer(
        const Duration(seconds: 75),
        () => unawaited(output.close()),
      );
    }

    queue(() async {
      final required = await windowsClientPolicy.requiredUpdate(
        clientPlatform ?? '',
        clientBuild ?? 0,
      );
      if (required != null) {
        send('update-required:$required');
        unawaited(output.close());
        return;
      }
      var member = await _streamMember(session);
      await _validateStreamToken(session, member);
      await ArchivePresence.db.deleteWhere(
        session,
        where: (t) => t.expiresAt < DateTime.now().toUtc(),
      );
      DateTime? lastHeartbeat;
      // Register BEFORE sending ready; a change during snapshot/reconnect is caught.
      events = session.messages
          .createStream<ArchiveSignal>(archiveEventsChannel)
          .listen((event) {
            if (event.kind == 'presence') {
              if (member.role == 'admin') {
                queue(() async {
                  member = await _streamMember(session);
                  if (member.role == 'admin' &&
                      !member.passwordChangeRequired) {
                    send(
                      'presence:${jsonEncode(await archiveSessionStatus(session))}',
                    );
                  }
                });
              }
            } else {
              send(event.kind);
            }
          });
      lease = await ArchivePresence.db.insertRow(
        session,
        ArchivePresence(
          userId: member.userId,
          authId: session.authenticated!.authId,
          expiresAt: DateTime.now().toUtc().add(const Duration(seconds: 75)),
        ),
      );
      await notifyArchive(session, 'presence');
      send('ready');
      armTimeout();
      beats = heartbeat.listen(
        (_) => queue(() async {
          member = await _streamMember(session);
          final now = DateTime.now().toUtc();
          if (lastHeartbeat != null &&
              now.difference(lastHeartbeat!) < const Duration(seconds: 5)) {
            return;
          }
          lastHeartbeat = now;
          final required = await windowsClientPolicy.requiredUpdate(
            clientPlatform ?? '',
            clientBuild ?? 0,
          );
          if (required != null) {
            send('update-required:$required');
            unawaited(output.close());
            return;
          }
          await _validateStreamToken(session, member);
          lease = await ArchivePresence.db.updateRow(
            session,
            lease!.copyWith(
              expiresAt: DateTime.now().toUtc().add(
                const Duration(seconds: 75),
              ),
            ),
          );
          armTimeout();
          send('alive');
          if (member.role == 'admin' && !member.passwordChangeRequired) {
            send('presence:${jsonEncode(await archiveSessionStatus(session))}');
          }
        }),
        onDone: () => unawaited(output.close()),
        onError: (Object e, StackTrace st) {
          if (!closed) output.addError(e, st);
          unawaited(output.close());
        },
      );
    });
    return output.stream;
  }
}
