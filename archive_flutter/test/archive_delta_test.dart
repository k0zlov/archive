import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive_client/archive_client.dart';
import 'package:archive_flutter/data/archive_repository.dart';
import 'package:archive_flutter/data/cache_store_native.dart';
import 'package:archive_flutter/data/local_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'archive_repository_test.dart' show TestClient;

Map<String, dynamic> record(int id, int version, {bool deleted = false}) => {
  'id': id,
  'version': version,
  'module': 'court',
  'values': {'caseNumber': 'CASE/$id', 'judge': 'Суддя $version'},
  'updatedAt': '2026-10-30T10:00:00Z',
  if (deleted) 'deletedAt': '2026-10-30T10:00:00Z',
};

class DeltaClient extends TestClient {
  int recordCalls = 0;
  final events = <Map<String, dynamic>>[];
  final cursors = <int>[];
  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) async {
    if (offline) throw const ServerpodClientNetworkException('offline');
    if (method == 'records') recordCalls++;
    if (endpoint == 'archiveSync') {
      final after = args['afterId'] as int;
      cursors.add(after);
      final head = events.length;
      return jsonEncode({
            'ok': true,
            'data': after == -1
                ? {'cursor': head}
                : {
                    'cursor': head,
                    'head': head,
                    'hasMore': false,
                    'items': events.skip(after).toList(),
                  },
          })
          as T;
    }
    return super.callServerEndpoint<T>(
      endpoint,
      method,
      args,
      authenticated: authenticated,
    );
  }
}

class ResetClient extends DeltaClient {
  bool cleared = false, resetSent = false;
  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) async {
    if (cleared && method == 'changes' && args['afterId'] != -1 && !resetSent) {
      resetSent = true;
      return jsonEncode({
            'ok': true,
            'data': {'reset': true},
          })
          as T;
    }
    if (cleared && method == 'records') {
      return jsonEncode({'ok': true, 'data': []}) as T;
    }
    return super.callServerEndpoint<T>(
      endpoint,
      method,
      args,
      authenticated: authenticated,
    );
  }
}

class CountingStore extends DriftCacheStore {
  CountingStore(String path) : super(databasePath: () async => path);
  int fullWrites = 0, deltas = 0;
  @override
  Future<void> write(String key, String value) async {
    fullWrites++;
    await super.write(key, value);
  }

  @override
  Future<void> applyArchiveDelta(
    String account,
    Map<String, dynamic> delta,
  ) async {
    deltas++;
    await super.applyArchiveDelta(account, delta);
  }
}

void main() {
  test(
    'updates, tombstones and restart resume by persisted cursor without another full download',
    () async {
      final dir = await Directory.systemTemp.createTemp('archive-deltas');
      addTearDown(() => dir.delete(recursive: true));
      final store = CountingStore('${dir.path}/cache.sqlite');
      final client = DeltaClient();
      ArchiveRepository create() => ArchiveRepository(
        client: client,
        store: store,
        server: 'test',
        userId: 'one',
      );
      final repo = create();
      await repo.refresh();
      expect(repo.online, true);
      expect(client.recordCalls, 1);
      client.events.add({'id': 1, 'record': record(1, 2)});
      await repo.refresh();
      expect(repo.records.single.version, 2);
      client.events.addAll([
        {'id': 2, 'record': record(1, 3, deleted: true)},
        {'id': 3, 'record': record(2, 1)},
      ]);
      await repo.refresh();
      expect(repo.records.single.id, 2);
      expect(store.fullWrites, 1);
      expect(store.deltas, 2);
      final restored = create();
      await restored.restore();
      expect(restored.records.single.id, 2);
      await restored.refresh();
      expect(client.cursors.last, 3);
      expect(client.recordCalls, 1);
      expect(
        (jsonDecode((await store.read(repo.cacheKey))!) as Map)['syncCursor'],
        3,
      );
      client.offline = true;
      await restored.refresh();
      expect(restored.online, false);
      expect(restored.records.single.id, 2);
    },
  );

  test(
    'Drift rolls back records and watermark together when a page is invalid',
    () async {
      final db = ArchiveLocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await db.replaceSnapshot(
        'one',
        jsonEncode({
          'profile': {'role': 'reader', 'courtAccess': true},
          'syncCursor': 10,
          'syncedAt': '2026-10-30T10:00:00Z',
          'records': [record(1, 1)],
          'documents': [],
          'files': {},
          'audit': [],
          'members': [],
        }),
      );
      await expectLater(
        db.applyArchiveDelta('one', {
          'removedIds': [1],
          'records': [
            {...record(2, 1), 'updatedAt': 'broken'},
          ],
          'audit': [],
          'profile': {'role': 'reader', '_syncCursor': 11},
          'syncedAt': '2026-10-30T10:01:00Z',
        }),
        throwsFormatException,
      );
      final snapshot = jsonDecode((await db.readSnapshot('one'))!) as Map;
      expect(snapshot['syncCursor'], 10);
      expect((snapshot['records'] as List).single['id'], 1);
    },
  );
  test(
    'server reset purges old records and cached file bytes before replacing the local copy',
    () async {
      final dir = await Directory.systemTemp.createTemp('archive-purge-cache');
      addTearDown(() => dir.delete(recursive: true));
      final store = CountingStore('${dir.path}/cache.sqlite');
      final client = ResetClient();
      final repo = ArchiveRepository(
        client: client,
        store: store,
        server: 'test',
        userId: 'one',
      );
      await repo.refresh();
      await store.syncAttachments(repo.cacheKey, [
        {
          'id': 1,
          'recordId': 1,
          'module': 'court',
          'fileName': 'test.pdf',
          'byteLength': 3,
          'chunkCount': 1,
        },
      ]);
      await store.putAttachmentChunk(
        repo.cacheKey,
        1,
        0,
        Uint8List.fromList([1, 2, 3]),
      );
      await store.completeAttachment(repo.cacheKey, 1);
      await repo.attachments.restore();
      expect(repo.records, hasLength(1));
      client.cleared = true;
      await repo.refresh();
      expect(repo.online, true);
      expect(repo.records, isEmpty);
      expect(repo.attachments.files, isEmpty);
      expect(await store.readAttachmentChunk(repo.cacheKey, 1, 0), isNull);
      expect(
        (jsonDecode((await store.read(repo.cacheKey))!) as Map)['records'],
        isEmpty,
      );
      expect(repo.dataReset.value, 1);
    },
  );
}
