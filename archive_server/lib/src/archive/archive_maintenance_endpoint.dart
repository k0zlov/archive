import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import 'package:archive_shared/archive_schema.dart';
import '../auth/archive_credentials.dart';
import '../generated/protocol.dart';
import '../sync/archive_events.dart';
import 'archive_record_writer.dart';

class ArchiveMaintenanceEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<ArchiveMember> _admin(
    Session session, {
    Transaction? transaction,
  }) async {
    final actor = await authenticatedArchiveMember(
      session,
      transaction: transaction,
    );
    if (actor.role != 'admin' || actor.passwordChangeRequired) {
      throw ArchiveAuthException(
        message: 'Очищення доступне лише адміністратору.',
      );
    }
    return actor;
  }

  Future<String> summary(Session session) async {
    await _admin(session);
    return jsonEncode({
      'ok': true,
      'data': {
        'records': await ArchiveRecord.db.count(session),
        'files': await ArchiveAttachment.db.count(session),
        'documents': await ArchiveDocument.db.count(session),
        'audit': await ArchiveAudit.db.count(session),
      },
    });
  }

  Future<String> clearRecords(Session session, String confirmation) =>
      _clear(session, confirmation, full: false);
  Future<String> clearArchive(Session session, String confirmation) =>
      _clear(session, confirmation, full: true);

  Future<String> _clear(
    Session session,
    String confirmation, {
    required bool full,
  }) async {
    await _admin(session);
    final requiredText = full ? 'ОЧИСТИТИ АРХІВ' : 'ВИДАЛИТИ ВСІ СПРАВИ';
    if (confirmation != requiredText) {
      throw ArchiveAuthException(
        message: 'Введіть фразу підтвердження без змін.',
      );
    }
    final result = await session.db.transaction((tx) async {
      await session.db.unsafeQuery(
        'SELECT pg_advisory_xact_lock(418243, 2)',
        transaction: tx,
      );
      final actor = await _admin(session, transaction: tx);
      final counts = {
        'records': await ArchiveRecord.db.count(session, transaction: tx),
        'files': await ArchiveAttachment.db.count(session, transaction: tx),
      };
      // Cascading relations delete staged import rows and every file part.
      await session.db.unsafeExecute(
        'DELETE FROM archive_import_job',
        transaction: tx,
      );
      await session.db.unsafeExecute(
        'DELETE FROM archive_record',
        transaction: tx,
      );
      if (full) {
        counts['documents'] = await ArchiveDocument.db.count(
          session,
          transaction: tx,
        );
        counts['audit'] = await ArchiveAudit.db.count(session, transaction: tx);
        await session.db.unsafeExecute(
          'DELETE FROM archive_document',
          transaction: tx,
        );
        await session.db.unsafeExecute(
          'DELETE FROM archive_audit',
          transaction: tx,
        );
      } else {
        // Record-scoped markers also invalidate older polling clients.
        await writeArchiveAudits(session, [
          for (final module in ArchiveModule.values)
            archiveChange(
              actor,
              'record.clear',
              'all',
              module: module.name,
              details: counts,
            ),
        ], transaction: tx);
      }
      await resetArchiveCursor(session, tx);
      return counts;
    });
    await notifyArchive(session, 'data');
    return jsonEncode({'ok': true, 'data': result});
  }
}
