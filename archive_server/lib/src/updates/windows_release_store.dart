import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:archive_shared/windows_release.dart';
import 'package:archive_shared/client_protocol.dart';

/// Public, immutable application binaries only. Never place archive data here.
class WindowsReleaseStore {
  WindowsReleaseStore(this.directory);
  final Directory directory;
  factory WindowsReleaseStore.configured() => WindowsReleaseStore(
    Directory(
      Platform.environment['ARCHIVE_WINDOWS_RELEASE_DIR'] ??
          'updates/windows/x64',
    ),
  );

  Future<List<String>> available() async {
    if (!await directory.exists()) return [];
    final result = <String>[];
    var invalid = false;
    await for (final entity in directory.list()) {
      final name = entity.uri.pathSegments.last;
      if (entity is! File ||
          (name != 'latest.json' &&
              !RegExp(r'^protocol-\d+\.json$').hasMatch(name))) {
        continue;
      }
      try {
        if (await entity.length() > 32768) throw const FormatException();
        final envelope = await entity.readAsString();
        final release = decodeWindowsRelease(envelope);
        final binary = File('${directory.path}/${release.sha256}.exe');
        if (!await binary.exists() || await binary.length() != release.size) {
          throw const FormatException();
        }
        result.add(envelope);
      } catch (_) {
        invalid = true;
      }
    }
    if (result.isEmpty && invalid) {
      throw const FormatException('Incomplete release publication');
    }
    return result;
  }

  Future<String?> check({List<int> protocols = archiveServerProtocols}) async {
    String? selected;
    var build = 0;
    for (final raw in await available()) {
      final release = decodeWindowsRelease(raw);
      if (protocols.contains(release.clientProtocol) && release.build > build) {
        selected = raw;
        build = release.build;
      }
    }
    return selected;
  }

  Future<ByteData> chunk(String hash, int offset) async {
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(hash) ||
        offset < 0 ||
        offset % windowsUpdateChunkSize != 0) {
      throw const FormatException('Invalid update request');
    }
    final file = File('${directory.path}/$hash.exe');
    final length = await file.length();
    if (offset >= length) throw const FormatException('Invalid update offset');
    final reader = await file.open();
    try {
      await reader.setPosition(offset);
      final bytes = await reader.read(
        min(windowsUpdateChunkSize, length - offset),
      );
      return ByteData.sublistView(bytes);
    } finally {
      await reader.close();
    }
  }
}
