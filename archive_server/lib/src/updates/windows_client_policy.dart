import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:archive_shared/windows_release.dart';
import 'package:archive_shared/client_protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'windows_release_store.dart';

/// A verified, complete, compatible publication is the only source of a floor.
class WindowsClientPolicy {
  WindowsClientPolicy({
    required this.store,
    required this.publicKey,
    this.protocols = archiveServerProtocols,
    this.cacheDuration = const Duration(seconds: 5),
  });
  final List<int> protocols;
  final Duration cacheDuration;
  final WindowsReleaseStore store;
  final Future<String> Function() publicKey;
  final _releases = <int, WindowsRelease>{};
  final _envelopes = <int, String>{};
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
        final key = await publicKey();
        for (final raw in await store.available()) {
          try {
            final next = await verifyWindowsRelease(raw, key);
            if (!protocols.contains(next.clientProtocol)) continue;
            final previous = _releases[next.clientProtocol];
            if (previous != null &&
                (next.build < previous.build ||
                    next.minimumSupportedBuild <
                        previous.minimumSupportedBuild ||
                    (next.build == previous.build &&
                        next.sha256 != previous.sha256))) {
              continue;
            }
            _releases[next.clientProtocol] = next;
            _envelopes[next.clientProtocol] = raw;
          } catch (_) {
            /* An invalid candidate cannot hide valid older releases. */
          }
        }
      } catch (_) {
        /* Retain the last verified, complete publication. */
      }
    })().whenComplete(() => _loading = null);
  }

  WindowsRelease? get _latest {
    WindowsRelease? latest;
    for (final release in _releases.values) {
      if (latest == null || release.build > latest.build) latest = release;
    }
    return latest;
  }

  Future<String?> check() async {
    await refresh();
    final latest = _latest;
    return latest == null ? null : _envelopes[latest.clientProtocol];
  }

  Future<UpdateCompatibility> compatibility() async {
    final selected = await check();
    return UpdateCompatibility(
      protocols: protocols,
      manifest: selected,
      policyManifests: _envelopes.values
          .where((raw) => raw != selected)
          .toList(),
    );
  }

  Future<String?> requiredUpdate(
    String platform,
    int build, {
    int protocol = 1,
  }) async {
    if (['macos', 'linux', 'ios', 'android', 'web'].contains(platform)) {
      return null;
    }
    await refresh();
    final ownMinimum = _releases[protocol]?.minimumSupportedBuild ?? 1;
    final selectedMinimum = _latest?.minimumSupportedBuild ?? 1;
    final minimum = ownMinimum > selectedMinimum ? ownMinimum : selectedMinimum;
    if (minimum <= 1 || build >= minimum) return null;
    final release = _latest;
    return release == null ? null : _envelopes[release.clientProtocol];
  }

  Middleware get middleware =>
      (next) => (request) async {
        final path = request.url.path;
        // Stable public HTTP bootstrap bypasses auth and all archive compatibility gates.
        if (path == '/$archiveUpdateCheckPath' &&
            request.method == Method.get) {
          return Response.ok(
            headers: Headers.build((h) {
              h['cache-control'] = ['no-store'];
            }),
            body: Body.fromString(
              jsonEncode((await compatibility()).toJson()),
              mimeType: MimeType.json,
            ),
          );
        }
        final download = RegExp(
          '^/$archiveUpdateDownloadPath/([a-f0-9]{64})/([0-9]+)\$',
        ).firstMatch(path);
        if (download != null && request.method == Method.get) {
          try {
            final chunk = await store.chunk(
              download[1]!,
              int.parse(download[2]!),
            );
            return Response.ok(
              body: Body.fromData(
                chunk.buffer.asUint8List(
                  chunk.offsetInBytes,
                  chunk.lengthInBytes,
                ),
              ),
            );
          } catch (_) {
            return Response.notFound();
          }
        }
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
        final protocol =
            int.tryParse(
              request.headers['x-archive-protocol']?.firstOrNull ?? '',
            ) ??
            1;
        final manifest = await requiredUpdate(
          platform,
          build,
          protocol: protocol,
        );
        if (protocols.contains(protocol) && manifest == null) {
          return next(request);
        }
        final info = await compatibility();
        return Response(
          426,
          headers: Headers.build((h) {
            h['cache-control'] = ['no-store'];
          }),
          body: Body.fromString(
            jsonEncode({
              ...info.toJson(),
              'code': protocols.contains(protocol)
                  ? 'update_required'
                  : 'protocol_unsupported',
              'manifest': ?manifest,
            }),
            mimeType: MimeType.json,
          ),
        );
      };
}

final windowsClientPolicy = WindowsClientPolicy(
  store: WindowsReleaseStore.configured(),
  publicKey: () => File('config/windows_update_public_key.txt').readAsString(),
);
