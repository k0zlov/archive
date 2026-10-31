import 'dart:convert';
import 'dart:io';
import 'package:archive_server/src/updates/windows_client_policy.dart';
import 'package:archive_server/src/updates/windows_release_store.dart';
import 'package:archive_shared/client_protocol.dart';
import 'package:archive_shared/windows_release.dart';
import 'package:cryptography/cryptography.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  test(
    'future publication cannot change the old server floor; incompatible clients can always use bootstrap and download',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'archive-protocol-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final seed = List<int>.filled(32, 19);
      final key = base64Encode(
        (await (await Ed25519().newKeyPairFromSeed(
          seed,
        )).extractPublicKey()).bytes,
      );
      final compatible = WindowsRelease(
        version: '1.0.2',
        build: 4,
        minimumSupportedBuild: 4,
        sha256: 'a' * 64,
        size: 2,
      );
      final future = WindowsRelease(
        version: '1.0.3',
        build: 20,
        minimumSupportedBuild: 20,
        clientProtocol: 2,
        sha256: 'b' * 64,
        size: 2,
      );
      final signed = await signWindowsRelease(compatible, seed);
      await File('${directory.path}/protocol-1.json').writeAsString(signed);
      await File(
        '${directory.path}/latest.json',
      ).writeAsString(await signWindowsRelease(future, seed));
      for (final release in [compatible, future]) {
        await File(
          '${directory.path}/${release.sha256}.exe',
        ).writeAsBytes([77, 90]);
      }
      final policy = WindowsClientPolicy(
        store: WindowsReleaseStore(directory),
        publicKey: () async => key,
        cacheDuration: Duration.zero,
      );
      expect(await policy.check(), signed);
      expect(await policy.requiredUpdate('windows', 4), isNull);
      final server = RelicServer(
        () => IOAdapter.bind(InternetAddress.loopbackIPv4, port: 0),
      );
      final client = HttpClient();
      var archiveCalls = 0;
      addTearDown(() async {
        client.close(force: true);
        await server.close(force: true);
      });
      await server.mountAndStart(
        policy.middleware((_) {
          archiveCalls++;
          return Response.ok();
        }),
      );
      Future<(int, List<int>)> request(
        String path, {
        int protocol = 2,
        int build = 20,
      }) async {
        final request = await client.getUrl(
          Uri.parse('http://127.0.0.1:${server.port}$path'),
        );
        request.headers.set('x-archive-platform', 'windows');
        request.headers.set('x-archive-build', '$build');
        request.headers.set('x-archive-protocol', '$protocol');
        final response = await request.close();
        return (
          response.statusCode,
          await response.fold<List<int>>([], (all, part) => all..addAll(part)),
        );
      }

      final check = await request('/$archiveUpdateCheckPath');
      expect(check.$1, 200);
      final info = UpdateCompatibility.fromJson(
        jsonDecode(utf8.decode(check.$2)) as Map<String, dynamic>,
      );
      expect(info.protocols, [1]);
      expect(info.manifest, signed);
      final download = await request(
        '/$archiveUpdateDownloadPath/${compatible.sha256}/0',
      );
      expect(download.$1, 200);
      expect(download.$2, [77, 90]);
      final denied = await request('/archive/profile');
      expect(denied.$1, 426);
      expect(
        (jsonDecode(utf8.decode(denied.$2)) as Map)['code'],
        'protocol_unsupported',
      );
      expect(archiveCalls, 0);
      expect(
        (await request('/archive/profile', protocol: 1, build: 4)).$1,
        200,
      );
      expect(archiveCalls, 1);
      final old = await request('/archive/profile', protocol: 1, build: 3);
      expect(old.$1, 426);
      expect((jsonDecode(utf8.decode(old.$2)) as Map)['manifest'], signed);
      final upgraded = WindowsClientPolicy(
        store: WindowsReleaseStore(directory),
        publicKey: () async => key,
        protocols: [1, 2],
      );
      expect(decodeWindowsRelease((await upgraded.check())!).build, 20);
      expect(await upgraded.requiredUpdate('windows', 4), isNotNull);
    },
  );
}
