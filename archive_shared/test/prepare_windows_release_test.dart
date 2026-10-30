import 'dart:convert';
import 'dart:io';
import 'package:archive_shared/windows_release.dart';
import 'package:cryptography/cryptography.dart';
import 'package:test/test.dart';

void main() {
  test(
    'CI chooses a newer build from signed metadata without requiring a source version edit',
    () async {
      final script = File('tool/prepare_windows_release.dart').absolute.path;
      final packages = File('../.dart_tool/package_config.json').absolute.path;
      final root = await Directory.systemTemp.createTemp('archive-ci-version-');
      addTearDown(() => root.delete(recursive: true));
      final seed = List<int>.filled(32, 3);
      final key = base64Encode(
        (await (await Ed25519().newKeyPairFromSeed(
          seed,
        )).extractPublicKey()).bytes,
      );
      for (final path in [
        'archive_flutter/assets/windows_update_public_key.txt',
        'archive_server/config/windows_update_public_key.txt',
      ]) {
        final file = File('${root.path}/$path');
        await file.parent.create(recursive: true);
        await file.writeAsString(key);
      }
      final pubspec = File('${root.path}/archive_flutter/pubspec.yaml');
      await pubspec.writeAsString(
        'name: archive_flutter\nversion: 1.0.0+1\nenvironment:\n  sdk: ^3.12.2\n',
      );
      final previous = File('${root.path}/latest.json');
      await previous.writeAsString(
        await signWindowsRelease(
          WindowsRelease(
            version: '1.0.0',
            build: 8,
            sha256: 'a' * 64,
            size: 10,
          ),
          seed,
        ),
      );
      final output = '${root.path}/result.json';
      Future<ProcessResult> run(String old, String version) => Process.run(
        Platform.resolvedExecutable,
        ['--packages=$packages', script, root.path, output, old, version],
        environment: {'GITHUB_RUN_NUMBER': '1'},
      );
      expect((await run(previous.path, '1.0.1')).exitCode, 0);
      expect(jsonDecode(await File(output).readAsString()), {
        'version': '1.0.1',
        'build': 9,
        'tag': 'windows-1.0.1-b9',
      });
      expect(await pubspec.readAsString(), contains('version: 1.0.1+9'));
      expect((await run('-', '-')).exitCode, 0);
      expect(
        (jsonDecode(await File(output).readAsString()) as Map)['build'],
        10,
      );
      expect(
        (jsonDecode(await File(output).readAsString()) as Map)['version'],
        '1.0.2',
      );
      await pubspec.writeAsString('name: archive_flutter\nversion: 1.0.0+1\n');
      expect((await run(previous.path, '-')).exitCode, 0);
      expect(
        (jsonDecode(await File(output).readAsString()) as Map)['version'],
        '1.0.1',
      );
      expect((await run(previous.path, '0.9.0')).exitCode, isNot(0));
      expect((await run('-', r'$(bad)')).exitCode, isNot(0));
      await previous.writeAsString('{}');
      expect((await run(previous.path, '-')).exitCode, isNot(0));
    },
  );
}
