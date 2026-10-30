import 'dart:async';
import 'dart:io';
import 'package:archive_client/archive_client.dart';
import 'package:archive_flutter/data/app_settings_store.dart';
import 'package:archive_flutter/data/app_settings_store_native.dart';
import 'package:archive_flutter/data/server_connection.dart';
import 'package:flutter_test/flutter_test.dart';

class MemorySettings implements AppSettingsStore {
  String? value;
  String? theme;
  @override
  Future<String?> readThemeMode() async => theme;
  @override
  Future<void> writeThemeMode(String value) async {
    if (failWrite) throw const FileSystemException('write refused');
    theme = value;
  }

  bool failWrite = false;
  @override
  Future<String?> readServerUrl() async => value;
  @override
  Future<void> writeServerUrl(String? value) async {
    if (failWrite) throw const FileSystemException('write refused');
    this.value = value;
  }
}

class TestServer implements ConnectedServer {
  TestServer(String url) : client = Client(url);
  @override
  final Client client;
  bool cleared = false, closed = false, failClear = false;
  @override
  Future<void> clearAuthentication() async {
    if (failClear) throw StateError('secure storage unavailable');
    cleared = true;
  }

  @override
  void close() {
    closed = true;
    client.close();
  }
}

class ConnectionFixture {
  final store = MemorySettings();
  final servers = <TestServer>[];
  final modes = <List<bool>>[];
  late final connection = ServerConnection(
    store: store,
    defaultUrl: () async => 'http://localhost:8080',
    openServer: (url, {required freshSession, required migrateLegacy}) async {
      modes.add([freshSession, migrateLegacy]);
      final server = TestServer(url);
      servers.add(server);
      return server;
    },
  );
  void close() {
    for (final server in servers) {
      if (!server.closed) server.close();
    }
    connection.dispose();
  }
}

void main() {
  test(
    'normalizes explicit HTTP(S), paths, IPv6; rejects malformed or credential URLs',
    () {
      expect(
        normalizeServerUrl(' HTTP://EXAMPLE.COM:8080 '),
        'http://example.com:8080/',
      );
      expect(normalizeServerUrl('https://host/api'), 'https://host/api/');
      expect(normalizeServerUrl('http://[::1]:8080/'), 'http://[::1]:8080/');
      for (final invalid in [
        '',
        '192.168.0.1:8080',
        'ftp://host',
        'http://',
        'http://name:password@host',
        'https://host/?token=x',
        'https://host/#x',
        'http://some host:8080',
        r'http://host\path',
        'http://host:0',
        'http://host:65536',
        'http://host:abc',
      ]) {
        expect(
          () => normalizeServerUrl(invalid),
          throwsFormatException,
          reason: invalid,
        );
      }
    },
  );

  test(
    'keeps existing default cache identity and migrates legacy auth only there',
    () async {
      final f = ConnectionFixture();
      addTearDown(f.close);
      await f.connection.initialize();
      expect(f.connection.url, 'http://localhost:8080');
      expect(f.modes.single, [false, true]);
      expect(
        await f.connection.changeServer('http://localhost:8080/'),
        isFalse,
      );
      expect(f.servers, hasLength(1));
      expect(f.servers.single.cleared, isFalse);
    },
  );

  test(
    'switches offline with a fresh session, clears old cache/session, restores saved URL',
    () async {
      final f = ConnectionFixture();
      addTearDown(f.close);
      await f.connection.initialize();
      final previous = f.connection.client;
      var clearedCache = false, notifications = 0;
      f.connection.addListener(() => notifications++);
      await f.connection.changeServer(
        'http://192.0.2.1:8080',
        beforeSwitch: () async {
          expect(f.store.value, 'http://192.0.2.1:8080/');
          clearedCache = true;
        },
      );
      expect(clearedCache, isTrue);
      expect(f.connection.client, isNot(same(previous)));
      expect(f.servers.first.cleared && f.servers.first.closed, isTrue);
      expect(f.modes.last, [true, false]);
      expect(f.connection.generation, 1);
      expect(notifications, 1);
      final restarted = ConnectionFixture();
      addTearDown(restarted.close);
      restarted.store.value = f.store.value;
      await restarted.connection.initialize();
      expect(restarted.connection.url, 'http://192.0.2.1:8080/');
      expect(restarted.modes.single, [false, false]);
    },
  );

  test(
    'disk failure keeps current client, session, URL and cache intact',
    () async {
      final f = ConnectionFixture();
      addTearDown(f.close);
      await f.connection.initialize();
      final previous = f.connection.client;
      f.store.failWrite = true;
      var cacheCleared = false;
      await expectLater(
        f.connection.changeServer(
          'https://other.example',
          beforeSwitch: () async {
            cacheCleared = true;
          },
        ),
        throwsA(isA<FileSystemException>()),
      );
      expect(f.connection.client, same(previous));
      expect(f.connection.generation, 0);
      expect(cacheCleared, isFalse);
      expect(f.servers.first.cleared || f.servers.first.closed, isFalse);
      expect(f.servers.last.closed, isTrue);
      expect(f.connection.switching, isFalse);
    },
  );

  test(
    'secure-storage failure rolls settings back before exposing a new client',
    () async {
      final f = ConnectionFixture();
      addTearDown(f.close);
      await f.connection.initialize();
      f.servers.first.failClear = true;
      await expectLater(
        f.connection.changeServer('https://other.example'),
        throwsStateError,
      );
      expect(f.store.value, isNull);
      expect(f.connection.url, 'http://localhost:8080');
      expect(f.servers.first.closed, isFalse);
      expect(f.servers.last.closed, isTrue);
    },
  );

  test(
    'old late login ignored and active auth write finishes before old session is cleared',
    () async {
      final f = ConnectionFixture();
      addTearDown(f.close);
      await f.connection.initialize();
      final oldClient = f.connection.client;
      final writing = Completer<void>();
      final started = Completer<void>();
      final authWrite = f.connection.updateAuthentication(oldClient, () async {
        started.complete();
        await writing.future;
      });
      await started.future;
      final switching = f.connection.changeServer('https://other.example');
      await Future<void>.delayed(Duration.zero);
      expect(f.servers.first.cleared, isFalse);
      writing.complete();
      await authWrite;
      await switching;
      var lateUpdate = false;
      await f.connection.updateAuthentication(oldClient, () async {
        lateUpdate = true;
      });
      expect(lateUpdate, isFalse);
      expect(f.servers.first.cleared, isTrue);
    },
  );

  test(
    'native setting creates its directory and survives reopening and replacement',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'archive-settings-test-',
      );
      addTearDown(() => root.delete(recursive: true));
      Future<Directory> directory() async =>
          Directory('${root.path}/nested/settings');
      final first = FileAppSettingsStore(directory: directory);
      expect(await first.readServerUrl(), isNull);
      await first.writeServerUrl('http://192.0.2.1:8080/');
      final second = FileAppSettingsStore(directory: directory);
      expect(await second.readServerUrl(), 'http://192.0.2.1:8080/');
      await second.writeServerUrl('https://archive.example/');
      expect(await first.readServerUrl(), 'https://archive.example/');
      expect(
        await File(
          '${(await directory()).path}/archive_settings.json.tmp',
        ).exists(),
        isFalse,
      );
    },
  );
}
