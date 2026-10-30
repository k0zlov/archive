import 'dart:convert';
import 'package:archive_client/archive_client.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'data/app_settings_store.dart';
import 'data/server_connection.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'data/updates/archive_api_client.dart';
import 'data/updates/client_access.dart';
import 'data/updates/policy_store.dart';

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
  final target = kIsWeb ? 'web' : defaultTargetPlatform.name.toLowerCase();
  var build = 0;
  if (!kIsWeb) {
    try {
      build = int.tryParse((await PackageInfo.fromPlatform()).buildNumber) ?? 0;
    } catch (_) {}
  }
  final access = ClientAccess(
    platform: target,
    build: build,
    trustedKey: target == 'windows'
        ? await rootBundle.loadString('assets/windows_update_public_key.txt')
        : '',
  );
  if (target == 'windows') {
    final policies = createUpdatePolicyStore();
    final canonical = normalizeServerUrl(url);
    access.remember = (raw) => policies.write(canonical, raw);
    try {
      final cached = await policies.read(canonical);
      if (cached != null) await access.accept(cached, persist: false);
    } catch (_) {}
    access.checked = false;
  }
  final monitor = FlutterConnectivityMonitor();
  final transport = ArchiveApiClient(url, access)
    ..connectivityMonitor = monitor
    ..authSessionManager = FlutterAuthSessionManager(storage: storage);
  final server = _ConnectedServer(transport, monitor);
  try {
    if (freshSession || target == 'windows') {
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
