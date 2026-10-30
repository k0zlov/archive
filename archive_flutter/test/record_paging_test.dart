import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:archive_shared/archive_shared.dart';
import 'package:archive_flutter/data/archive_repository.dart';
import 'package:archive_flutter/data/cache_store_native.dart';
import 'package:archive_flutter/data/local_database.dart';
import 'package:archive_flutter/data/record_page.dart';
import 'package:archive_flutter/ui/archive_controller.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'archive_repository_test.dart' show TestClient, MemoryStore;

Map<String, dynamic> _snapshot(List<Map<String, dynamic>> records) => {
  'profile': {'role': 'editor', 'courtAccess': true},
  'syncedAt': '2026-10-29T10:00:00Z',
  'records': records,
  'documents': [],
  'files': {},
  'members': [],
  'audit': [],
};
Map<String, dynamic> _record(int id, {String module = 'court'}) => {
  'id': id,
  'version': 1,
  'module': module,
  'updatedAt': '2026-10-29T10:00:00Z',
  'values': {
    'caseNumber': 'СПРАВА/$id',
    'participants': id == 17 ? 'Олена 100% Коваль' : 'Учасник $id',
    'retentionType': id.isEven ? 'Постійне' : 'Тимчасове',
  },
};

class _LegacyDatabase extends GeneratedDatabase {
  _LegacyDatabase(super.executor);
  @override
  int get schemaVersion => 1;
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => [];
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (_) => customStatement(
      'CREATE TABLE local_records (account TEXT NOT NULL, remote_id INTEGER NOT NULL, module TEXT NOT NULL, payload TEXT NOT NULL, PRIMARY KEY(account, remote_id))',
    ),
  );
}

class _MetadataStore extends MemoryStore implements SnapshotMetadataStore {
  int fullWrites = 0, metadataWrites = 0;
  @override
  Future<void> write(String key, String value) async {
    fullWrites++;
    await super.write(key, value);
  }

  @override
  Future<void> updateMetadata(
    String account,
    Map<String, dynamic> profile,
    String syncedAt,
  ) async {
    metadataWrites++;
    final snapshot = Map<String, dynamic>.from(
      jsonDecode(data[account]!) as Map,
    );
    snapshot['profile'] = profile;
    snapshot['syncedAt'] = syncedAt;
    data[account] = jsonEncode(snapshot);
  }
}

class _CountingClient extends TestClient {
  int recordCalls = 0;
  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) {
    if (method == 'records') recordCalls++;
    return super.callServerEndpoint<T>(
      endpoint,
      method,
      args,
      authenticated: authenticated,
    );
  }
}

