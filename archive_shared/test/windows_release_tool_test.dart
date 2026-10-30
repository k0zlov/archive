import 'dart:io';
import 'package:archive_shared/windows_release.dart';
import 'package:test/test.dart';

void main() {
  test(
    'release command creates keys once, signs versioned installers and preserves prior downloads',
    () async {
      final script = File('tool/windows_release.dart').absolute.path;
      final packages = File('../.dart_tool/package_config.json').absolute.path;
      final root = await Directory.systemTemp.createTemp(
        'archive-release-tool-',
      );
      addTearDown(() => root.delete(recursive: true));
      final working = await Directory('${root.path}/archive_shared').create();
      final private = '${root.path}/keys/test.key';
      final public =
          '${root.path}/archive_flutter/assets/windows_update_public_key.txt';
      Future<ProcessResult> run(List<String> args) => Process.run(
        Platform.resolvedExecutable,
        ['--packages=$packages', script, ...args],
        workingDirectory: working.path,
      );
      expect((await run(['keygen', private, public])).exitCode, 0);
      final before = await File(public).readAsString();
      expect((await run(['keygen', private, public])).exitCode, 1);
      expect(await File(public).readAsString(), before);
      final output = '${root.path}/output';
      final first = File('${root.path}/Archive-Setup-1.0.0-1-x64.exe');
      await first.writeAsBytes([0x4d, 0x5a, 1, 2, 3]);
      expect(
        (await run([
          'publish',
          first.path,
          '1.0.0',
          '1',
          private,
          output,
        ])).exitCode,
        0,
      );
      final manifest = File('$output/latest.json');
      final release = await verifyWindowsRelease(
        await manifest.readAsString(),
        before,
      );
      expect(await File('$output/${release.sha256}.exe').readAsBytes(), [
        0x4d,
        0x5a,
        1,
        2,
        3,
      ]);
      // A changed installer with the same build cannot silently replace a release.
      await first.writeAsBytes([0x4d, 0x5a, 9]);
      expect(
        (await run([
          'publish',
          first.path,
          '1.0.0',
          '1',
          private,
          output,
        ])).exitCode,
        1,
      );
      final second = File('${root.path}/Archive-Setup-1.0.1-2-x64.exe');
      await second.writeAsBytes([0x4d, 0x5a, 5, 6]);
      expect(
        (await run([
          'publish',
          second.path,
          '1.0.1',
          '2',
          private,
          output,
        ])).exitCode,
        0,
      );
      expect(
        (await verifyWindowsRelease(
          await manifest.readAsString(),
          before,
        )).build,
        2,
      );
      expect(await File('$output/${release.sha256}.exe').exists(), isTrue);
    },
  );
}
