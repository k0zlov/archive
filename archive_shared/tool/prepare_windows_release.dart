import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:archive_shared/windows_release.dart';
import 'package:archive_shared/client_protocol.dart';

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
  var minimum = 1;
  final history = <File>[];
  if (args[2].isNotEmpty && args[2] != '-') {
    if (await Directory(args[2]).exists()) {
      await for (final entity in Directory(args[2]).list(recursive: true)) {
        if (entity is File && entity.path.endsWith('latest.json'))
          history.add(entity);
      }
    } else {
      history.add(File(args[2]));
    }
  }
  for (final file in history) {
    final release = await verifyWindowsRelease(await file.readAsString(), key);
    if (previous == null || release.build > previous.build) previous = release;
    if (release.clientProtocol == archiveClientProtocol &&
        release.minimumSupportedBuild > minimum)
      minimum = release.minimumSupportedBuild;
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
      'minimumSupportedBuild':
          Platform.environment['ARCHIVE_MANDATORY_UPDATE'] == 'true'
          ? build
          : minimum,
      'clientProtocol': archiveClientProtocol,
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
