import 'package:archive_client/archive_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import '../client.dart';

abstract class AuthGateway {
  Future<void> login(String login, String password);
  Future<void> register(String login, String password);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<String> resetPassword(int memberId);
}

class ServerpodAuthGateway implements AuthGateway {
  Future<void> _authenticate(
    Future<AuthSuccess> Function(Client source) request,
  ) async {
    final source = client;
    final result = await request(source);
    await serverConnection.updateAuthentication(
      source,
      () => source.auth.updateSignedInUser(result),
    );
  }

  @override
  Future<void> login(String login, String password) =>
      _authenticate((source) => source.login.login(login, password));
  @override
  Future<void> register(String login, String password) =>
      _authenticate((source) => source.login.register(login, password));
  @override
  Future<void> changePassword(String currentPassword, String newPassword) =>
      _authenticate(
        (source) => source.account.changePassword(currentPassword, newPassword),
      );
  @override
  Future<String> resetPassword(int memberId) =>
      client.account.resetPassword(memberId);
}

String authErrorMessage(Object error) => error is ArchiveAuthException
    ? error.message
    : 'Не вдалося з’єднатися із сервером. Спробуйте ще раз.';
