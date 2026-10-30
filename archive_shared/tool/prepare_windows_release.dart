import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:archive_shared/windows_release.dart';

/// Called only inside CI. Version changes stay in the build checkout.
Future<void> main(List<String> args) async {
  if (args.length != 4)
    throw ArgumentError('root output previous-manifest requested-version');
  final root = Directory(args[0]);
  final pubspec = File('${root.path}/archive_flutter/pubspec.yaml');
  final original = await pubspec.readAsString();
  final pattern = RegExp(
    r'^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$',
    multiLine: true,
  );
  final match = pattern.firstMatch(original);
  if (match == null)
    throw const FormatException('Version must include a build number.');
  final requested = args[3].trim();
  if (requested.isNotEmpty &&
      requested != '-' &&
      !RegExp(r'^\d+\.\d+\.\d+$').hasMatch(requested)) {
    throw const FormatException('Use a version such as 1.0.1.');
  }
  final key = (await File(
    '${root.path}/archive_flutter/assets/windows_update_public_key.txt',
  ).readAsString()).trim();
  if ((await File(
        '${root.path}/archive_server/config/windows_update_public_key.txt',
      ).readAsString()).trim() !=
      key) {
    throw StateError('Client and server update public keys differ.');
  }
  WindowsRelease? previous;
  if (args[2].isNotEmpty && args[2] != '-') {
    previous = await verifyWindowsRelease(
      await File(args[2]).readAsString(),
      key,
    );
  }
  final sourceVersion = match.group(1)!;
  final String version;
  if (requested.isNotEmpty && requested != '-') {
    version = requested;
    if (previous != null && _compareVersions(version, previous.version) < 0) {
      throw const FormatException(
        'A stable release version cannot go backwards.',
      );
    }
  } else if (previous != null &&
      _compareVersions(sourceVersion, previous.version) > 0) {
    version = sourceVersion;
  } else {
    final parts = (previous?.version ?? sourceVersion)
        .split('.')
        .map(int.parse)
        .toList();
    parts[2]++;
    version = parts.join('.');
  }
  final previousBuild = previous?.build ?? 0;
  final build = [
    int.parse(match.group(2)!) + 1,
    previousBuild + 1,
    int.tryParse(Platform.environment['GITHUB_RUN_NUMBER'] ?? '') ?? 1,
  ].reduce(max);
  if (build > 65535 ||
      version.split('.').any((part) => int.parse(part) > 65535)) {
    throw const FormatException('Windows version components must be 0..65535.');
  }
  await pubspec.writeAsString(
    original.replaceFirst(pattern, 'version: $version+$build\n'),
  );
  await File(args[1]).writeAsString(
    jsonEncode({
      'version': version,
      'build': build,
      'tag': 'windows-$version-b$build',
    }),
  );
}

int _compareVersions(String a, String b) {
  final left = a.split('.').map(int.parse).toList();
  final right = b.split('.').map(int.parse).toList();
  for (var i = 0; i < 3; i++) {
    if (left[i] != right[i]) return left[i].compareTo(right[i]);
  }
  return 0;
}
