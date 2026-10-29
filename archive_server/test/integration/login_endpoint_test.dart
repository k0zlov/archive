import 'dart:convert';
import 'dart:io';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:archive_server/src/generated/protocol.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Username authentication', (sessions, endpoints) {
    final session = sessions.build();
    setUpAll(() {
      session.serverpod.initializeAuthServices(
        tokenManagerBuilders: [JwtConfigFromPasswords()],
        identityProviderBuilders: [EmailIdpConfigFromPasswords()],
      );
    });
    // The built-in rate limiter commits attempts on a separate connection.
    // Use real transactions in this group's disposable database.
    setUp(() async {
      await ArchiveAudit.db.deleteWhere(session, where: (t) => t.id > 0);
      await ArchiveMember.db.deleteWhere(session, where: (t) => t.id > 0);
      for (final user in await AuthServices.instance.authUsers.list(session)) {
        await AuthServices.instance.authUsers.delete(
          session,
          authUserId: user.id,
        );
      }
    });
    dynamic signedIn(String userId) => sessions.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(userId, {}),
    );
    Future<ArchiveMember> member(String login) async => (await ArchiveMember.db
        .findFirstRow(session, where: (t) => t.login.equals(login)))!;

    test(
      'registration needs no mailbox and always creates a pending member',
      () async {
        final auth = await endpoints.login.register(
          sessions,
          '  New.User  ',
          'test-password-one',
        );
        final created = await member('new.user');
        expect(created.userId, auth.authUserId.toString());
        expect(created.email, isEmpty);
        expect(created.role, 'pending');
        expect(created.courtAccess, false);
        expect(created.managementAccess, false);
        final success = await endpoints.login.login(
          sessions,
          'NEW.USER',
          'test-password-one',
        );
        expect(success.authUserId, auth.authUserId);
        final profile =
            jsonDecode(
                  await endpoints.archive.profile(signedIn(created.userId)),
                )['data']
                as Map;
        expect(profile['login'], 'new.user');
        final denied = jsonDecode(
          await endpoints.archive.records(signedIn(created.userId), 0),
        );
        expect(denied['code'], 'denied');
        final account = await AuthServices.instance.emailIdp.admin.findAccount(
          session,
          email: '${created.userId}@archive.invalid',
        );
        expect(account!.passwordHash, isNot(contains('test-password-one')));
        final journal = await ArchiveAudit.db.find(session);
        expect(journal.single.afterJson, isNot(contains('test-password-one')));
      },
    );

    test('invalid and duplicate logins leave no orphaned users', () async {
      await expectLater(
        endpoints.login.register(sessions, 'a@b.com', 'test-password-two'),
        throwsA(isA<ArchiveAuthException>()),
      );
      await expectLater(
        endpoints.login.register(sessions, 'valid', 'short'),
        throwsA(isA<ArchiveAuthException>()),
      );
      expect(await ArchiveMember.db.count(session), 0);
      await endpoints.login.register(
        sessions,
        'duplicate',
        'test-password-two',
      );
      final usersBefore = (await AuthServices.instance.authUsers.list(
        session,
      )).length;
      await expectLater(
        endpoints.login.register(sessions, 'DUPLICATE', 'another-password'),
        throwsA(isA<ArchiveAuthException>()),
      );
      expect(await ArchiveMember.db.count(session), 1);
      expect(
        (await AuthServices.instance.authUsers.list(session)).length,
        usersBefore,
      );
    });

    test(
      'legacy email credentials keep their password, ID and admin rights',
      () async {
        final services = AuthServices.instance;
        final user = await services.authUsers.create(session);
        await services.emailIdp.admin.createEmailAuthentication(
          session,
          authUserId: user.id,
          email: 'legacy@example.test',
          password: 'legacy-password',
        );
        await ArchiveMember.db.insertRow(
          session,
          ArchiveMember(
            userId: user.id.toString(),
            email: 'legacy@example.test',
            login: 'legacy',
            displayName: 'Адміністратор',
            role: 'admin',
          ),
        );
        final auth = await endpoints.login.login(
          sessions,
          'legacy',
          'legacy-password',
        );
        expect(auth.authUserId, user.id);
        final profile = jsonDecode(
          await endpoints.archive.profile(signedIn(user.id.toString())),
        )['data'];
        expect(profile['role'], 'admin');
        expect(profile['login'], 'legacy');
      },
    );

    test(
      'wrong credentials are generic and failed attempts are limited',
      () async {
        await endpoints.login.register(
          sessions,
          'ratelimit',
          'correct-password',
        );
        for (var attempt = 0; attempt < 5; attempt++) {
          await expectLater(
            endpoints.login.login(sessions, 'ratelimit', 'wrong-password'),
            throwsA(
              isA<ArchiveAuthException>().having(
                (e) => e.message,
                'message',
                'Неправильний логін або пароль.',
              ),
            ),
          );
        }
        await expectLater(
          endpoints.login.login(sessions, 'ratelimit', 'correct-password'),
          throwsA(
            isA<ArchiveAuthException>().having(
              (e) => e.message,
              'message',
              contains('Забагато спроб'),
            ),
          ),
        );
        await expectLater(
          endpoints.login.login(sessions, 'unknown', 'wrong-password'),
          throwsA(
            isA<ArchiveAuthException>().having(
              (e) => e.message,
              'message',
              'Неправильний логін або пароль.',
            ),
          ),
        );
      },
    );

    test(
      'admin reset requires a new password before any archive access and never audits secrets',
      () async {
        final adminAuth = await endpoints.login.register(
          sessions,
          'administrator',
          'admin-password',
        );
        final targetAuth = await endpoints.login.register(
          sessions,
          'reset-target',
          'original-password',
        );
        final actor = await member('administrator');
        final target = await member('reset-target');
        await ArchiveMember.db.updateRow(
          session,
          actor.copyWith(role: 'admin'),
        );
        await ArchiveMember.db.updateRow(
          session,
          target.copyWith(role: 'editor', courtAccess: true),
        );
        final adminSession = signedIn(adminAuth.authUserId.toString());
        final targetSession = signedIn(targetAuth.authUserId.toString());
        await expectLater(
          endpoints.account.resetPassword(targetSession, actor.id!),
          throwsA(isA<ArchiveAuthException>()),
        );
        await expectLater(
          endpoints.account.resetPassword(adminSession, actor.id!),
          throwsA(isA<ArchiveAuthException>()),
        );
        final temporary = await endpoints.account.resetPassword(
          adminSession,
          target.id!,
        );
        expect(temporary.length, 20);
        expect((await member('reset-target')).passwordChangeRequired, true);
        expect((await member('reset-target')).role, 'editor');
        await expectLater(
          endpoints.login.login(sessions, 'reset-target', 'original-password'),
          throwsA(isA<ArchiveAuthException>()),
        );
        final temporarySession = await endpoints.login.login(
          sessions,
          'reset-target',
          temporary,
        );
        expect(temporarySession.authUserId, targetAuth.authUserId);
        final denied = jsonDecode(
          await endpoints.archive.records(targetSession, 0),
        );
        expect(denied['code'], 'denied');
        final requiredProfile = jsonDecode(
          await endpoints.archive.profile(targetSession),
        )['data'];
        expect(requiredProfile['passwordChangeRequired'], true);
        await expectLater(
          endpoints.account.changePassword(
            targetSession,
            'incorrect',
            'my-new-password',
          ),
          throwsA(isA<ArchiveAuthException>()),
        );
        final changed = await endpoints.account.changePassword(
          targetSession,
          temporary,
          'my-new-password',
        );
        expect(changed.authUserId, targetAuth.authUserId);
        expect((await member('reset-target')).passwordChangeRequired, false);
        expect(
          jsonDecode(await endpoints.archive.records(targetSession, 0))['ok'],
          true,
        );
        await expectLater(
          endpoints.login.login(sessions, 'reset-target', temporary),
          throwsA(isA<ArchiveAuthException>()),
        );
        expect(
          (await endpoints.login.login(
            sessions,
            'reset-target',
            'my-new-password',
          )).authUserId,
          targetAuth.authUserId,
        );
        final journal = await ArchiveAudit.db.find(session);
        final raw = journal
            .map((a) => '${a.beforeJson}${a.afterJson}${a.detailsJson}')
            .join();
        for (final secret in [
          temporary,
          'original-password',
          'my-new-password',
        ]) {
          expect(raw, isNot(contains(secret)));
        }
        expect(
          journal.where((a) => a.action == 'member.password.reset'),
          hasLength(1),
        );
        expect(
          journal.where((a) => a.action == 'member.password.change'),
          hasLength(1),
        );
      },
    );

    test('blocked users cannot sign in or change passwords', () async {
      final auth = await endpoints.login.register(
        sessions,
        'blocked-user',
        'original-password',
      );
      final target = await member('blocked-user');
      await ArchiveMember.db.updateRow(
        session,
        target.copyWith(role: 'blocked'),
      );
      await expectLater(
        endpoints.login.login(sessions, 'blocked-user', 'original-password'),
        throwsA(isA<ArchiveAuthException>()),
      );
      await expectLater(
        endpoints.account.changePassword(
          signedIn(auth.authUserId.toString()),
          'original-password',
          'new-password',
        ),
        throwsA(isA<ArchiveAuthException>()),
      );
      await expectLater(
        endpoints.account.changePassword(
          sessions,
          'original-password',
          'new-password',
        ),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });

    test(
      'migration preserves identities and reserves unique case-insensitive usernames',
      () async {
        for (final email in [
          'Unique.Name@example.test',
          'same@one.test',
          'same@two.test',
          'user-4@example.test',
          'x@example.test',
        ]) {
          await ArchiveMember.db.insertRow(
            session,
            ArchiveMember(
              userId: email,
              email: email,
              displayName: email,
              role: 'admin',
            ),
          );
        }
        final before = await ArchiveMember.db.find(session);
        final sql = await File(
          'migrations/20261029202326913-username_login/migration.sql',
        ).readAsString();
        final transform = sql.substring(
          sql.indexOf('UPDATE "archive_member" SET'),
          sql.indexOf('CREATE UNIQUE INDEX'),
        );
        await session.db.unsafeExecute(transform);
        final after = await ArchiveMember.db.find(session);
        expect(after.map((m) => m.login).toSet().length, before.length);
        expect(
          after.firstWhere((m) => m.email.startsWith('Unique')).login,
          'unique.name',
        );
        for (final row in after) {
          final old = before.singleWhere((m) => m.id == row.id);
          expect(row.userId, old.userId);
          expect(row.role, old.role);
          if (!row.email.startsWith('Unique')) {
            expect(row.login, 'user-${row.id}');
          }
        }
      },
    );
  }, rollbackDatabase: RollbackDatabase.disabled);
}
