import 'dart:convert';
import 'package:archive_client/archive_client.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'data/app_settings_store.dart';
import 'data/server_connection.dart';

final serverConnection = ServerConnection(
  store: appSettingsStore,
  defaultUrl: getServerUrl,
  openServer: _openServer,
);
Client get client => serverConnection.client;
Future<String> get serverUrl async => serverConnection.url;
Future<void> initializeClient() => serverConnection.initialize();

Future<ConnectedServer> _openServer(
  String url, {
  required bool freshSession,
  required bool migrateLegacy,
}) async {
  final secureStorage = !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS
      ? const FlutterSecureStorage(
          mOptions: MacOsOptions(
            usesDataProtectionKeychain: false,
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        )
      : const FlutterSecureStorage();
  final key = sha256.convert(utf8.encode(normalizeServerUrl(url))).toString();
  final storage = SecureClientAuthSuccessStorage(
    secureStorage: secureStorage,
    authSuccessStorageKey: 'archive.auth.$key',
  );
  if (freshSession) {
    await storage.set(null);
  } else if (migrateLegacy) {
    final legacy = SecureClientAuthSuccessStorage(secureStorage: secureStorage);
    final previous = await legacy.get();
    if (previous != null) {
      if (await storage.get() == null) await storage.set(previous);
      await legacy.set(null);
    }
  }
  final monitor = FlutterConnectivityMonitor();
  final transport = Client(url)
    ..connectivityMonitor = monitor
    ..authSessionManager = FlutterAuthSessionManager(storage: storage);
  final server = _ConnectedServer(transport, monitor);
  try {
    if (freshSession) {
      await transport.auth.restore();
    } else {
      await transport.auth.initialize();
    }
    return server;
  } catch (_) {
    server.close();
    rethrow;
  }
}

class _ConnectedServer implements ConnectedServer {
  _ConnectedServer(this.client, this.monitor);
  @override
  final Client client;
  final FlutterConnectivityMonitor monitor;
  @override
  Future<void> clearAuthentication() => client.auth.updateSignedInUser(null);
  @override
  void close() {
    client.connectivityMonitor = null;
    monitor.dispose();
    client.close();
  }
}
