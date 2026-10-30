import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:archive_server/src/updates/github_release_sync.dart';
import 'package:archive_server/src/updates/windows_release_store.dart';
import 'package:archive_shared/windows_release.dart';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:test/test.dart';

class FakeGithub implements GithubReleaseSource {
  Map<String, dynamic>? metadata;
  final data = <int, List<int>>{};
  int checks = 0, downloads = 0;
  Completer<void>? gate;
  bool fail = false;
  @override
  Future<Map<String, dynamic>?> latest(String repository) async {
    checks++;
    if (gate != null) await gate!.future;
    if (fail) throw const SocketException('offline');
    return metadata;
  }

  @override
  Stream<List<int>> asset(String repository, int id) async* {
    downloads++;
    yield data[id]!;
  }
}

void main() {
  final seed = List<int>.generate(32, (i) => i + 2);
  late Directory directory;
  late FakeGithub source;
  late String key;
  late WindowsReleaseStore store;
  late GithubReleaseSync sync;
  var failures = 0;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('archive-github-test-');
    source = FakeGithub();
    store = WindowsReleaseStore(directory);
    failures = 0;
    key = base64Encode(
      (await (await Ed25519().newKeyPairFromSeed(
        seed,
      )).extractPublicKey()).bytes,
    );
    sync = GithubReleaseSync(
      repository: 'owner/repo',
      store: store,
      publicKey: () async => key,
      source: source,
      onFailure: () => failures++,
    );
  });
  tearDown(() async {
    sync.stop();
    await directory.delete(recursive: true);
  });
  Future<WindowsRelease> publish(int build, {bool corrupt = false}) async {
    final bytes = List<int>.generate(600000, (i) => (i + build) % 251);
    final release = WindowsRelease(
      version: '1.0.0',
      build: build,
      sha256: sha256.convert(bytes).toString(),
      size: bytes.length,
    );
    final envelope = utf8.encode(await signWindowsRelease(release, seed));
    source.metadata = {
      'draft': false,
      'prerelease': false,
      'assets': [
        {
          'id': 1,
          'name': 'latest.json',
          'size': envelope.length,
          'state': 'uploaded',
        },
        {
          'id': 2,
          'name': '${release.sha256}.exe',
          'size': bytes.length,
          'state': 'uploaded',
        },
      ],
    };
    source.data[1] = envelope;
    source.data[2] = corrupt ? List.filled(bytes.length, 0) : bytes;
    return release;
  }

  test(
    'verified release is published atomically; next build retains old downloads and duplicate checks are throttled',
    () async {
      final first = await publish(2);
      await sync.refresh(force: true);
      expect(
        (await verifyWindowsRelease((await store.check())!, key)).build,
        2,
      );
      expect(
        (await store.chunk(first.sha256, 0)).lengthInBytes,
        windowsUpdateChunkSize,
      );
      final count = source.downloads;
      await sync.refresh();
      expect(source.checks, 1);
      await sync.refresh(force: true);
      expect(source.downloads, count + 1); // metadata only
      await publish(3);
      await sync.refresh(force: true);
      expect(
        (await verifyWindowsRelease((await store.check())!, key)).build,
        3,
      );
      expect(
        await File('${directory.path}/${first.sha256}.exe').exists(),
        isTrue,
      );
      expect(failures, 0);
    },
  );
  test(
    'offline, corrupt, unsigned and older releases preserve the existing valid release',
    () async {
      await publish(3);
      await sync.refresh(force: true);
      final original = await store.check();
      source.fail = true;
      await sync.refresh(force: true);
      source.fail = false;
      await publish(4, corrupt: true);
      await sync.refresh(force: true);
      expect(await store.check(), original);
      expect(
        await directory.list().where((f) => f.path.endsWith('.part')).toList(),
        isEmpty,
      );
      await publish(4);
      source.data[1] = utf8.encode('{}');
      await sync.refresh(force: true);
      await publish(2);
      await sync.refresh(force: true);
      expect(await store.check(), original);
      expect(failures, 3);
    },
  );
  test(
    'drafts and incomplete releases are not announced; overlapping syncs share one request',
    () async {
      await publish(2);
      source.metadata!['draft'] = true;
      await sync.refresh(force: true);
      expect(await store.check(), isNull);
      source.metadata!['draft'] = false;
      (source.metadata!['assets'] as List).removeLast();
      await sync.refresh(force: true);
      expect(await store.check(), isNull);
      source.gate = Completer<void>();
      final first = sync.refresh(force: true),
          second = sync.refresh(force: true);
      final checks = source.checks;
      source.gate!.complete();
      await first;
      await second;
      expect(source.checks, checks);
    },
  );
}
