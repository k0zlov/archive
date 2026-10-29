import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import '../generated/protocol.dart';
import '../archive/archive_record_writer.dart';
import 'archive_credentials.dart';

class LoginEndpoint extends Endpoint {
  Future<AuthSuccess> login(
    Session session,
    String login,
    String password,
  ) async {
    String normalized;
    try {
      normalized = normalizeArchiveLogin(login);
    } on ArchiveAuthException {
      throw invalidArchiveCredentials();
    }
    final member = await ArchiveMember.db.findFirstRow(
      session,
      where: (t) => t.login.equals(normalized),
    );
    // Unknown and blocked users follow the same credential failure path.
    return archivePasswordLogin(
      session,
      member == null || member.role == 'blocked'
          ? 'unknown-$normalized@archive.invalid'
          : credentialIdentifier(member),
      password,
    );
  }

  Future<AuthSuccess> register(
    Session session,
    String login,
    String password,
  ) async {
    final normalized = normalizeArchiveLogin(login);
    validateArchivePassword(password);
    try {
      return await session.db.transaction((tx) async {
        final existing = await ArchiveMember.db.findFirstRow(
          session,
          where: (t) => t.login.equals(normalized),
          transaction: tx,
        );
        if (existing != null) {
          throw ArchiveAuthException(message: 'Цей логін уже зайнятий.');
        }
        final services = AuthServices.instance;
        final user = await services.authUsers.create(session, transaction: tx);
        final member = await ArchiveMember.db.insertRow(
          session,
          ArchiveMember(
            userId: user.id.toString(),
            email: '',
            login: normalized,
            displayName: normalized,
            // Registration never grants access, including reserved-looking names.
            role: 'pending',
          ),
          transaction: tx,
        );
        await services.emailIdp.admin.createEmailAuthentication(
          session,
          authUserId: user.id,
          email: credentialIdentifier(member),
          password: password,
          transaction: tx,
        );
        await services.userProfiles.createUserProfile(
          session,
          user.id,
          UserProfileData(userName: normalized, fullName: normalized),
          transaction: tx,
        );
        await ArchiveAudit.db.insertRow(
          session,
          archiveChange(
            member,
            'member.create',
            member.userId,
            after: archiveMemberJson(member),
          ),
          transaction: tx,
        );
        return services.tokenManager.issueToken(
          session,
          authUserId: user.id,
          method: services.emailIdp.method,
          scopes: user.scopes,
          transaction: tx,
        );
      });
    } on DatabaseUniqueViolationException {
      throw ArchiveAuthException(message: 'Цей логін уже зайнятий.');
    }
  }
}
