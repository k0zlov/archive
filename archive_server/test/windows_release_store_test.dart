import 'dart:io';
import 'package:archive_shared/windows_release.dart';
import 'package:archive_server/src/updates/windows_release_store.dart';
import 'package:crypto/crypto.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late WindowsReleaseStore store;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('archive-update-server-');
    store = WindowsReleaseStore(directory);
  });
  tearDown(() => directory.delete(recursive: true));
  test(
    'empty publication returns no update; old installers stay downloadable after metadata changes',
    () async {
      expect(await store.check(), isNull);
      final bytes = List<int>.generate(
        windowsUpdateChunkSize + 17,
        (i) => i % 251,
      );
      final hash = sha256.convert(bytes).toString();
      await File('${directory.path}/$hash.exe').writeAsBytes(bytes);
      final release = WindowsRelease(
        version: '1.0.1',
        build: 2,
        sha256: hash,
        size: bytes.length,
      );
      final signed = await signWindowsRelease(release, List.filled(32, 1));
      final metadata = File('${directory.path}/latest.json');
      await metadata.writeAsString(signed);
      expect(await store.check(), signed);
      final first = await store.chunk(hash, 0),
          last = await store.chunk(hash, windowsUpdateChunkSize);
      expect(first.lengthInBytes, windowsUpdateChunkSize);
      expect(
        last.buffer.asUint8List(last.offsetInBytes, last.lengthInBytes),
        bytes.sublist(windowsUpdateChunkSize),
      );
      await metadata.delete();
      expect(await store.check(), isNull);
      expect(
        (await store.chunk(hash, 0)).lengthInBytes,
        windowsUpdateChunkSize,
      );
    },
  );
  test(
    'path traversal, invalid offsets and incomplete publications are rejected',
    () async {
      await expectLater(store.chunk('../secret', 0), throwsFormatException);
      await expectLater(store.chunk('a' * 64, -1), throwsFormatException);
      await expectLater(store.chunk('a' * 64, 1), throwsFormatException);
      final release = WindowsRelease(
        version: '1.0.1',
        build: 2,
        sha256: 'a' * 64,
        size: 5,
      );
      await File(
        '${directory.path}/latest.json',
      ).writeAsString(await signWindowsRelease(release, List.filled(32, 1)));
      await expectLater(store.check(), throwsFormatException);
    },
  );
}
