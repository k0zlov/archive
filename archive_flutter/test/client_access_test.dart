import 'dart:convert';
import 'package:archive_flutter/data/archive_repository.dart';
import 'package:archive_flutter/data/updates/archive_api_client.dart';
import 'package:archive_flutter/data/updates/client_access.dart';
import 'package:archive_flutter/ui/archive_controller.dart';
import 'package:archive_shared/archive_schema.dart';
import 'package:archive_shared/windows_release.dart';
import 'package:archive_shared/client_protocol.dart';
import 'package:archive_flutter/data/updates/update_source.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'archive_repository_test.dart' show MemoryStore, TestClient;

void main() {
  final seed = List<int>.filled(32, 23);
  late String key, mandatory;
  late ClientAccess access;
  setUp(() async {
    key = base64Encode(
      (await (await Ed25519().newKeyPairFromSeed(
        seed,
      )).extractPublicKey()).bytes,
    );
    mandatory = await signWindowsRelease(
      WindowsRelease(
        version: '1.0.3',
        build: 10,
        minimumSupportedBuild: 8,
        sha256: 'a' * 64,
        size: 2,
      ),
      seed,
    );
    access = ClientAccess(platform: 'windows', build: 2, trustedKey: key);
  });
  test(
    'startup and mandatory gates stop data, auth and streams, but allow the public update channel',
    () async {
      final sent = <http.Request>[];
      final client = ArchiveApiClient(
        'http://localhost:8080/',
        access,
        httpClient: MockClient((r) async {
          sent.add(r);
          return http.Response('null', 200);
        }),
      );
      addTearDown(client.close);
      expect(
        () => client.archive.profile(),
        throwsA(isA<ClientOfflineException>()),
      );
      await access.accept(mandatory);
      expect(
        () => client.callServerEndpoint('account', 'login', {}),
        throwsA(isA<ClientOfflineException>()),
      );
      await expectLater(
        client.archiveSync.watch(const Stream<int>.empty()),
        emitsError(isA<ClientOfflineException>()),
      );
      expect(sent, isEmpty);
      expect(await client.updates.check(), isNull);
      expect(sent, hasLength(1));
      expect(sent.single.headers['x-archive-platform'], 'windows');
      expect(sent.single.headers['x-archive-build'], '2');
      expect(sent.single.headers['x-archive-protocol'], '1');
      expect(sent.single.headers.containsKey('authorization'), isFalse);
    },
  );
  test(
    'future client stays offline on an older server while the stable update channel and downloads remain available',
    () async {
      final future = ClientAccess(
        platform: 'windows',
        build: 20,
        protocol: 2,
        trustedKey: key,
      );
      final sent = <http.Request>[];
      final client = ArchiveApiClient(
        'http://localhost:8080/',
        future,
        httpClient: MockClient((r) async {
          sent.add(r);
          if (r.url.path.endsWith('/check')) {
            return http.Response(
              jsonEncode({
                'format': 1,
                'protocols': [1],
                'manifest': mandatory,
              }),
              200,
            );
          }
          return http.Response.bytes([77, 90], 200);
        }),
      );
      addTearDown(client.close);
      final updates = ServerpodUpdateSource(client);
      await updates.check();
      expect(future.serverUpgradeRequired, true);
      expect(future.onlineAllowed, false);
      future.chooseOffline();
      expect(
        () => client.archive.profile(),
        throwsA(isA<ClientOfflineException>()),
      );
      expect((await updates.download('a' * 64, 0)).lengthInBytes, 2);
      expect(sent, hasLength(2));
      expect(sent.every((r) => !r.headers.containsKey('authorization')), true);
      await future.acceptCompatibility(UpdateCompatibility(protocols: [1, 2]));
      expect(future.onlineAllowed, true);
    },
  );
  test(
    'bootstrap fallback is limited to legacy servers; errors never silently enable a future protocol',
    () async {
      var rpcCalls = 0;
      final future = ClientAccess(
        platform: 'windows',
        build: 20,
        protocol: 2,
        trustedKey: key,
      );
      var status = 404;
      final client = ArchiveApiClient(
        'http://localhost:8080/',
        future,
        httpClient: MockClient((r) async {
          if (r.url.path.contains('client-updates')) {
            return http.Response('', status);
          }
          rpcCalls++;
          return http.Response(jsonEncode(mandatory), 200);
        }),
      );
      addTearDown(client.close);
      await client.checkUpdates();
      expect(rpcCalls, 1);
      expect(future.protocolBlocked, true);
      status = 500;
      await expectLater(client.checkUpdates(), throwsFormatException);
      expect(rpcCalls, 1);
      expect(future.onlineAllowed, false);
    },
  );
  test(
    'signed policies retain separate floors across protocol changes and reject incompatible offers',
    () async {
      String? stored;
      access.remember = (raw) async => stored = raw;
      await access.accept(mandatory);
      final newer = await signWindowsRelease(
        WindowsRelease(
          version: '1.0.4',
          build: 20,
          minimumSupportedBuild: 20,
          clientProtocol: 2,
          sha256: 'b' * 64,
          size: 2,
        ),
        seed,
      );
      await access.acceptCompatibility(
        UpdateCompatibility(protocols: [1, 2], manifest: newer),
      );
      expect(access.requiredUpdate, true);
      final restored = ClientAccess(
        platform: 'windows',
        build: 10,
        trustedKey: key,
      );
      addTearDown(restored.dispose);
      await restored.restorePolicy(stored!);
      await restored.acceptCompatibility(
        UpdateCompatibility(protocols: [1], manifest: mandatory),
      );
      expect(
        restored.onlineAllowed,
        true,
      ); // Protocol 2's floor cannot poison protocol 1.
      expect(restored.policy!.minimumSupportedBuild, 8);
      await expectLater(
        restored.acceptCompatibility(
          UpdateCompatibility(protocols: [1], manifest: newer),
        ),
        throwsFormatException,
      );
      expect(restored.policy!.clientProtocol, 1);
      final softTarget = await signWindowsRelease(
        WindowsRelease(
          version: '1.0.5',
          build: 30,
          clientProtocol: 2,
          sha256: 'c' * 64,
          size: 2,
        ),
        seed,
      );
      final fresh = ClientAccess(
        platform: 'windows',
        build: 2,
        trustedKey: key,
      );
      addTearDown(fresh.dispose);
      await fresh.acceptCompatibility(
        UpdateCompatibility(
          protocols: [1, 2],
          manifest: softTarget,
          policyManifests: [mandatory],
        ),
      );
      expect(fresh.policy!.clientProtocol, 2);
      expect(
        fresh.requiredUpdate,
        true,
      ); // Own protocol's signed floor applies on a fresh install too.
      expect(fresh.onlineAllowed, false);
      access.dispose();
    },
  );
  test(
    'HTTP 426 adopts signed policy before any later request; invalid data cannot lower it',
    () async {
      var sent = 0;
      final client = ArchiveApiClient(
        'http://localhost:8080/',
        access,
        httpClient: MockClient((r) async {
          sent++;
          return http.Response(
            jsonEncode({'code': 'update_required', 'manifest': mandatory}),
            426,
          );
        }),
      );
      addTearDown(client.close);
      access.checkCompleted();
      await expectLater(
        client.archive.profile(),
        throwsA(isA<ClientOfflineException>()),
      );
      expect(access.requiredUpdate, isTrue);
      expect(
        () => client.archive.profile(),
        throwsA(isA<ClientOfflineException>()),
      );
      expect(sent, 1);
      await expectLater(access.accept('{}'), throwsFormatException);
      access.checkCompleted();
      expect(access.onlineAllowed, isFalse);
      final lower = await signWindowsRelease(
        WindowsRelease(version: '1.0.4', build: 11, sha256: 'b' * 64, size: 2),
        seed,
      );
      access.checked = false; // Startup after restoring the cached policy.
      await access.accept(lower);
      expect(access.checked, isTrue);
      expect(access.policy!.minimumSupportedBuild, 8);
    },
  );
  test(
    'cached signed policy survives restart and failed checks; the cached archive stays readable without requests',
    () async {
      String? persisted;
      access.remember = (raw) async => persisted = raw;
      await access.accept(mandatory);
      final restoredAccess = ClientAccess(
        platform: 'windows',
        build: 2,
        trustedKey: key,
      );
      await restoredAccess.restorePolicy(persisted!);
      restoredAccess.checkFailed();
      expect(restoredAccess.requiredUpdate, isTrue);
      final store = MemoryStore(), seedClient = TestClient();
      addTearDown(seedClient.close);
      final online = ArchiveRepository(
        client: seedClient,
        store: store,
        server: 'http://localhost:8080/',
        userId: 'one',
      );
      await online.refresh();
      final before = Map<String, String>.of(store.data);
      online.dispose();
      var sent = 0;
      final client = ArchiveApiClient(
        'http://localhost:8080/',
        restoredAccess,
        httpClient: MockClient((_) async {
          sent++;
          throw StateError('Must remain offline');
        }),
      );
      addTearDown(client.close);
      final repository = ArchiveRepository(
        client: client,
        store: store,
        server: 'http://localhost:8080/',
        userId: 'one',
      );
      final controller = ArchiveController(repository);
      addTearDown(controller.dispose);
      await controller.initialize();
      expect(controller.recordsOnPage.single.reference, '001/26');
      expect(controller.writable, isFalse);
      await expectLater(
        repository.save(ArchiveModule.court, {'caseNumber': '2'}, null),
        throwsA(isA<ArchiveFailure>()),
      );
      await repository.refresh();
      expect(sent, 0);
      expect(store.data, before);
      access.dispose();
    },
  );
}
