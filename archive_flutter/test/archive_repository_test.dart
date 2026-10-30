import 'dart:async';
import 'dart:convert';
import 'package:archive_client/archive_client.dart';
import 'package:archive_shared/archive_shared.dart';
import 'package:archive_flutter/data/archive_repository.dart';
import 'package:archive_flutter/data/cache_store.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryStore implements CacheStore {
  final data = <String, String>{};
  @override
  Future<String?> read(String key) async => data[key];
  @override
  Future<void> write(String key, String value) async {
    data[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    data.remove(key);
  }
}

class TestClient extends Client {
  TestClient() : super('http://localhost:8080/');
  bool offline = false;
  bool revoked = false;
  bool passwordChangeRequired = false;
  Completer<void>? recordsGate;
  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) async {
    if (offline) throw const ServerpodClientNetworkException('offline');
    if (endpoint == 'attachment' && method == 'list') {
      return jsonEncode({'ok': true, 'data': []}) as T;
    }
    dynamic data;
    switch (method) {
      case 'profile':
        data = {
          'userId': 'one',
          'role': 'editor',
          'passwordChangeRequired': passwordChangeRequired,
          'courtAccess': !revoked,
          'managementAccess': false,
        };
      case 'recordRevision':
        data = {
          'revision':
              '${revoked ? 'none' : 'court'}:${recordsGate != null ? 2 : 1}',
        };
      case 'records':
        if (recordsGate != null) await recordsGate!.future;
        data = revoked
            ? []
            : [
                {
                  'id': 1,
                  'version': 1,
                  'module': 'court',
                  'values': {'caseNumber': '001/26'},
                  'updatedAt': '2026-10-29T10:00:00Z',
                },
              ];
      case 'documents':
        data = [];
      default:
        throw StateError('Unexpected endpoint call $method');
    }
    return jsonEncode({'ok': true, 'data': data}) as T;
  }
}

void main() {
  late TestClient client;
  late MemoryStore store;
  ArchiveRepository repository({
    String server = 'http://localhost:8080',
    String user = 'one',
  }) => ArchiveRepository(
    client: client,
    store: store,
    server: server,
    userId: user,
  );
  setUp(() {
    client = TestClient();
    store = MemoryStore();
  });
  test(
    'last successful snapshot survives restart offline and rejects changes',
    () async {
      final online = repository();
      await online.refresh();
      final timestamp = online.syncedAt;
      client.offline = true;
      final offline = repository();
      await offline.restore();
      await offline.refresh();
      expect(offline.online, false);
      expect(offline.records.single.reference, '001/26');
      expect(offline.syncedAt, timestamp);
      await expectLater(
        offline.save(ArchiveModule.court, {'caseNumber': '2'}, null),
        throwsA(isA<ArchiveFailure>()),
      );
    },
  );
  test('a cache cannot be read from another account or server', () async {
    await repository().refresh();
    final otherUser = repository(user: 'two');
    await otherUser.restore();
    final otherServer = repository(server: 'https://other.example');
    await otherServer.restore();
    expect(otherUser.records, isEmpty);
    expect(otherServer.records, isEmpty);
  });
  test('revoked module is removed from persistent offline snapshot', () async {
    final repo = repository();
    await repo.refresh();
    client.revoked = true;
    await repo.refresh();
    client.offline = true;
    final restored = repository();
    await restored.restore();
    expect(restored.records, isEmpty);
  });
  test(
    'a reset purges cached data until password change then reloads the same revision',
    () async {
      final repo = repository();
      await repo.refresh();
      expect(repo.records, hasLength(1));
      client.passwordChangeRequired = true;
      await repo.refresh();
      expect(repo.profile['passwordChangeRequired'], true);
      expect(repo.online, true);
      expect(repo.records, isEmpty);
      final offline = repository();
      await offline.restore();
      expect(offline.records, isEmpty);
      expect(offline.profile['passwordChangeRequired'], true);
      client.passwordChangeRequired = false;
      await repo.refresh();
      expect(repo.records, hasLength(1));
      expect(repo.profile['passwordChangeRequired'], false);
    },
  );
  test('a refresh finishing after logout cannot recreate the cache', () async {
    final repo = repository();
    await repo.refresh();
    client.recordsGate = Completer<void>();
    final refresh = repo.refresh();
    await Future<void>.delayed(Duration.zero);
    await repo.clear();
    client.recordsGate!.complete();
    await refresh;
    expect(repo.profile, isEmpty);
    expect(repo.records, isEmpty);
    expect(store.data, isEmpty);
  });
}
