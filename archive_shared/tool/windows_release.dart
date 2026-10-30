import 'dart:convert';
import 'dart:io';
import 'package:archive_shared/windows_release.dart';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';

Future<void> main(List<String> args) async {
  try {
    if (args.length == 3 && args.first == 'keygen') {
      final privateFile = File(args[1]), publicFile = File(args[2]);
      if (await privateFile.exists() || await publicFile.exists()) {
        throw StateError('Refusing to overwrite existing signing keys.');
      }
      final pair = await Ed25519().newKeyPair();
      final seed = await pair.extractPrivateKeyBytes();
      final public = await pair.extractPublicKey();
      await privateFile.parent.create(recursive: true);
      // Restrict the enclosing directory on Unix; on Windows use a private user directory.
      if (!Platform.isWindows) {
        final result = await Process.run('chmod', [
          '700',
          privateFile.parent.path,
        ]);
        if (result.exitCode != 0)
          throw StateError('Cannot protect signing key directory.');
      }
      await privateFile.writeAsString('${base64Encode(seed)}\n', flush: true);
      if (!Platform.isWindows)
        await Process.run('chmod', ['600', privateFile.path]);
      await publicFile.parent.create(recursive: true);
      await publicFile.writeAsString(
        '${base64Encode(public.bytes)}\n',
        flush: true,
      );
      stdout.writeln(
        'Signing key created. Keep the private file backed up and out of source control.',
      );
      return;
    }
    // publish <installer> <version> <build> <private-key> <output-dir> [notes-file|-] [minimum-supported-build]
    if (args.length < 6 || args.length > 8 || args.first != 'publish') {
      throw ArgumentError(
        'keygen <private-key> <public-key> OR publish <installer> <version> <build> <private-key> <output-dir> [notes-file] [minimum-supported-build]',
      );
    }
    final installer = File(args[1]);
    if (installer.uri.pathSegments.last !=
        'Archive-Setup-${args[2]}-${args[3]}-x64.exe') {
      throw StateError(
        'Installer filename must match the supplied version and build.',
      );
    }
    final header = await installer.open();
    try {
      final magic = await header.read(2);
      if (magic.length != 2 || magic[0] != 0x4d || magic[1] != 0x5a) {
        throw StateError('Expected a Windows executable installer.');
      }
    } finally {
      await header.close();
    }
    final digest = (await sha256.bind(installer.openRead()).first).toString();
    final release = WindowsRelease(
      version: args[2],
      build: int.parse(args[3]),
      sha256: digest,
      size: await installer.length(),
      notes: args.length >= 7 && args[6].isNotEmpty && args[6] != '-'
          ? await File(args[6]).readAsString()
          : '',
      minimumSupportedBuild: args.length == 8 ? int.parse(args[7]) : 1,
    );
    final seed = base64Decode((await File(args[4]).readAsString()).trim());
    final envelope = await signWindowsRelease(release, seed);
    final expectedPublic = (await Ed25519().newKeyPairFromSeed(
      seed,
    )).extractPublicKey();
    final asset = File(
      '../archive_flutter/assets/windows_update_public_key.txt',
    );
    if (!await asset.exists() ||
        (await asset.readAsString()).trim() !=
            base64Encode((await expectedPublic).bytes)) {
      throw StateError(
        'Signing key does not match the public key embedded in the client.',
      );
    }
    final output = Directory(args[5]);
    await output.create(recursive: true);
    final existingManifest = File('${output.path}/latest.json');
    if (await existingManifest.exists()) {
      final previous = decodeWindowsRelease(
        await existingManifest.readAsString(),
      );
      if (release.minimumSupportedBuild < previous.minimumSupportedBuild) {
        throw StateError('Minimum supported build cannot decrease.');
      }
      if (release.build < previous.build ||
          (release.build == previous.build &&
              release.sha256 != previous.sha256)) {
        throw StateError(
          'Increase the build number before publishing another installer.',
        );
      }
    }
    final binary = File('${output.path}/$digest.exe');
    if (await binary.exists()) {
      if ((await sha256.bind(binary.openRead()).first).toString() != digest)
        throw StateError('Existing release file is corrupt.');
    } else {
      await installer.copy(binary.path);
    }
    // Publish metadata last. Keep old content-addressed installers for in-flight downloads.
    final manifest = File('${output.path}/latest.json');
    final temporary = File('${manifest.path}.tmp');
    await temporary.writeAsString(envelope, flush: true);
    await temporary.rename(manifest.path);
    stdout.writeln(
      'Release ${release.version}+${release.build} prepared in ${output.path}.',
    );
  } catch (error) {
    // Do not print supplied arguments or private key contents.
    stderr.writeln(
      error is ArgumentError
          ? error.message
          : 'Release preparation failed. Check paths, version and signing key.',
    );
    exitCode = 1;
  }
}
