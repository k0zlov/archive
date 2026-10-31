import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:archive_shared/windows_release.dart';
import 'package:archive_shared/client_protocol.dart';
import 'package:crypto/crypto.dart';
import 'windows_release_store.dart';

abstract interface class GithubReleaseSource {
  Stream<Map<String, dynamic>> releases(String repository);
  Stream<List<int>> asset(String repository, int id);
}

/// Public GitHub releases only. No GitHub credentials are given to clients.
class PublicGithubReleases implements GithubReleaseSource {
  Stream<List<int>> _get(Uri uri, {required bool binary}) async* {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      for (var redirects = 0; redirects < 5; redirects++) {
        if (uri.scheme != 'https' ||
            uri.userInfo.isNotEmpty ||
            !(uri.host == 'api.github.com' ||
                uri.host == 'github.com' ||
                uri.host.endsWith('.githubusercontent.com'))) {
          throw const FormatException('Unexpected GitHub download host');
        }
        final request = await client
            .getUrl(uri)
            .timeout(const Duration(seconds: 10));
        request.followRedirects = false;
        request.headers.set(
          HttpHeaders.userAgentHeader,
          'Archive-Windows-Updates',
        );
        request.headers.set(
          HttpHeaders.acceptHeader,
          binary ? 'application/octet-stream' : 'application/vnd.github+json',
        );
        final response = await request.close().timeout(
          const Duration(seconds: 15),
        );
        if ([301, 302, 303, 307, 308].contains(response.statusCode)) {
          final location = response.headers.value(HttpHeaders.locationHeader);
          await response.drain<void>();
          if (location == null) throw const FormatException('Missing redirect');
          uri = uri.resolve(location);
          continue;
        }
        if (response.statusCode == 404) throw const _NoGithubRelease();
        if (response.statusCode != 200) {
          throw const HttpException('GitHub release unavailable');
        }
        yield* response.timeout(const Duration(seconds: 60));
        return;
      }
      throw const HttpException('Too many GitHub redirects');
    } finally {
      client.close(force: true);
    }
  }

  @override
  Stream<Map<String, dynamic>> releases(String repository) async* {
    for (var page = 1; ; page++) {
      List<dynamic> items;
      try {
        final bytes = await _collect(
          _get(
            Uri.https('api.github.com', '/repos/$repository/releases', {
              'per_page': '100',
              'page': '$page',
            }),
            binary: false,
          ),
          8 * 1024 * 1024,
        );
        items = jsonDecode(utf8.decode(bytes)) as List;
      } on _NoGithubRelease {
        return;
      }
      for (final item in items) {
        yield Map<String, dynamic>.from(item as Map);
      }
      if (items.length < 100) return;
    }
  }

  @override
  Stream<List<int>> asset(String repository, int id) => _get(
    Uri.https('api.github.com', '/repos/$repository/releases/assets/$id'),
    binary: true,
  );
}

class _NoGithubRelease implements Exception {
  const _NoGithubRelease();
}

Future<List<int>> _collect(Stream<List<int>> stream, int limit) async {
  final bytes = <int>[];
  await for (final part in stream) {
    if (bytes.length + part.length > limit) {
      throw const FormatException('Release metadata too large');
    }
    bytes.addAll(part);
  }
  return bytes;
}

Future<String> _hashFile(String path) async =>
    (await sha256.bind(File(path).openRead()).first).toString();
Future<String> _isolatedHash(String path) => Isolate.run(() => _hashFile(path));

class GithubReleaseSync {
  GithubReleaseSync({
    required this.repository,
    required this.store,
    required this.publicKey,
    required this.source,
    this.onFailure,
    this.protocols = archiveServerProtocols,
  });
  final String repository;
  final List<int> protocols;
  final _manifestCache = <int, String>{};
  final WindowsReleaseStore store;
  final Future<String> Function() publicKey;
  final GithubReleaseSource source;
  final void Function()? onFailure;
  Timer? _timer;
  Future<void>? _running;
  DateTime? _lastAttempt;
  String? _verifiedHash;
  bool _stopped = false;

