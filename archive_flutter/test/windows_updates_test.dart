import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive_client/archive_client.dart';
import 'package:archive_flutter/data/updates/update_platform.dart';
import 'package:archive_flutter/data/updates/update_platform_native.dart';
import 'package:archive_flutter/data/updates/update_source.dart';
import 'package:archive_flutter/data/updates/client_access.dart';
import 'package:archive_flutter/ui/windows_update_controller.dart';
import 'package:archive_flutter/ui/windows_update_panel.dart';
import 'package:archive_flutter/ui/server_settings_dialog.dart';
import 'package:archive_flutter/ui/theme.dart';
import 'package:archive_shared/windows_release.dart';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class UpdateTestSource implements UpdateSource {
  String? envelope;
  Completer<String?>? gate;
  final bytes = Uint8List.fromList(
    List.generate(windowsUpdateChunkSize + 19, (i) => i % 251),
  );
  bool corrupt = false;
  final offsets = <int>[];
  @override
  Future<String?> check() async => gate == null ? envelope : gate!.future;
  @override
  Future<ByteData> download(String hash, int offset) async {
    offsets.add(offset);
    final part = Uint8List.fromList(
      bytes.sublist(
        offset,
        (offset + windowsUpdateChunkSize).clamp(0, bytes.length),
      ),
    );
    if (corrupt) part[0] ^= 1;
    return ByteData.sublistView(part);
  }
}

class MemoryUpdatePlatform implements UpdatePlatform {
  Completer<PreparedUpdate>? gate;
  int installed = 0, discarded = 0;
  bool failInstall = false;
  @override
  Future<PreparedUpdate> download(
    WindowsRelease release,
    FetchUpdatePart fetch, {
    required bool Function() cancelled,
    required void Function(int) progress,
  }) async {
    progress(50);
    return gate == null ? const PreparedUpdate('memory') : gate!.future;
  }

  @override
  Future<void> discard(PreparedUpdate update) async {
    discarded++;
  }

  @override
  Future<void> install(PreparedUpdate update, WindowsRelease release) async {
    if (failInstall) throw const UpdateFailure('Встановлення недоступне.');
    installed++;
  }
}

class RequestRecordingClient extends Client {
  RequestRecordingClient() : super('http://localhost:8080/');
  final authenticatedCalls = <bool>[];
  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) async {
    authenticatedCalls.add(authenticated);
    return (method == 'check' ? null : ByteData(1)) as T;
  }
}

