import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'cache_store.dart';
import 'local_database.dart';
import 'record_page.dart';

CacheStore createStore() => DriftCacheStore();

class _DatabaseWork {
  const _DatabaseWork(
    this.path,
    this.account,
    this.operation, {
    this.snapshot,
    this.query,
    this.record,
    this.removedIds = const [],
  });
  final String path, account, operation;
  final String? snapshot;
  final RecordPageRequest? query;
  final Map<String, dynamic>? record;
  final List<int> removedIds;
}

/// Parsing, migration and ORM batch construction run off the UI isolate too.
Future<Object?> _databaseWork(_DatabaseWork work) async {
  final database = ArchiveLocalDatabase(
    NativeDatabase(
      File(work.path),
      setup: (db) {
        db.execute('PRAGMA busy_timeout = 5000');
        db.execute('PRAGMA journal_mode = WAL');
      },
    ),
  );
  try {
    switch (work.operation) {
      case 'read':
        return await database.readSnapshot(work.account);
      case 'write':
        await database.replaceSnapshot(work.account, work.snapshot!);
        return null;
      case 'remove':
        await database.removeSnapshot(work.account);
        return null;
      case 'page':
        return await database.readRecordPage(work.query!);
      case 'patch':
        await database.applyRecordPatch(
          work.account,
          work.record!,
          work.removedIds,
        );
        return null;
      case 'metadata':
        await database.updateMetadata(
          work.account,
          Map<String, dynamic>.from(work.record!['profile'] as Map),
          work.record!['syncedAt'] as String,
        );
        return null;
      default:
        throw StateError('Unknown local database operation');
    }
  } finally {
    await database.close();
  }
}

class DriftCacheStore
    implements
        CacheStore,
        RecordPageStore,
        RecordPatchStore,
        SnapshotMetadataStore {
  DriftCacheStore({Future<String> Function()? databasePath})
    : _path = (databasePath ?? _defaultPath)();
  final Future<String> _path;
  static Future<String> _defaultPath() async =>
      '${(await getApplicationSupportDirectory()).path}/archive_local.sqlite';
  Future<Object?> _run(
    String key,
    String operation, {
    String? snapshot,
    RecordPageRequest? query,
  }) async => compute(
    _databaseWork,
    _DatabaseWork(
      await _path,
      key,
      operation,
      snapshot: snapshot,
      query: query,
    ),
  );
  @override
  Future<String?> read(String key) async {
    final current = await _run(key, 'read') as String?;
    if (current != null) return current;
    final old = await _legacy(key);
    if (!await old.exists()) return null;
    final content = await old.readAsString();
    await write(key, content);
    await old.delete();
    return content;
  }

  Future<File> _legacy(String key) async => File(
    '${(await getApplicationSupportDirectory()).path}/archive_cache/$key.json',
  );
  @override
  Future<void> write(String key, String value) async {
    await _run(key, 'write', snapshot: value);
  }

  @override
  Future<RecordPageData> readRecordPage(RecordPageRequest request) async =>
      await _run(request.account, 'page', query: request) as RecordPageData;
  @override
  Future<void> applyRecordPatch(
    String account,
    Map<String, dynamic> record,
    List<int> removedIds,
  ) async {
    await compute(
      _databaseWork,
      _DatabaseWork(
        await _path,
        account,
        'patch',
        record: record,
        removedIds: removedIds,
      ),
    );
  }

  @override
  Future<void> updateMetadata(
    String account,
    Map<String, dynamic> profile,
    String syncedAt,
  ) async {
    await compute(
      _databaseWork,
      _DatabaseWork(
        await _path,
        account,
        'metadata',
        record: {'profile': profile, 'syncedAt': syncedAt},
      ),
    );
  }

  @override
  Future<void> remove(String key) async {
    await _run(key, 'remove');
    final old = await _legacy(key);
    if (await old.exists()) await old.delete();
  }
}
