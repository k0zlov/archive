import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:archive_shared/windows_release.dart';
import 'package:serverpod/serverpod.dart';
import 'windows_release_store.dart';

/// Only a verified manifest with a published installer can raise the API floor.
class WindowsClientPolicy {
  WindowsClientPolicy({
    required this.store,
    required this.publicKey,
    this.cacheDuration = const Duration(seconds: 5),
  });
  final Duration cacheDuration;
  final WindowsReleaseStore store;
  final Future<String> Function() publicKey;
  String? _envelope;
  WindowsRelease? _release;
  DateTime? _checked;
  Future<void>? _loading;
  Future<void> refresh() {
    if (_loading != null) return _loading!;
    if (_checked != null &&
        DateTime.now().difference(_checked!) < cacheDuration) {
      return Future.value();
    }
    _checked = DateTime.now();
    return _loading = (() async {
      try {
        final raw = await store.check();
        if (raw == null || raw == _envelope) return;
        final next = await verifyWindowsRelease(raw, await publicKey());
        if (_release != null &&
            (next.build < _release!.build ||
                next.minimumSupportedBuild < _release!.minimumSupportedBuild)) {
          return;
        }
        _release = next;
        _envelope = raw;
      } catch (_) {
        // Retain the last verified policy on a corrupt or incomplete publication.
      }
    })().whenComplete(() => _loading = null);
  }

  Future<String?> requiredUpdate(String platform, int build) async {
    if (['macos', 'linux', 'ios', 'android', 'web'].contains(platform)) {
      return null;
    }
    await refresh();
    final minimum = _release?.minimumSupportedBuild ?? 1;
    if (minimum <= 1 || build >= minimum) return null;
    return _envelope;
  }

  Middleware get middleware =>
      (next) => (request) async {
        final path = request.url.path;
        if (request.method == Method.options ||
            path == '/updates/check' ||
            path == '/updates/download' ||
            path == '/v1/websocket' ||
            path == '/' ||
            ['/livez', '/readyz', '/startupz'].contains(path)) {
          return next(request);
        }
        final platform =
            request.headers['x-archive-platform']?.firstOrNull ?? '';
        final build =
            int.tryParse(
              request.headers['x-archive-build']?.firstOrNull ?? '',
            ) ??
            0;
        final envelope = await requiredUpdate(platform, build);
        if (envelope == null) return next(request);
        return Response(
          426,
          body: Body.fromString(
            jsonEncode({'code': 'update_required', 'manifest': envelope}),
            mimeType: MimeType.json,
          ),
        );
      };
}

final windowsClientPolicy = WindowsClientPolicy(
  store: WindowsReleaseStore.configured(),
  publicKey: () => File('config/windows_update_public_key.txt').readAsString(),
);
