import 'dart:convert';
import 'package:archive_shared/windows_release.dart';
import 'package:cryptography/cryptography.dart';
import 'package:test/test.dart';

void main() {
  final seed = List<int>.generate(32, (i) => i);
  late String key;
  setUp(() async {
    key = base64Encode(
      (await (await Ed25519().newKeyPairFromSeed(
        seed,
      )).extractPublicKey()).bytes,
    );
  });
  WindowsRelease release() => WindowsRelease(
    version: '1.0.1',
    build: 2,
    sha256: 'a' * 64,
    size: 300001,
    notes: 'Виправлення',
  );
  test(
    'signed metadata round-trips; wrong keys and modified fields fail closed',
    () async {
      final signed = await signWindowsRelease(release(), seed);
      final verified = await verifyWindowsRelease(signed, key);
      expect(verified.toJson(), release().toJson());
      await expectLater(
        verifyWindowsRelease(signed, base64Encode(List.filled(32, 1))),
        throwsFormatException,
      );
      final envelope = jsonDecode(signed) as Map<String, dynamic>;
      final payload =
          jsonDecode(utf8.decode(base64Decode(envelope['payload'] as String)))
              as Map;
      payload['build'] = 999;
      envelope['payload'] = base64Encode(utf8.encode(jsonEncode(payload)));
      await expectLater(
        verifyWindowsRelease(jsonEncode(envelope), key),
        throwsFormatException,
      );
    },
  );
  test(
    'product, architecture, offsets in versions and malformed envelopes rejected',
    () async {
      for (final change in [
        {'product': 'other'},
        {'architecture': 'arm64'},
        {'version': '../1'},
        {'build': 0},
        {'minimumSupportedBuild': 0},
        {'minimumSupportedBuild': 3},
        {'minimumSupportedBuild': '2'},
        {'size': -1},
        {'sha256': '../file'},
        {'notes': 'a' * 8001},
      ]) {
        expect(
          () => WindowsRelease.fromJson({...release().toJson(), ...change}),
          throwsFormatException,
        );
      }
      for (final bad in [
        '',
        '{}',
        'x' * 32769,
        '{"format":2}',
        '{"signature":"???"}',
      ]) {
        await expectLater(
          verifyWindowsRelease(bad, key),
          throwsFormatException,
        );
      }
    },
  );
  test(
    'old manifests remain compatible and the minimum is covered by the signature',
    () async {
      final legacy = release().toJson()..remove('minimumSupportedBuild');
      expect(WindowsRelease.fromJson(legacy).minimumSupportedBuild, 1);
      final mandatory = WindowsRelease(
        version: '1.0.1',
        build: 2,
        minimumSupportedBuild: 2,
        sha256: 'a' * 64,
        size: 10,
      );
      final signed = await signWindowsRelease(mandatory, seed);
      expect(
        (await verifyWindowsRelease(signed, key)).minimumSupportedBuild,
        2,
      );
      final envelope = jsonDecode(signed) as Map;
      final payload =
          jsonDecode(utf8.decode(base64Decode(envelope['payload'] as String)))
              as Map;
      payload['minimumSupportedBuild'] = 1;
      envelope['payload'] = base64Encode(utf8.encode(jsonEncode(payload)));
      await expectLater(
        verifyWindowsRelease(jsonEncode(envelope), key),
        throwsFormatException,
      );
    },
  );
}
