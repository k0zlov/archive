import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:archive_shared/windows_release.dart';

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

  Future<String?> check() async {
    final file = File('${directory.path}/latest.json');
    if (!await file.exists()) return null;
    if (await file.length() > 32768) {
      throw const FormatException('Invalid release metadata');
    }
    final envelope = await file.readAsString();
    final release = decodeWindowsRelease(envelope);
    final binary = File('${directory.path}/${release.sha256}.exe');
    if (!await binary.exists() || await binary.length() != release.size) {
      throw const FormatException('Incomplete release publication');
    }
    return envelope;
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
