import 'dart:convert';
import 'package:drift/drift.dart';
import 'record_page.dart';
part 'local_database.g.dart';

class LocalAccounts extends Table {
  TextColumn get account => text()();
  TextColumn get profile => text()();
  TextColumn get syncedAt => text()();
  @override
  Set<Column> get primaryKey => {account};
}

@TableIndex(
  name: 'local_records_page_idx',
  columns: {#account, #module, #updatedAtMillis, #remoteId},
)
class LocalRecords extends Table {
  TextColumn get account => text()();
  IntColumn get remoteId => integer()();
  TextColumn get module => text()();
  TextColumn get payload => text()();
  IntColumn get updatedAtMillis => integer().withDefault(const Constant(0))();
  TextColumn get searchText => text().withDefault(const Constant(''))();
  TextColumn get retentionType => text().withDefault(const Constant(''))();
  @override
  Set<Column> get primaryKey => {account, remoteId};
}

class LocalDocuments extends Table {
  TextColumn get account => text()();
  IntColumn get remoteId => integer()();
  TextColumn get payload => text()();
  BlobColumn get contents => blob().nullable()();
  @override
  Set<Column> get primaryKey => {account, remoteId};
}

class LocalAuditEvents extends Table {
  TextColumn get account => text()();
  IntColumn get remoteId => integer()();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {account, remoteId};
}

class LocalMembers extends Table {
  TextColumn get account => text()();
  IntColumn get remoteId => integer()();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {account, remoteId};
}

/// Replaces an account's authorized snapshot atomically. No authentication tokens.
@DriftDatabase(
  tables: [
    LocalAccounts,
    LocalRecords,
    LocalDocuments,
    LocalAuditEvents,
    LocalMembers,
  ],
)
class ArchiveLocalDatabase extends _$ArchiveLocalDatabase {
  ArchiveLocalDatabase(super.executor);
  @override
  int get schemaVersion => 2;

  Future<void> updateMetadata(
    String account,
    Map<String, dynamic> profile,
    String syncedAt,
  ) async {
    final changed =
        await (update(
          localAccounts,
        )..where((t) => t.account.equals(account))).write(
          LocalAccountsCompanion(
            profile: Value(jsonEncode(profile)),
            syncedAt: Value(syncedAt),
          ),
        );
    if (changed != 1) throw StateError('Локальну копію не знайдено.');
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(localRecords, localRecords.updatedAtMillis);
        await m.addColumn(localRecords, localRecords.searchText);
        await m.addColumn(localRecords, localRecords.retentionType);
        final old = await select(localRecords).get();
        await batch((b) {
          for (final row in old) {
            final record = jsonDecode(row.payload) as Map;
            final values = record['values'] as Map;
            b.update(
              localRecords,
              LocalRecordsCompanion(
                updatedAtMillis: Value(
                  DateTime.parse(
                    record['updatedAt'] as String,
                  ).millisecondsSinceEpoch,
                ),
                searchText: Value(recordSearchText(values)),
                retentionType: Value(values['retentionType'] as String? ?? ''),
              ),
              where: (t) =>
                  t.account.equals(row.account) &
                  t.remoteId.equals(row.remoteId),
            );
          }
        });
        await customStatement(
          'CREATE INDEX IF NOT EXISTS local_records_page_idx ON local_records (account, module, updated_at_millis, remote_id)',
        );
      }
    },
  );

  Future<RecordPageData> readRecordPage(RecordPageRequest request) =>
      transaction(() async {
        if (request.size < 1 || request.size > 200 || request.page < 0) {
          throw ArgumentError('Некоректна сторінка.');
        }
        final search = request.search.trim().toLowerCase();
        Expression<bool> filter($LocalRecordsTable t) =>
            t.account.equals(request.account) &
            t.module.equals(request.module) &
            (request.retention.isEmpty
                ? const Constant(true)
                : t.retentionType.equals(request.retention)) &
            (search.isEmpty
                ? const Constant(true)
                : FunctionCallExpression<int>('instr', [
                    t.searchText,
                    Variable(search),
                  ]).isBiggerThanValue(0));
        final count = localRecords.remoteId.count();
        final countQuery = selectOnly(localRecords)
          ..addColumns([count])
          ..where(filter(localRecords));
        final total = (await countQuery.getSingle()).read(count) ?? 0;
        final lastPage = total == 0 ? 0 : (total - 1) ~/ request.size;
        final page = request.page > lastPage ? lastPage : request.page;
        final query = select(localRecords)
          ..where(filter)
          ..orderBy([
            (t) => OrderingTerm.desc(t.updatedAtMillis),
            (t) => OrderingTerm.desc(t.remoteId),
          ])
          ..limit(request.size, offset: page * request.size);
        final rows = await query.get();
        return RecordPageData(
          rows
              .map(
                (r) => Map<String, dynamic>.from(jsonDecode(r.payload) as Map),
              )
              .toList(),
          total,
          page,
        );
      });

  Future<void> applyRecordPatch(
    String account,
    Map<String, dynamic> record,
    List<int> removedIds,
  ) => transaction(() async {
    if (removedIds.isNotEmpty) {
      await (delete(localRecords)..where(
            (t) => t.account.equals(account) & t.remoteId.isIn(removedIds),
          ))
          .go();
    }
    final values = record['values'] as Map;
    await into(localRecords).insertOnConflictUpdate(
      LocalRecordsCompanion.insert(
        account: account,
        remoteId: record['id'] as int,
        module: record['module'] as String,
        payload: jsonEncode(record),
        updatedAtMillis: Value(
          DateTime.parse(record['updatedAt'] as String).millisecondsSinceEpoch,
        ),
        searchText: Value(recordSearchText(values)),
        retentionType: Value(values['retentionType'] as String? ?? ''),
      ),
    );
  });

  Future<String?> readSnapshot(String account) => transaction(() async {
    final meta = await (select(
      localAccounts,
    )..where((t) => t.account.equals(account))).getSingleOrNull();
    if (meta == null) return null;
    final records = await (select(
      localRecords,
    )..where((t) => t.account.equals(account))).get();
    final documents = await (select(
      localDocuments,
    )..where((t) => t.account.equals(account))).get();
    final audit =
        await (select(localAuditEvents)
              ..where((t) => t.account.equals(account))
              ..orderBy([(t) => OrderingTerm.desc(t.remoteId)]))
            .get();
    final members = await (select(
      localMembers,
    )..where((t) => t.account.equals(account))).get();
    return jsonEncode({
      'schemaVersion': 1,
      'profile': jsonDecode(meta.profile),
      'syncedAt': meta.syncedAt,
      'records': records.map((r) => jsonDecode(r.payload)).toList(),
      'documents': documents.map((d) => jsonDecode(d.payload)).toList(),
      'files': {
        for (final d in documents)
          if (d.contents != null) '${d.remoteId}': base64Encode(d.contents!),
      },
      'audit': audit.map((e) => jsonDecode(e.payload)).toList(),
      'members': members.map((m) => jsonDecode(m.payload)).toList(),
    });
  });

  Future<void> replaceSnapshot(String account, String raw) => transaction(
    () async {
      final snapshot = jsonDecode(raw) as Map;
      await removeSnapshot(account);
      await into(localAccounts).insert(
        LocalAccountsCompanion.insert(
          account: account,
          profile: jsonEncode(snapshot['profile']),
          syncedAt: snapshot['syncedAt'] as String,
        ),
      );
      final files = snapshot['files'] as Map? ?? {};
      await batch((b) {
        b.insertAll(localRecords, [
          for (final r in snapshot['records'] as List)
            LocalRecordsCompanion.insert(
              account: account,
              remoteId: r['id'] as int,
              module: r['module'] as String,
              payload: jsonEncode(r),
              updatedAtMillis: Value(
                DateTime.parse(r['updatedAt'] as String).millisecondsSinceEpoch,
              ),
              searchText: Value(recordSearchText(r['values'] as Map)),
              retentionType: Value(
                (r['values'] as Map)['retentionType'] as String? ?? '',
              ),
            ),
        ]);
        b.insertAll(localDocuments, [
          for (final d in snapshot['documents'] as List)
            LocalDocumentsCompanion.insert(
              account: account,
              remoteId: d['id'] as int,
              payload: jsonEncode(d),
              contents: Value(
                files['${d['id']}'] == null
                    ? null
                    : base64Decode(files['${d['id']}'] as String),
              ),
            ),
        ]);
        b.insertAll(localAuditEvents, [
          for (final e in snapshot['audit'] as List? ?? [])
            LocalAuditEventsCompanion.insert(
              account: account,
              remoteId: e['id'] as int,
              payload: jsonEncode(e),
            ),
        ]);
        b.insertAll(localMembers, [
          for (final m in snapshot['members'] as List? ?? [])
            LocalMembersCompanion.insert(
              account: account,
              remoteId: m['id'] as int,
              payload: jsonEncode(m),
            ),
        ]);
      });
    },
  );
  Future<void> removeSnapshot(String account) => transaction(() async {
    await (delete(localRecords)..where((t) => t.account.equals(account))).go();
    await (delete(
      localDocuments,
    )..where((t) => t.account.equals(account))).go();
    await (delete(
      localAuditEvents,
    )..where((t) => t.account.equals(account))).go();
    await (delete(localMembers)..where((t) => t.account.equals(account))).go();
    await (delete(localAccounts)..where((t) => t.account.equals(account))).go();
  });
}
