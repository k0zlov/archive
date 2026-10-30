import 'dart:io';
import 'package:archive_flutter/data/app_settings_store_native.dart';
import 'package:archive_flutter/main.dart';
import 'package:archive_flutter/ui/appearance_controller.dart';
import 'package:archive_flutter/ui/server_settings_dialog.dart';
import 'package:archive_flutter/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'server_connection_test.dart' show MemorySettings, ConnectionFixture;

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return ((x > y ? x : y) + .05) / ((x > y ? y : x) + .05);
}

void main() {
  test(
    'default follows system; every saved choice survives initialization',
    () async {
      final store = MemorySettings();
      final preferences = AppearanceController(store);
      await preferences.initialize();
      expect(preferences.mode, ThemeMode.system);
      for (final mode in [ThemeMode.dark, ThemeMode.light, ThemeMode.system]) {
        await preferences.setMode(mode);
        final reopened = AppearanceController(store);
        await reopened.initialize();
        expect(reopened.mode, mode);
        reopened.dispose();
      }
      store.theme = 'invalid future setting';
      await preferences.initialize();
      expect(preferences.mode, ThemeMode.system);
      preferences.dispose();
    },
  );

  test('failed persistence keeps the current theme', () async {
    final store = MemorySettings()..failWrite = true;
    final preferences = AppearanceController(store);
    await expectLater(
      preferences.setMode(ThemeMode.dark),
      throwsA(isA<FileSystemException>()),
    );
    expect(preferences.mode, ThemeMode.system);
    preferences.dispose();
  });

  test(
    'native settings preserve URL and theme through concurrent writes and URL rollback',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'archive-appearance-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final first = FileAppSettingsStore(directory: () async => directory);
      final second = FileAppSettingsStore(directory: () async => directory);
      await Future.wait([
        first.writeServerUrl('http://192.0.2.1:8080/'),
        second.writeThemeMode('dark'),
      ]);
      expect(await second.readServerUrl(), 'http://192.0.2.1:8080/');
      expect(await first.readThemeMode(), 'dark');
      await second.writeServerUrl(null);
      expect(await first.readServerUrl(), isNull);
      expect(await first.readThemeMode(), 'dark');
    },
  );

  for (final brightness in Brightness.values) {
    test(
      '$brightness normal, secondary, input, button and status text meet 4.5:1 contrast',
      () {
        final theme = archiveTheme(brightness: brightness);
        final scheme = theme.colorScheme;
        final colors = theme.extension<ArchiveColors>()!;
        for (final background in [
          scheme.surface,
          theme.scaffoldBackgroundColor,
          colors.panel,
          colors.subtleSurface,
        ]) {
          for (final foreground in [
            scheme.onSurface,
            scheme.onSurfaceVariant,
            scheme.primary,
          ]) {
            expect(
              contrast(foreground, background),
              greaterThanOrEqualTo(4.5),
              reason: '$brightness $foreground on $background',
            );
          }
        }
        expect(
          contrast(scheme.onPrimary, scheme.primary),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(scheme.error, scheme.errorContainer),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(colors.warningText, colors.warningSurface),
          greaterThanOrEqualTo(4.5),
        );
      },
    );
  }

  testWidgets(
    'system reacts to OS; explicit choices override OS without losing login input or connection',
    (tester) async {
      final f = ConnectionFixture();
      await f.connection.initialize();
      f.connection.client.authSessionManager = FlutterAuthSessionManager();
      final preferences = AppearanceController(f.store);
      addTearDown(preferences.dispose);
      addTearDown(f.close);
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      await tester.pumpWidget(
        MyApp(connection: f.connection, appearance: preferences),
      );
      await tester.enterText(
        find.byKey(const ValueKey('auth-login')),
        'my-login',
      );
      final original = f.connection.client;
      Brightness active() => Theme.of(
        tester.element(find.byKey(const ValueKey('auth-login'))),
      ).brightness;
      expect(active(), Brightness.light);
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pumpAndSettle();
      expect(active(), Brightness.dark);
      await preferences.setMode(ThemeMode.light);
      await tester.pumpAndSettle();
      expect(active(), Brightness.light);
      await preferences.setMode(ThemeMode.dark);
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      await tester.pumpAndSettle();
      expect(active(), Brightness.dark);
      await preferences.setMode(ThemeMode.system);
      await tester.pumpAndSettle();
      expect(active(), Brightness.light);
      expect(find.text('my-login'), findsOneWidget);
      expect(f.connection.client, same(original));
      expect(f.connection.generation, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'settings offers three modes and saves theme without changing the server',
    (tester) async {
      final f = ConnectionFixture();
      await f.connection.initialize();
      addTearDown(f.close);
      final preferences = AppearanceController(f.store);
      addTearDown(preferences.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: archiveTheme(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => ServerSettingsDialog(
                    initialUrl: f.connection.url,
                    onSave: (url, mode) async {
                      await preferences.setMode(mode);
                      await f.connection.changeServer(url);
                    },
                  ),
                ),
                child: const Text('Settings'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('theme-mode')));
      await tester.pumpAndSettle();
      expect(find.text('Системна'), findsWidgets);
      expect(find.text('Світла'), findsWidgets);
      expect(find.text('Темна'), findsWidgets);
      await tester.tap(find.text('Темна').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Зберегти'));
      await tester.pumpAndSettle();
      expect(preferences.mode, ThemeMode.dark);
      expect(f.store.theme, 'dark');
      expect(f.connection.generation, 0);
      expect(f.servers.single.cleared, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
