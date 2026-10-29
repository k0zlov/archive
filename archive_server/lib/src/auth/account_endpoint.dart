import 'dart:math';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import '../generated/protocol.dart';
import '../archive/archive_record_writer.dart';
import 'archive_credentials.dart';

class AccountEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<AuthSuccess> changePassword(
    Session session,
    String currentPassword,
    String newPassword,
  ) async {
    validateArchivePassword(newPassword);
    if (currentPassword == newPassword) {
      throw ArchiveAuthException(
        message: 'Новий пароль має відрізнятися від поточного.',
      );
    }
    return session.db.transaction((tx) async {
      await session.db.unsafeExecute(
        'LOCK TABLE archive_member IN SHARE ROW EXCLUSIVE MODE',
        transaction: tx,
      );
      final member = await authenticatedArchiveMember(session, transaction: tx);
      final identifier = credentialIdentifier(member);
      // Authenticate under the same identity lock as administrative resets.
      // Serverpod persists failed attempts outside this transaction.
      final verified = await archivePasswordLogin(
        session,
        identifier,
        currentPassword,
        transaction: tx,
      );
      if (verified.authUserId.toString() != member.userId) {
        throw invalidArchiveCredentials();
      }
      final services = AuthServices.instance;
      await services.emailIdp.admin.setPassword(
        session,
        email: identifier,
        password: newPassword,
        transaction: tx,
      );
      await services.tokenManager.revokeAllTokens(
        session,
        authUserId: verified.authUserId,
        transaction: tx,
      );
      await ArchiveMember.db.updateRow(
        session,
        member.copyWith(passwordChangeRequired: false),
        transaction: tx,
      );
      await ArchiveAudit.db.insertRow(
        session,
        archiveChange(member, 'member.password.change', member.userId),
        transaction: tx,
      );
      return archivePasswordLogin(
        session,
        identifier,
        newPassword,
        transaction: tx,
      );
    });
  }

  /// A one-time displayed temporary password; never written to the audit journal.
  Future<String> resetPassword(Session session, int memberId) async {
    return session.db.transaction((tx) async {
      await session.db.unsafeExecute(
        'LOCK TABLE archive_member IN SHARE ROW EXCLUSIVE MODE',
        transaction: tx,
      );
      final actor = await authenticatedArchiveMember(session, transaction: tx);
      if (actor.role != 'admin' ||
          actor.passwordChangeRequired ||
          actor.id == memberId) {
        throw ArchiveAuthException(
          message: 'Немає дозволу на скидання пароля.',
        );
      }
      final target = await ArchiveMember.db.findById(
        session,
        memberId,
        transaction: tx,
      );
      if (target == null) {
        throw ArchiveAuthException(message: 'Користувача не знайдено.');
      }
      const alphabet = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ23456789';
      final random = Random.secure();
      final temporary = List.generate(
        20,
        (_) => alphabet[random.nextInt(alphabet.length)],
      ).join();
      final services = AuthServices.instance;
      await services.emailIdp.admin.setPassword(
        session,
        email: credentialIdentifier(target),
        password: temporary,
        transaction: tx,
      );
      await services.tokenManager.revokeAllTokens(
        session,
        authUserId: UuidValue.fromString(target.userId),
        transaction: tx,
      );
      await ArchiveMember.db.updateRow(
        session,
        target.copyWith(passwordChangeRequired: true),
        transaction: tx,
      );
      await ArchiveAudit.db.insertRow(
        session,
        archiveChange(actor, 'member.password.reset', target.userId),
        transaction: tx,
      );
      return temporary;
    });
  }
}