class _SavingClient extends _CountingClient {
  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) async {
    if (method == 'saveRecord') {
      return jsonEncode({
            'ok': true,
            'data': {
              'id': args['id'] ?? 1,
              'module': args['module'],
              'version': 2,
              'updatedAt': '2026-10-30T10:00:00Z',
              'values': jsonDecode(args['valuesJson'] as String),
              'merged': false,
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

class _GatedRepository extends ArchiveRepository {
  _GatedRepository()
    : super(
        client: TestClient(),
        store: MemoryStore(),
        server: 'test',
        userId: 'one',
      );
  final slow = Completer<CaseRecordPage>();
  @override
  Future<CaseRecordPage> recordPage(
    ArchiveModule module, {
    String query = '',
    String retention = '',
    int page = 0,
    int size = 50,
  }) async {
    if (query == 'old') return slow.future;
    return CaseRecordPage([CaseRecord.fromJson(_record(3))], 1, 0);
  }
}

void main() {
  test(
    'Drift returns bounded stable pages, literal Ukrainian search, filters and account isolation',
    () async {
      final db = ArchiveLocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await db.replaceSnapshot(
        'one',
        jsonEncode(
          _snapshot([
            for (var id = 1; id <= 123; id++) _record(id),
            _record(999, module: 'management'),
          ]),
        ),
      );
      await db.replaceSnapshot('two', jsonEncode(_snapshot([_record(1000)])));
      final first = await db.readRecordPage(
        const RecordPageRequest(account: 'one', module: 'court'),
      );
      final second = await db.readRecordPage(
        const RecordPageRequest(account: 'one', module: 'court', page: 1),
      );
      final last = await db.readRecordPage(
        const RecordPageRequest(account: 'one', module: 'court', page: 99),
      );
      expect(first.total, 123);
      expect(first.records, hasLength(50));
      expect(first.records.first['id'], 123);
      expect(second.records.first['id'], 73);
      expect(last.page, 2);
      expect(last.records, hasLength(23));
      expect({
        ...first.records.map((r) => r['id']),
        ...second.records.map((r) => r['id']),
        ...last.records.map((r) => r['id']),
      }, hasLength(123));
      final found = await db.readRecordPage(
        const RecordPageRequest(
          account: 'one',
          module: 'court',
          search: 'ОЛЕНА 100%',
        ),
      );
      expect(found.records.single['id'], 17);
      final filtered = await db.readRecordPage(
        const RecordPageRequest(
          account: 'one',
          module: 'court',
          retention: 'Постійне',
        ),
      );
      expect(filtered.total, 61);
      expect(filtered.records.every((r) => (r['id'] as int).isEven), true);
      expect(
        (await db.readRecordPage(
          const RecordPageRequest(account: 'none', module: 'court'),
        )).total,
        0,
      );
      final plan = await db
          .customSelect(
            'EXPLAIN QUERY PLAN SELECT payload FROM local_records WHERE account = ? AND module = ? ORDER BY updated_at_millis DESC, remote_id DESC LIMIT 50',
            variables: [const Variable('one'), const Variable('court')],
          )
          .get();
      final details = plan.map((r) => r.data.values.join(' ')).join(' ');
      expect(details, contains('local_records_page_idx'));
      expect(details, isNot(contains('TEMP B-TREE')));
    },
  );
  test(
    'schema 1 migrates existing data and indexes Ukrainian search without discarding cards',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'archive-v1-pages',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/local.sqlite');
      final old = _LegacyDatabase(NativeDatabase(file));
      await old.customStatement(
        'INSERT INTO local_records VALUES (?, ?, ?, ?)',
        ['one', 17, 'court', jsonEncode(_record(17))],
      );
      await old.close();
      final db = ArchiveLocalDatabase(NativeDatabase(file));
      addTearDown(db.close);
      final page = await db.readRecordPage(
        const RecordPageRequest(
          account: 'one',
          module: 'court',
          search: 'ОЛЕНА',
        ),
      );
      expect(page.records.single['id'], 17);
      expect(
        (await db.customSelect('PRAGMA user_version').getSingle())
            .data
            .values
            .single,
        3,
      );
    },
  );
  test(
    'native cache worker supports paging while preserving the full offline snapshot',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'archive-native-pages',
      );
      addTearDown(() => directory.delete(recursive: true));
      final store = DriftCacheStore(
        databasePath: () async => '${directory.path}/local.sqlite',
      );
      await store.write(
        'one',
        jsonEncode(_snapshot([for (var id = 1; id <= 501; id++) _record(id)])),
      );
      final page = await store.readRecordPage(
        const RecordPageRequest(account: 'one', module: 'court', page: 10),
      );
      expect(page.records.single['id'], 1);
      expect(page.total, 501);
      await store.updateMetadata('one', {
        'role': 'reader',
        'courtAccess': true,
      }, '2026-10-30T10:00:00Z');
      final metadata = jsonDecode((await store.read('one'))!) as Map;
      expect(metadata['syncedAt'], '2026-10-30T10:00:00Z');
      expect(metadata['records'], hasLength(501));
      expect(
        (jsonDecode((await store.read('one'))!) as Map)['records'],
        hasLength(501),
      );
    },
  );
  test(
    'unchanged server revision skips a second complete card download',
    () async {
      final client = _CountingClient();
      final repo = ArchiveRepository(
        client: client,
        store: MemoryStore(),
        server: 'test',
        userId: 'one',
      );
      await repo.refresh();
      await repo.refresh();
      expect(client.recordCalls, 1);
      expect(repo.records, hasLength(1));
      client.revoked = true;
      await repo.refresh();
      expect(repo.records, isEmpty);
    },
  );
  test('a late search result cannot replace the current page', () async {
    final repo = _GatedRepository();
    final controller = ArchiveController(repo);
    addTearDown(controller.dispose);
    controller.search = 'old';
    final old = controller.loadPage();
    controller.search = 'new';
    await controller.loadPage();
    repo.slow.complete(
      CaseRecordPage([CaseRecord.fromJson(_record(99))], 1, 0),
    );
    await old;
    expect(controller.recordsOnPage.single.id, 3);
    expect(controller.pageLoading, false);
  });
  test(
    'saving one card updates its Drift row without downloading the archive again',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'archive-save-patch',
      );
      addTearDown(() => directory.delete(recursive: true));
      final store = DriftCacheStore(
        databasePath: () async => '${directory.path}/local.sqlite',
      );
      final client = _SavingClient();
      final repo = ArchiveRepository(
        client: client,
        store: store,
        server: 'test',
        userId: 'one',
      );
      await repo.refresh();
      await repo.save(ArchiveModule.court, {
        'caseNumber': '001/26',
        'judge': 'Новий суддя',
      }, repo.records.single);
      expect(client.recordCalls, 1);
      expect(
        (await repo.recordPage(
          ArchiveModule.court,
        )).records.single.values['judge'],
        'Новий суддя',
      );
      expect(
        ((jsonDecode((await store.read(repo.cacheKey))!) as Map)['records']
                as List)
            .single['values']['judge'],
        'Новий суддя',
      );
    },
  );
  test(
    'an older background refresh cannot overwrite a freshly saved card',
    () async {
      final client = _SavingClient();
      final repo = ArchiveRepository(
        client: client,
        store: MemoryStore(),
        server: 'test',
        userId: 'one',
      );
      await repo.refresh();
      client.recordsGate = Completer<void>();
      final background = repo.refresh();
      await Future<void>.delayed(Duration.zero);
      await repo.save(ArchiveModule.court, {
        'caseNumber': '001/26',
        'judge': 'Свіжі дані',
      }, repo.records.single);
      client.recordsGate!.complete();
      await background;
      expect(repo.records.single.values['judge'], 'Свіжі дані');
    },
  );
  test(
    'unchanged sync updates metadata without rewriting the full local database',
    () async {
      final store = _MetadataStore();
      final repo = ArchiveRepository(
        client: TestClient(),
        store: store,
        server: 'test',
        userId: 'one',
      );
      await repo.refresh();
      await repo.refresh();
      expect(store.fullWrites, 1);
      expect(store.metadataWrites, 1);
      expect(
        (jsonDecode(store.data[repo.cacheKey]!) as Map)['records'],
        hasLength(1),
      );
    },
  );
}
