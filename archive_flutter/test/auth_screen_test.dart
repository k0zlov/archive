import 'dart:async';
import 'package:archive_client/archive_client.dart';
import 'package:archive_flutter/data/auth_gateway.dart';
import 'package:archive_flutter/ui/auth_screen.dart';
import 'package:archive_flutter/ui/password_dialog.dart';
import 'package:archive_flutter/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthGateway implements AuthGateway {
  final calls = <List<String>>[];
  Completer<void>? gate;
  Object? failure;
  Future<void> _call(List<String> values) async {
    calls.add(values);
    if (gate != null) await gate!.future;
    if (failure != null) throw failure!;
  }

  @override
  Future<void> login(String login, String password) =>
      _call(['login', login, password]);
  @override
  Future<void> register(String login, String password) =>
      _call(['register', login, password]);
  @override
  Future<void> changePassword(String currentPassword, String newPassword) =>
      _call(['change', currentPassword, newPassword]);
  @override
  Future<String> resetPassword(int memberId) async => 'temporary-test-password';
}

void main() {
  testWidgets(
    'login uses a username without any email or code fields and prevents duplicate requests',
    (tester) async {
      final gateway = FakeAuthGateway()..gate = Completer<void>();
      await tester.pumpWidget(
        MaterialApp(
          theme: archiveTheme(),
          home: AuthScreen(gateway: gateway),
        ),
      );
      expect(find.text('Логін'), findsOneWidget);
      expect(find.text('Електронна пошта'), findsNothing);
      expect(find.text('Код підтвердження'), findsNothing);
      await tester.enterText(
        find.byKey(const ValueKey('auth-login')),
        '  My.Login  ',
      );
      await tester.enterText(
        find.byKey(const ValueKey('auth-password')),
        'existing-password',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Увійти'));
      await tester.pump();
      expect(gateway.calls.single, ['login', 'my.login', 'existing-password']);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      gateway.failure = ArchiveAuthException(
        message: 'Неправильний логін або пароль.',
      );
      gateway.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Неправильний логін або пароль.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'registration confirms passwords and submits without sending any code',
    (tester) async {
      final gateway = FakeAuthGateway();
      await tester.pumpWidget(
        MaterialApp(
          theme: archiveTheme(),
          home: AuthScreen(gateway: gateway),
        ),
      );
      await tester.tap(
        find.widgetWithText(TextButton, 'Створити обліковий запис'),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('auth-login')),
        'new-user',
      );
      await tester.enterText(
        find.byKey(const ValueKey('auth-password')),
        'new-password',
      );
      await tester.enterText(
        find.byKey(const ValueKey('auth-password-confirmation')),
        'different-password',
      );
      await tester.ensureVisible(find.byType(FilledButton));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('Паролі не збігаються.'), findsOneWidget);
      expect(gateway.calls, isEmpty);
      await tester.enterText(
        find.byKey(const ValueKey('auth-password-confirmation')),
        'new-password',
      );
      await tester.ensureVisible(find.byType(FilledButton));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(gateway.calls.single, ['register', 'new-user', 'new-password']);
      expect(find.textContaining('підтвердження з листа'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'temporary password form stays on screen until a valid password change succeeds',
    (tester) async {
      final gateway = FakeAuthGateway();
      var completed = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: archiveTheme(),
          home: Scaffold(
            body: Center(
              child: PasswordChangeForm(
                gateway: gateway,
                requiredChange: true,
                onChanged: () async {
                  completed++;
                },
              ),
            ),
          ),
        ),
      );
      expect(find.text('Створіть власний пароль'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('password-current')),
        'temporary-password',
      );
      await tester.enterText(
        find.byKey(const ValueKey('password-new')),
        'my-new-password',
      );
      await tester.enterText(
        find.byKey(const ValueKey('password-confirmation')),
        'wrong-confirmation',
      );
      await tester.tap(find.text('Зберегти пароль'));
      await tester.pumpAndSettle();
      expect(gateway.calls, isEmpty);
      expect(completed, 0);
      await tester.enterText(
        find.byKey(const ValueKey('password-confirmation')),
        'my-new-password',
      );
      gateway.failure = ArchiveAuthException(
        message: 'Неправильний логін або пароль.',
      );
      await tester.tap(find.text('Зберегти пароль'));
      await tester.pumpAndSettle();
      expect(completed, 0);
      expect(find.text('Неправильний логін або пароль.'), findsOneWidget);
      gateway.failure = null;
      await tester.tap(find.text('Зберегти пароль'));
      await tester.pumpAndSettle();
      expect(completed, 1);
      expect(gateway.calls.last, [
        'change',
        'temporary-password',
        'my-new-password',
      ]);
      expect(tester.takeException(), isNull);
    },
  );
}
