import 'dart:async';
import 'dart:convert';
import 'package:archive_server/src/generated/protocol.dart';
import 'package:archive_server/src/sync/archive_events.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart' show QueryParameters;
import 'test_tools/serverpod_test_tools.dart';

Map<String, dynamic> payload(String raw) =>
    Map<String, dynamic>.from(jsonDecode(raw)['data'] as Map);

void main() {
  const groupName = 'Durable sync, presence and account removal';
  withServerpod(groupName, (sessions, endpoints) {
    final session = sessions.build();
    late AuthSuccess admin, reader;
    late ArchiveMember readerMember;
    dynamic signed(AuthSuccess info) => sessions.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        info.authUserId.toString(),
        {},
        authId: info.jwtRefreshTokenId.toString(),
      ),
    );
    // Presence tests use a supported desktop client, independent of published
    // Windows releases. Version enforcement is covered by policy tests.
    Stream<String> watch(Stream<int> heartbeat) => endpoints.archiveSync.watch(
      signed(reader),
      heartbeat,
      clientPlatform: 'macos',
    );
    setUpAll(
      () => session.serverpod.initializeAuthServices(
        tokenManagerBuilders: [
          JwtConfig(
            algorithm: JwtAlgorithm.hmacSha512(
              SecretKey('archive-live-tests-only-private-key'),
            ),
            refreshTokenHashPepper: 'archive-live-tests-only-pepper',
          ),
        ],
        identityProviderBuilders: [
          EmailIdpConfig(
            secretHashPepper: 'archive-live-tests-password-pepper',
          ),
        ],
      ),
    );
    setUp(() async {
      await ArchivePresence.db.deleteWhere(session, where: (t) => t.id > 0);
      await ArchiveRecord.db.deleteWhere(session, where: (t) => t.id > 0);
      await ArchiveAudit.db.deleteWhere(session, where: (t) => t.id > 0);
      await ArchiveMember.db.deleteWhere(session, where: (t) => t.id > 0);
      for (final user in await AuthServices.instance.authUsers.list(session)) {
        await AuthServices.instance.authUsers.delete(
          session,
          authUserId: user.id,
        );
      }
      admin = await endpoints.login.register(
        sessions,
        'root.admin',
        'archive-test-password',
      );
      reader = await endpoints.login.register(
        sessions,
        'reader.one',
        'archive-test-password',
      );
      final adminMember = (await ArchiveMember.db.findFirstRow(
        session,
        where: (t) => t.userId.equals(admin.authUserId.toString()),
      ))!;
      await ArchiveMember.db.updateRow(
        session,
        adminMember.copyWith(role: 'admin'),
      );
      readerMember = (await ArchiveMember.db.findFirstRow(
        session,
        where: (t) => t.userId.equals(reader.authUserId.toString()),
      ))!;
      readerMember = await ArchiveMember.db.updateRow(
        session,
        readerMember.copyWith(role: 'reader', courtAccess: true),
      );
    });

    test(
      'journal sends only authorized cards, preserves tombstones and catches changes after the watermark',
      () async {
        final baseline =
            payload(
                  await endpoints.archiveSync.changes(signed(reader), -1, 0),
                )['cursor']
                as int;
        final card = payload(
          await endpoints.archive.saveRecord(
            signed(admin),
            'court',
            jsonEncode({'caseNumber': 'SYNC/1'}),
            null,
            null,
          ),
        );
        final hidden = await endpoints.archive.saveRecord(
          signed(admin),
          'management',
          jsonEncode({
            'caseIndex': '1',
            'title': 'Private management',
          }),
          null,
          null,
        );
        expect(jsonDecode(hidden)['ok'], true);
        await endpoints.archive.deleteRecord(
          signed(admin),
          card['id'],
          card['version'],
        );
        final delta = payload(
          await endpoints.archiveSync.changes(signed(reader), baseline, 0),
        );
        final items = delta['items'] as List;
        expect(items, hasLength(2));
        expect(items.every((e) => e['audit'] == null), true);
        expect(items.first['record']['values']['caseNumber'], 'SYNC/1');
        expect(items.last['record']['deletedAt'], isNotNull);
        await endpoints.archive.restoreRecord(signed(admin), card['id']);
        final restored = payload(
          await endpoints.archiveSync.changes(
            signed(reader),
            delta['cursor'],
            0,
          ),
        );
        expect(
          (restored['items'] as List).single['record']['deletedAt'],
          isNull,
        );
        await endpoints.archive.setMemberAccess(
          signed(admin),
          readerMember.id!,
          'reader',
          false,
          false,
        );
        final denied = payload(
          await endpoints.archiveSync.changes(signed(reader), baseline, 0),
        );
        expect(denied['items'], isEmpty);
      },
    );

    test(
      'byte-bounded journal pages advance only past delivered changes',
      () async {
        final baseline =
            payload(
                  await endpoints.archiveSync.changes(signed(admin), -1, 0),
                )['cursor']
                as int;
        final large = List.filled(400000, 'x').join();
        await session.db.transaction((tx) async {
          await writeArchiveAudits(session, [
            for (var i = 1; i <= 3; i++)
              ArchiveAudit(
                actorId: admin.authUserId.toString(),
                actorEmail: 'root.admin',
                action: 'record.update',
                target: '$i',
                module: 'court',
                afterJson: jsonEncode({
                  'id': i,
                  'version': 1,
                  'module': 'court',
                  'updatedAt': DateTime.now().toUtc().toIso8601String(),
                  'values': {'caseNumber': '$i', 'title': large},
                  'deletedAt': null,
                }),
              ),
          ], transaction: tx);
        });
        var cursor = baseline, head = 0;
        final delivered = <int>[];
        while (true) {
          final page = payload(
            await endpoints.archiveSync.changes(signed(admin), cursor, head),
          );
          head = page['head'] as int;
          final items = page['items'] as List;
          expect(items, hasLength(1));
          delivered.add(items.single['record']['id'] as int);
          expect(page['cursor'] as int, greaterThan(cursor));
          cursor = page['cursor'] as int;
          if (page['hasMore'] != true) break;
        }
        expect(delivered, [1, 2, 3]);
        expect(cursor, head);
      },
    );

    test(
      'counts live connections, ignores saved logins and drops expired or revoked connections',
      () async {
        await endpoints.login.login(
          sessions,
          'reader.one',
          'archive-test-password',
        );
        Future<Map> status() async =>
            (jsonDecode(await endpoints.archive.members(signed(admin)))['data']
                    as List)
                .cast<Map>()
                .singleWhere((m) => m['id'] == readerMember.id);
        expect((await status())['activeSessions'], 0);
        expect((await status())['online'], false);
        final lease = await ArchivePresence.db.insertRow(
          session,
          ArchivePresence(
            userId: readerMember.userId,
            authId: reader.jwtRefreshTokenId.toString(),
            expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 1)),
          ),
        );
        expect((await status())['activeSessions'], 1);
        final second = await ArchivePresence.db.insertRow(
          session,
          lease.copyWith(id: null),
        );
        expect((await status())['activeSessions'], 2);
        expect((await status())['online'], true);
        await ArchivePresence.db.updateRow(
          session,
          second.copyWith(
            expiresAt: DateTime.now().toUtc().subtract(
              const Duration(seconds: 1),
            ),
          ),
        );
        expect((await status())['activeSessions'], 1);
        await session.db.unsafeExecute(
          'UPDATE serverpod_auth_core_jwt_refresh_token SET "lastUpdatedAt" = @expired WHERE id = @id::uuid',
          parameters: QueryParameters.named({
            'id': reader.jwtRefreshTokenId.toString(),
            'expired': DateTime.now().toUtc().subtract(
              const Duration(days: 30),
            ),
          }),
        );
        expect((await status())['activeSessions'], 0);
        expect((await status())['online'], false);
      },
    );

    test(
      'watch receives hints, acknowledges liveness and removes its lease on cancellation',
      () async {
        final input = StreamController<int>();
        final output = StreamController<String>();
        final subscription = watch(input.stream).listen(
          output.add,
          onError: output.addError,
          onDone: output.close,
        );
        final iterator = StreamIterator(output.stream);
        expect(await iterator.moveNext(), true);
        expect(iterator.current, 'ready');
        expect(await ArchivePresence.db.count(session), 1);
        Future<int> connected() async {
          final raw = await endpoints.archive.members(signed(admin));
          final response = jsonDecode(raw) as Map;
          final users = (response['data'] as List).cast<Map>();
          final user = users.singleWhere((m) => m['id'] == readerMember.id);
          return user['activeSessions'] as int;
        }

        expect(await connected(), 1);
        // Two open sockets for the same user AND same auth token count twice.
        final secondInput = StreamController<int>();
        final second = StreamIterator(watch(secondInput.stream));
        expect(await second.moveNext(), true);
        expect(second.current, 'ready');
        expect(await connected(), 2);
        await second.cancel();
        await secondInput.close();
        expect(await connected(), 1);
        await endpoints.archive.saveRecord(
          signed(admin),
          'court',
          jsonEncode({'caseNumber': 'LIVE/1'}),
          null,
          null,
        );
        expect(await iterator.moveNext(), true);
        expect(iterator.current, 'data');
        input.add(1);
        expect(await iterator.moveNext(), true);
        expect(iterator.current, 'alive');
        await subscription.cancel();
        await input.close();
        await iterator.cancel();
        expect(await ArchivePresence.db.count(session), 0);
        expect(await connected(), 0);
      },
    );

    test(
      'only another administrator can delete an account and credentials and sessions are removed',
      () async {
        await endpoints.login.login(
          sessions,
          'reader.one',
          'archive-test-password',
        );
        await expectLater(
          endpoints.account.deleteMember(signed(reader), readerMember.id!),
          throwsA(isA<ArchiveAuthException>()),
        );
        final adminMember = (await ArchiveMember.db.findFirstRow(
          session,
          where: (t) => t.userId.equals(admin.authUserId.toString()),
        ))!;
        await expectLater(
          endpoints.account.deleteMember(signed(admin), adminMember.id!),
          throwsA(isA<ArchiveAuthException>()),
        );
        final input = StreamController<int>();
        final iterator = StreamIterator(watch(input.stream));
        expect(await iterator.moveNext(), true);
        expect(iterator.current, 'ready');
        await endpoints.account.deleteMember(signed(admin), readerMember.id!);
        input.add(1);
        try {
          final open = await iterator.moveNext().timeout(
            const Duration(seconds: 2),
          );
          expect(open, false);
        } catch (e) {
          expect(
            e,
            anyOf(
              isA<ConnectionClosedException>(),
              isA<ArchiveAuthException>(),
            ),
          );
        }
        await iterator.cancel();
        await input.close();

        final tokens = await AuthServices.instance.tokenManager.listTokens(
          session,
          authUserId: reader.authUserId,
        );
        expect(tokens, isEmpty);
        await expectLater(
          AuthServices.instance.authUsers.get(
            session,
            authUserId: reader.authUserId,
          ),
          throwsA(isA<AuthUserNotFoundException>()),
        );
        await expectLater(
          endpoints.login.login(
            sessions,
            'reader.one',
            'archive-test-password',
          ),
          throwsA(isA<ArchiveAuthException>()),
        );
        expect(
          jsonDecode(await endpoints.archive.profile(signed(reader)))['code'],
          'denied',
        );
        expect(
          (jsonDecode(await endpoints.archive.members(signed(admin)))['data']
                  as List)
              .any((m) => m['userId'] == readerMember.userId),
          false,
        );
        final audit = await ArchiveAudit.db.findFirstRow(
          session,
          where: (t) => t.action.equals('member.delete'),
        );
        expect(jsonDecode(audit!.beforeJson)['login'], 'reader.one');
        // A newly registered same login has a different identity, never old rights.
        final replacement = await endpoints.login.register(
          sessions,
          'reader.one',
          'replacement-password',
        );
        expect(replacement.authUserId, isNot(reader.authUserId));
        final newMember = (await ArchiveMember.db.findFirstRow(
          session,
          where: (t) => t.login.equals('reader.one'),
        ))!;
        expect(newMember.role, 'pending');
      },
    );

    test(
      'concurrent journal writers cannot commit a cursor beyond an unfinished earlier change',
      () async {
        final first = await session.serverpod.createSession();
        final second = await session.serverpod.createSession();
        final held = Completer<void>(), release = Completer<void>();
        try {
          final firstWrite = first.db.transaction((tx) async {
            await writeArchiveAudit(
              first,
              ArchiveAudit(
                actorId: 'test',
                actorEmail: 'test',
                action: 'test.first',
                target: '1',
              ),
              transaction: tx,
            );
            held.complete();
            await release.future;
          });
          await held.future;
          var secondFinished = false;
          final secondWrite = second.db
              .transaction((tx) async {
                await writeArchiveAudit(
                  second,
                  ArchiveAudit(
                    actorId: 'test',
                    actorEmail: 'test',
                    action: 'test.second',
                    target: '2',
                  ),
                  transaction: tx,
                );
              })
              .then((_) => secondFinished = true);
          await Future<void>.delayed(const Duration(milliseconds: 40));
          expect(secondFinished, false);
          final head =
              payload(
                    await endpoints.archiveSync.changes(signed(admin), -1, 0),
                  )['cursor']
                  as int;
          release.complete();
          await firstWrite;
          await secondWrite;
          final delta = payload(
            await endpoints.archiveSync.changes(signed(admin), head, 0),
          );
          expect((delta['items'] as List).map((e) => e['action']), [
            'test.first',
            'test.second',
          ]);
        } finally {
          if (!release.isCompleted) release.complete();
          await first.close();
          await second.close();
        }
      },
    );
  }, rollbackDatabase: RollbackDatabase.disabled);
}