void main() {
  final seed = List<int>.generate(32, (i) => i + 1);
  late String key;
  late UpdateTestSource source;
  late MemoryUpdatePlatform platform;
  late WindowsRelease release;
  setUp(() async {
    source = UpdateTestSource();
    platform = MemoryUpdatePlatform();
    key = base64Encode(
      (await (await Ed25519().newKeyPairFromSeed(
        seed,
      )).extractPublicKey()).bytes,
    );
    release = WindowsRelease(
      version: '1.0.1',
      build: 2,
      sha256: sha256.convert(source.bytes).toString(),
      size: source.bytes.length,
      notes: 'Поліпшено пошук',
    );
    source.envelope = await signWindowsRelease(release, seed);
  });
  WindowsUpdateController controller() => WindowsUpdateController(
    version: '1.0.0',
    build: 1,
    trustedKey: key,
    source: source,
    platform: platform,
  );

  test(
    'checks and binary downloads never attach account authentication',
    () async {
      final client = RequestRecordingClient();
      addTearDown(client.close);
      final gateway = ServerpodUpdateSource(client);
      await gateway.check();
      await gateway.download('a' * 64, 0);
      expect(client.authenticatedCalls, [false, false]);
    },
  );
  test(
    'only a signed newer build is offered; check does not install anything',
    () async {
      final c = controller();
      addTearDown(c.dispose);
      await c.check();
      expect(c.release?.build, 2);
      expect(platform.installed, 0);
      await c.download();
      expect(c.prepared, isNotNull);
      expect(platform.installed, 0);
      await c.install();
      expect(platform.installed, 1);
      source.envelope = await signWindowsRelease(
        WindowsRelease(
          version: '0.9.0',
          build: 1,
          sha256: release.sha256,
          size: release.size,
        ),
        seed,
      );
      await c.check();
      // A signed older manifest cannot roll back the verified update policy.
      expect(c.release?.build, 2);
      expect(c.prepared, isNotNull);
    },
  );
  test(
    'invalid signature and offline failures cannot launch an installer',
    () async {
      source.envelope = source.envelope!.replaceFirst('signature', 'wrong');
      final c = controller();
      addTearDown(c.dispose);
      await c.check();
      await c.download();
      await c.install();
      expect(c.error, contains('підпис'));
      expect(platform.installed, 0);
      source.gate = Completer<String?>()
        ..completeError(const SocketException('offline'));
      await c.check();
      expect(c.error, contains('перевірити'));
    },
  );
  test(
    'late checks and downloads from the previous server are ignored and discarded',
    () async {
      final c = controller();
      addTearDown(c.dispose);
      source.gate = Completer<String?>();
      final checking = c.check();
      final other = UpdateTestSource();
      c.reset(other);
      source.gate!.complete(source.envelope);
      await checking;
      await Future<void>.delayed(Duration.zero);
      expect(c.release, isNull);
      source.gate = null;
      final downloadingController = controller();
      addTearDown(downloadingController.dispose);
      await downloadingController.check();
      platform.gate = Completer<PreparedUpdate>();
      final downloading = downloadingController.download();
      downloadingController.reset(other);
      platform.gate!.complete(const PreparedUpdate('old-server'));
      await downloading;
      expect(downloadingController.prepared, isNull);
      expect(platform.discarded, 1);
    },
  );
  test(
    'cache preparation finishes before install; launch failure resumes the archive',
    () async {
      final c = controller();
      addTearDown(c.dispose);
      await c.check();
      await c.download();
      final gate = Completer<void>();
      var resumed = false;
      c.registerPreparation(() => gate.future, () => resumed = true);
      platform.failInstall = true;
      final installing = c.install();
      expect(platform.installed, 0);
      expect(c.installing, isTrue);
      gate.complete();
      await installing;
      expect(resumed, isTrue);
      expect(c.error, 'Встановлення недоступне.');
    },
  );

  test(
    'native download streams bounded chunks, rechecks bytes before launching and never deletes user data',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'archive-download-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      var launched = false, quit = false;
      final files = WindowsUpdateFiles(
        directory: () async => directory,
        launch: (path, args) async {
          launched = true;
          expect(args, contains('/ARCHIVEPID=$pid'));
        },
        quit: () => quit = true,
      );
      final percentages = <int>[];
      final ready = await files.download(
        release,
        (offset) => source.download(release.sha256, offset),
        cancelled: () => false,
        progress: percentages.add,
      );
      expect(source.offsets, [0, windowsUpdateChunkSize]);
      expect(percentages.last, 100);
      expect(await File(ready.path).readAsBytes(), source.bytes);
      await files.install(ready, release);
      expect(launched && quit, isTrue);
      launched = false;
      quit = false;
      await File(ready.path).writeAsBytes([1, 2, 3]);
      await expectLater(
        files.install(ready, release),
        throwsA(isA<UpdateFailure>()),
      );
      expect(launched || quit, isFalse);
      await files.discard(ready);
      expect(await File(ready.path).exists(), isFalse);
    },
  );
  test('corrupt or cancelled downloads leave no runnable installer', () async {
    final directory = await Directory.systemTemp.createTemp(
      'archive-bad-download-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final files = WindowsUpdateFiles(directory: () async => directory);
    source.corrupt = true;
    await expectLater(
      files.download(
        release,
        (offset) => source.download(release.sha256, offset),
        cancelled: () => false,
        progress: (_) {},
      ),
      throwsA(isA<UpdateFailure>()),
    );
    expect(await directory.list().toList(), isEmpty);
    source.corrupt = false;
    await expectLater(
      files.download(
        release,
        (offset) => source.download(release.sha256, offset),
        cancelled: () => true,
        progress: (_) {},
      ),
      throwsA(isA<UpdateCancelled>()),
    );
    expect(await directory.list().toList(), isEmpty);
  });

  for (final brightness in Brightness.values) {
    for (final hasCache in [true, false]) {
      testWidgets('$brightness mandatory update with cache=$hasCache', (
        tester,
      ) async {
        source.envelope = await signWindowsRelease(
          WindowsRelease(
            version: '1.0.1',
            build: 2,
            minimumSupportedBuild: 2,
            sha256: release.sha256,
            size: release.size,
          ),
          seed,
        );
        final c = controller();
        addTearDown(c.dispose);
        await c.check();
        expect(c.access.requiredUpdate, isTrue);
        expect(c.access.ensureOnline, throwsA(isA<ClientOfflineException>()));
        await tester.pumpWidget(
          MaterialApp(
            theme: archiveTheme(brightness: brightness),
            home: WindowsUpdateHost(
              controller: c,
              offlineAvailable: () async => hasCache,
              child: const Scaffold(body: Text('Локальні справи')),
            ),
          ),
        );
        expect(find.text('Потрібне оновлення'), findsOneWidget);
        expect(find.text('Локальні справи'), findsNothing);
        await tester.tap(find.text('Працювати офлайн'));
        await tester.pumpAndSettle();
        if (hasCache) {
          expect(find.text('Локальні справи'), findsOneWidget);
          expect(c.access.onlineAllowed, isFalse);
          await tester.tap(find.text('Оновити'));
          await tester.pumpAndSettle();
          expect(find.text('Потрібне оновлення'), findsOneWidget);
        } else {
          expect(find.text('Локальні справи'), findsNothing);
          expect(find.textContaining('Локальної копії немає'), findsOneWidget);
        }
        await tester.tap(find.text('Завантажити'));
        await tester.pumpAndSettle();
        expect(platform.installed, 0);
        await tester.tap(find.text('Встановити й перезапустити'));
        await tester.pumpAndSettle();
        expect(platform.installed, 1);
        expect(tester.takeException(), isNull);
      });
    }
    testWidgets(
      '$brightness Windows update banner and settings use explicit user actions',
      (tester) async {
        final c = controller();
        addTearDown(c.dispose);
        await c.check();
        await tester.pumpWidget(
          MaterialApp(
            theme: archiveTheme(brightness: brightness),
            home: WindowsUpdateHost(
              controller: c,
              child: const Scaffold(body: Text('Вхід')),
            ),
          ),
        );
        expect(find.text('Доступне оновлення 1.0.1'), findsOneWidget);
        await tester.tap(find.text('Переглянути'));
        await tester.pumpAndSettle();
        expect(find.text('Поліпшено пошук'), findsOneWidget);
        await tester.tap(find.text('Завантажити'));
        await tester.pumpAndSettle();
        expect(platform.installed, 0);
        expect(find.text('Встановити й перезапустити'), findsOneWidget);
        await tester.tap(find.text('Встановити й перезапустити'));
        await tester.pumpAndSettle();
        expect(platform.installed, 1);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Закрити'));
        await tester.pumpAndSettle();
        await tester.pumpWidget(
          MaterialApp(
            theme: archiveTheme(brightness: brightness),
            home: Scaffold(
              body: ServerSettingsDialog(
                initialUrl: 'http://localhost:8080/',
                updates: c,
                onSave: (_, _) async {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Оновлення'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
