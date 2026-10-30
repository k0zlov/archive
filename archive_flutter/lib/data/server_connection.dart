import 'package:archive_client/archive_client.dart';
import 'package:flutter/foundation.dart';
import 'app_settings_store.dart';

/// URLs are explicit to avoid silently choosing a protocol or API port.
String normalizeServerUrl(String value) {
  final text = value.trim();
  const message =
      'Введіть адресу сервера: http://адреса:порт/ або https://адреса/.';
  final uri = Uri.tryParse(text);
  if (uri == null ||
      !['http', 'https'].contains(uri.scheme.toLowerCase()) ||
      !uri.hasAuthority ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty ||
      uri.hasQuery ||
      uri.hasFragment ||
      RegExp(r'\s|\\').hasMatch(text)) {
    throw const FormatException(message);
  }
  try {
    if (uri.port < 1 || uri.port > 65535) {
      throw const FormatException(message);
    }
  } on FormatException {
    throw const FormatException(message);
  }
  return uri
      .replace(
        scheme: uri.scheme.toLowerCase(),
        host: uri.host.toLowerCase(),
        path: uri.path.endsWith('/') ? uri.path : '${uri.path}/',
      )
      .toString();
}

abstract interface class ConnectedServer {
  Client get client;
  Future<void> clearAuthentication();
  void close();
}

typedef OpenServer =
    Future<ConnectedServer> Function(
      String url, {
      required bool freshSession,
      required bool migrateLegacy,
    });

/// Replaces the complete transport/session together, never just the URL label.
class ServerConnection extends ChangeNotifier {
  ServerConnection({
    required this.store,
    required this.defaultUrl,
    required this.openServer,
  });
  final AppSettingsStore store;
  final Future<String> Function() defaultUrl;
  final OpenServer openServer;
  late ConnectedServer _server;
  late String url;
  String? _savedUrl;
  int generation = 0;
  bool switching = false;
  Future<void> _authWrite = Future.value();
  Client get client => _server.client;

  Future<void> initialize() async {
    _savedUrl = await store.readServerUrl();
    // Keep the default spelling so its existing offline cache is reused.
    url = _savedUrl ?? await defaultUrl();
    normalizeServerUrl(url);
    _server = await openServer(
      url,
      freshSession: false,
      migrateLegacy: _savedUrl == null,
    );
  }

  /// A late response from the old server must never sign into the new one.
  Future<void> updateAuthentication(
    Client source,
    Future<void> Function() update,
  ) async {
    if (switching || !identical(source, client)) return;
    final previous = _authWrite;
    final next = () async {
      await previous.catchError((Object _) {});
      if (switching || !identical(source, client)) return;
      await update();
    }();
    _authWrite = next;
    await next;
  }

  Future<bool> changeServer(
    String value, {
    Future<void> Function()? beforeSwitch,
  }) async {
    final normalized = normalizeServerUrl(value);
    if (switching) throw StateError('Server change already in progress');
    if (normalized == normalizeServerUrl(url)) return false;
    switching = true;
    ConnectedServer? replacement;
    var persisted = false;
    try {
      replacement = await openServer(
        normalized,
        freshSession: true,
        migrateLegacy: false,
      );
      // A storage failure leaves the current connection intact.
      await store.writeServerUrl(normalized);
      persisted = true;
      await beforeSwitch?.call();
      await _authWrite.catchError((Object _) {});
      await _server.clearAuthentication();
      final previous = _server;
      _server = replacement;
      replacement = null;
      url = normalized;
      _savedUrl = normalized;
      generation++;
      previous.close();
      notifyListeners();
      return true;
    } catch (_) {
      if (persisted) await store.writeServerUrl(_savedUrl);
      rethrow;
    } finally {
      replacement?.close();
      switching = false;
    }
  }
}
