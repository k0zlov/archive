import 'dart:async';
import 'package:archive_flutter/ui/server_settings_dialog.dart';
import 'package:archive_flutter/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> openSettings(
  WidgetTester tester,
  Future<void> Function(String) save,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: archiveTheme(),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => ServerSettingsDialog(
                initialUrl: 'http://localhost:8080',
                onSave: (url, _) => save(url),
              ),
            ),
            child: const Text('Open settings'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open settings'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'validates the address, saves normalized URL and prevents repeated saves',
    (tester) async {
      final gate = Completer<void>();
      final calls = <String>[];
      await openSettings(tester, (url) async {
        calls.add(url);
        await gate.future;
      });
      final field = find.byKey(const ValueKey('server-url'));
      await tester.enterText(field, 'ftp://host');
      await tester.tap(find.text('Зберегти'));
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
      expect(find.textContaining('Введіть адресу'), findsOneWidget);
      await tester.enterText(field, ' http://192.168.0.102:8080 ');
      await tester.tap(find.text('Зберегти'));
      await tester.pump();
      expect(calls, ['http://192.168.0.102:8080/']);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Скасувати'))
            .onPressed,
        isNull,
      );
      gate.complete();
      await tester.pumpAndSettle();
      expect(find.byType(ServerSettingsDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'failed save retains address and allows retry; cancel never saves',
    (tester) async {
      var attempts = 0;
      await openSettings(tester, (_) async {
        attempts++;
        throw StateError('disk full');
      });
      await tester.enterText(
        find.byKey(const ValueKey('server-url')),
        'https://archive.example',
      );
      await tester.tap(find.text('Зберегти'));
      await tester.pumpAndSettle();
      expect(
        find.text('Не вдалося зберегти налаштування. Спробуйте ще раз.'),
        findsOneWidget,
      );
      expect(find.text('https://archive.example'), findsOneWidget);
      await tester.tap(find.text('Скасувати'));
      await tester.pumpAndSettle();
      expect(attempts, 1);
      expect(find.byType(ServerSettingsDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('small window scrolls settings content without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(440, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await openSettings(tester, (_) async {});
    expect(find.text('Налаштування'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Скасувати'));
    await tester.pumpAndSettle();
  });
}
