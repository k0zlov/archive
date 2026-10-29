import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import '../generated/protocol.dart';

/// Username adapter over Serverpod's password hashing, throttling and JWTs.
/// New accounts use an opaque internal credential identifier, never a mailbox.
String credentialIdentifier(ArchiveMember member) =>
    member.email.isNotEmpty ? member.email : '${member.userId}@archive.invalid';

String normalizeArchiveLogin(String value) {
  final login = value.trim().toLowerCase();
  if (!RegExp(r'^[a-z0-9][a-z0-9._-]{2,63}$').hasMatch(login)) {
    throw ArchiveAuthException(
      message:
          'Логін: 3–64 символи, латинські літери, цифри, крапка, дефіс або підкреслення.',
    );
  }
  return login;
}

void validateArchivePassword(String password) {
  if (password.length > 256 ||
      !AuthServices.instance.emailIdp.config.passwordValidationFunction(
        password,
      )) {
    throw ArchiveAuthException(
      message: 'Пароль: 8–256 символів, без пробілів на початку й у кінці.',
    );
  }
}

Future<ArchiveMember> authenticatedArchiveMember(
  Session session, {
  Transaction? transaction,
}) async {
  final userId = session.authenticated?.authUserId.toString();
  if (userId == null) {
    throw ArchiveAuthException(message: 'Увійдіть до облікового запису.');
  }
  final member = await ArchiveMember.db.findFirstRow(
    session,
    where: (t) => t.userId.equals(userId),
    transaction: transaction,
  );
  if (member == null || member.role == 'blocked') {
    throw ArchiveAuthException(message: 'Обліковий запис недоступний.');
  }
  return member;
}

ArchiveAuthException invalidArchiveCredentials() =>
    ArchiveAuthException(message: 'Неправильний логін або пароль.');

Future<AuthSuccess> archivePasswordLogin(
  Session session,
  String identifier,
  String password, {
  Transaction? transaction,
}) async {
  if (password.length > 256) throw invalidArchiveCredentials();
  try {
    return await AuthServices.instance.emailIdp.login(
      session,
      email: identifier,
      password: password,
      transaction: transaction,
    );
  } on EmailAccountLoginException catch (error) {
    throw ArchiveAuthException(
      message: error.reason == EmailAccountLoginExceptionReason.tooManyAttempts
          ? 'Забагато спроб. Спробуйте через кілька хвилин.'
          : 'Неправильний логін або пароль.',
    );
  }
}
