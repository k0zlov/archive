import 'dart:convert';
import 'dart:io';
import 'package:archive_server/src/updates/windows_client_policy.dart';
import 'package:archive_server/src/updates/windows_release_store.dart';
import 'package:archive_shared/windows_release.dart';
import 'package:cryptography/cryptography.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  final seed = List<int>.filled(32, 7);
  test(
    'only a signed published installer raises the compatibility floor; invalid publications retain the previous floor',
    () async {
      final dir = await Directory.systemTemp.createTemp(
        'archive-client-policy',
      );
      addTearDown(() => dir.delete(recursive: true));
      final key = base64Encode(
        (await (await Ed25519().newKeyPairFromSeed(
          seed,
        )).extractPublicKey()).bytes,
      );
      final release = WindowsRelease(
        version: '1.0.2',
        build: 10,
        minimumSupportedBuild: 8,
        sha256: 'a' * 64,
        size: 2,
      );
      final manifest = File('${dir.path}/latest.json');
      await manifest.writeAsString(await signWindowsRelease(release, seed));
      final policy = WindowsClientPolicy(
        store: WindowsReleaseStore(dir),
        publicKey: () async => key,
        cacheDuration: Duration.zero,
      );
      expect(
        await policy.requiredUpdate('windows', 2),
        isNull,
      ); // Not published without the binary.
      await File('${dir.path}/${release.sha256}.exe').writeAsBytes([77, 90]);
      final required = await policy.requiredUpdate('windows', 7);
      expect(required, isNotNull);
      expect(
        (await verifyWindowsRelease(required!, key)).minimumSupportedBuild,
        8,
      );
      expect(await policy.requiredUpdate('windows', 8), isNull);
      expect(await policy.requiredUpdate('macos', 1), isNull);
      // Exercise the same middleware mounted in front of real RPC handlers.
      final server = RelicServer(
        () => IOAdapter.bind(InternetAddress.loopbackIPv4, port: 0),
      );
      final client = HttpClient();
      addTearDown(() async {
        client.close(force: true);
        await server.close(force: true);
      });
      await server.mountAndStart(
        policy.middleware((_) => Response.ok(body: Body.fromString('handled'))),
      );
      Future<(int, String)> request(
        String path, {
        String platform = 'windows',
        int build = 7,
      }) async {
        final request = await client.postUrl(
          Uri.parse('http://127.0.0.1:${server.port}$path'),
        );
        request.headers.set('x-archive-platform', platform);
        request.headers.set('x-archive-build', '$build');
        final response = await request.close();
        return (response.statusCode, await utf8.decoder.bind(response).join());
      }

      final blocked = await request('/archive/saveRecord');
      expect(blocked.$1, 426);
      expect((jsonDecode(blocked.$2) as Map)['manifest'], required);
      expect((await request('/updates/check')).$1, 200);
      expect((await request('/updates/download')).$1, 200);
      expect((await request('/archive/records', build: 8)).$1, 200);
      expect(
        (await request('/archive/records', platform: 'macos', build: 1)).$1,
        200,
      );
      expect(
        await policy.requiredUpdate('', 0),
        isNotNull,
      ); // Older clients carry no build metadata.
      await manifest.writeAsString('{}');
      expect(await policy.requiredUpdate('windows', 7), required);
      await manifest.writeAsString(
        await signWindowsRelease(
          WindowsRelease(
            version: '1.0.3',
            build: 11,
            sha256: 'b' * 64,
            size: 2,
          ),
          seed,
        ),
      );
      await File('${dir.path}/${'b' * 64}.exe').writeAsBytes([77, 90]);
      expect(
        await policy.requiredUpdate('windows', 7),
        required,
      ); // Never lower the minimum.
    },
  );
}