  void start() {
    if (_timer != null) return;
    unawaited(refresh());
    _timer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => unawaited(refresh()),
    );
  }

  void stop() {
    _stopped = true;
    _timer?.cancel();
  }

  Future<void> refresh({bool force = false}) {
    if (_stopped) return Future.value();
    if (_running != null) return _running!;
    if (!force &&
        _lastAttempt != null &&
        DateTime.now().difference(_lastAttempt!) < const Duration(minutes: 5)) {
      return Future.value();
    }
    _lastAttempt = DateTime.now();
    final work = _sync().catchError((Object _) {
      onFailure?.call();
    });
    _running = work;
    return work.whenComplete(() => _running = null);
  }

  Future<WindowsRelease?> _current(String key, int protocol) async {
    WindowsRelease? current;
    try {
      for (final raw in await store.available()) {
        try {
          final release = await verifyWindowsRelease(raw, key);
          if (release.clientProtocol == protocol &&
              (current == null || release.build > current.build)) {
            current = release;
          }
        } catch (_) {}
      }
    } catch (_) {}
    return current;
  }

  Future<String> _manifest(Map asset, String key) async {
    final id = asset['id'];
    if (id is! int ||
        id < 1 ||
        asset['size'] is! int ||
        (asset['size'] as int) > 32768) {
      throw const FormatException('Invalid manifest asset');
    }
    final file = File('${store.directory.path}/manifests/$id.json');
    var raw = _manifestCache[id];
    if (raw == null && await file.exists() && await file.length() <= 32768) {
      raw = await file.readAsString();
    }
    if (raw != null) {
      try {
        await verifyWindowsRelease(raw, key);
        return raw;
      } catch (_) {}
    }
    raw = utf8.decode(await _collect(source.asset(repository, id), 32768));
    await verifyWindowsRelease(raw, key);
    _manifestCache[id] = raw;
    await file.parent.create(recursive: true);
    await file.writeAsString(raw, flush: true);
    return raw;
  }

  Future<void> _sync() async {
    if (!RegExp(r'^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$').hasMatch(repository)) {
      throw const FormatException('Invalid repository');
    }
    final key = await publicKey();
    final candidates = <({WindowsRelease release, String raw, Map binary})>[];
    await for (final metadata in source.releases(repository)) {
      if (_stopped) return;
      if (metadata['draft'] == true || metadata['prerelease'] == true) continue;
      try {
        final assets = (metadata['assets'] as List).cast<Map>();
        final manifest = assets.where(
          (a) => a['name'] == 'latest.json' && a['state'] == 'uploaded',
        );
        if (manifest.length != 1) continue;
        final raw = await _manifest(manifest.single, key);
        final release = await verifyWindowsRelease(raw, key);
        if (!protocols.contains(release.clientProtocol)) continue;
        final binaries = assets.where(
          (a) =>
              a['name'] == '${release.sha256}.exe' && a['state'] == 'uploaded',
        );
        if (binaries.length != 1 ||
            binaries.single['id'] is! int ||
            binaries.single['size'] != release.size) {
          throw const FormatException('Missing installer asset');
        }
        candidates.add((release: release, raw: raw, binary: binaries.single));
      } catch (_) {
        onFailure?.call();
      }
    }
    candidates.sort((a, b) => b.release.build.compareTo(a.release.build));
    final completed = <int>{};
    for (final candidate in candidates) {
      if (completed.contains(candidate.release.clientProtocol)) continue;
      try {
        await _publish(candidate.release, candidate.raw, candidate.binary, key);
        completed.add(candidate.release.clientProtocol);
      } catch (_) {
        onFailure?.call();
      }
    }
    // Keep the legacy announcement compatible too. Old binaries remain addressable.
    String? selected;
    var build = 0;
    try {
      for (final raw in await store.available()) {
        try {
          final release = await verifyWindowsRelease(raw, key);
          if (protocols.contains(release.clientProtocol) &&
              release.build > build) {
            selected = raw;
            build = release.build;
          }
        } catch (_) {}
      }
    } catch (_) {}
    if (selected != null && !_stopped) {
      final pending = File('${store.directory.path}/latest.github.tmp');
      await pending.writeAsString(selected, flush: true);
      await pending.rename('${store.directory.path}/latest.json');
    }
  }

  Future<void> _publish(
    WindowsRelease release,
    String raw,
    Map binaryAsset,
    String key,
  ) async {
    final current = await _current(key, release.clientProtocol);
    if (current != null &&
        (current.build > release.build ||
            current.minimumSupportedBuild > release.minimumSupportedBuild)) {
      return;
    }
    if (current != null &&
        current.build == release.build &&
        current.sha256 != release.sha256) {
      throw const FormatException('Conflicting release build');
    }
    if (current?.sha256 == release.sha256 && _verifiedHash == release.sha256) {
      return;
    }
    await store.directory.create(recursive: true);
    final binary = File('${store.directory.path}/${release.sha256}.exe');
    final partial = File('${binary.path}.github.part');
    try {
      if (!await binary.exists() ||
          await binary.length() != release.size ||
          await _isolatedHash(binary.path) != release.sha256) {
        final sink = partial.openWrite();
        try {
          var count = 0;
          await for (final part in source.asset(
            repository,
            binaryAsset['id'] as int,
          )) {
            count += part.length;
            if (_stopped || count > release.size) {
              throw const FormatException('Interrupted update download');
            }
            sink.add(part);
            await sink.flush();
          }
          await sink.close();
          if (count != release.size ||
              await _isolatedHash(partial.path) != release.sha256) {
            throw const FormatException('Installer checksum mismatch');
          }
        } catch (_) {
          try {
            await sink.close();
          } catch (_) {}
          rethrow;
        }
        await partial.rename(binary.path);
      }
      if (_stopped) return;
      // A manual publication may have happened while the network request ran.
      final newest = await _current(key, release.clientProtocol);
      if (newest != null &&
          (newest.build > release.build ||
              newest.minimumSupportedBuild > release.minimumSupportedBuild)) {
        return;
      }
      if (newest != null &&
          newest.build == release.build &&
          newest.sha256 != release.sha256) {
        throw const FormatException('Conflicting release build');
      }
      final pending = File(
        '${store.directory.path}/protocol-${release.clientProtocol}.tmp',
      );
      await pending.writeAsString(raw, flush: true);
      await pending.rename(
        '${store.directory.path}/protocol-${release.clientProtocol}.json',
      );
      _verifiedHash = release.sha256;
    } finally {
      if (await partial.exists()) await partial.delete();
    }
  }
}

GithubReleaseSync? windowsGithubSync;
void startWindowsGithubSync() {
  if (Platform.environment['ARCHIVE_GITHUB_UPDATES'] == 'false') return;
  windowsGithubSync ??= GithubReleaseSync(
    repository:
        Platform.environment['ARCHIVE_GITHUB_REPOSITORY'] ?? 'k0zlov/archive',
    store: WindowsReleaseStore.configured(),
    publicKey: () =>
        File('config/windows_update_public_key.txt').readAsString(),
    source: PublicGithubReleases(),
    onFailure: () => stderr.writeln(
      'Windows update sync failed; existing release retained.',
    ),
  );
  windowsGithubSync!.start();
}
