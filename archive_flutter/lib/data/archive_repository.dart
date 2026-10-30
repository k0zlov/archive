import 'dart:async';
import 'dart:convert';
import 'package:archive_client/archive_client.dart';
import 'package:archive_shared/archive_schema.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show compute, mapEquals;
import 'cache_store.dart';
import 'record_page.dart';
import 'archive_activity.dart';
import 'attachment_repository.dart';

Map<String, dynamic> _decodeArchiveJson(String raw) =>
    jsonDecode(raw) as Map<String, dynamic>;
String _encodeArchiveJson(Map<String, dynamic> value) => jsonEncode(value);
bool _sameMetadata(List<Map<String, dynamic>> a, List<Map<String, dynamic>> b) {
  if (a.length != b.length) return false;
  final indexed = {for (final value in a) value['id']: value};
  return b.every((value) => mapEquals(indexed[value['id']], value));
}

class CaseRecordPage {
  const CaseRecordPage(this.records, this.total, this.page);
  final List<CaseRecord> records;
  final int total, page;
}

class ArchiveFailure implements Exception {
  const ArchiveFailure(this.message, {this.denied = false});
  final String message;
  final bool denied;
  @override
  String toString() => message;
}

class ArchiveImportCancelled extends ArchiveFailure {
  const ArchiveImportCancelled() : super('Імпорт скасовано. Записи не додано.');
}

class CaseRecord {
  CaseRecord.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      version = json['version'] as int,
      module = ArchiveModule.values.byName(json['module'] as String),
      values = Map.unmodifiable(
        Map<String, String>.from(json['values'] as Map),
      ),
      updatedAt = DateTime.parse(json['updatedAt'] as String);
  final int id;
  final int version;
  final ArchiveModule module;
  final Map<String, String> values;
  final DateTime updatedAt;
  String get reference => recordReference(module, values);
  String get title => values['title'] ?? values['category'] ?? 'Без категорії';
  late final String listTitle = title.length > 220
      ? '${title.substring(0, 220)}…'
      : title;
  late final String listProceedings = (() {
    final value = values['proceedingNumber'] ?? '';
    if (value.length <= 100) return value.replaceAll('\n', ', ');
    return '${value.substring(0, 100).replaceAll('\n', ', ')}…';
  })();
  late final String searchText = recordSearchText(values);
  Map<String, dynamic> toJson() => {
    'id': id,
    'version': version,
    'module': module.name,
    'values': values,
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class ArchiveRepository {
  ArchiveRepository({
    required this.client,
    required this.store,
    required String server,
    required String userId,
  }) : cacheKey = sha256.convert(utf8.encode('$server|$userId')).toString();
  final Client client;
  final CacheStore store;
  final String cacheKey;
  final activity = ArchiveActivity();
  late final attachments = AttachmentRepository(this);
  int _mutationEpoch = 0;
  Future<void>? _refreshInFlight;
  Map<String, dynamic> profile = {};
  List<CaseRecord> records = [];
  List<Map<String, dynamic>> documents = [];
  Map<String, String> documentFiles = {};
  List<Map<String, dynamic>> audit = [];
  List<Map<String, dynamic>> members = [];
  DateTime? syncedAt;
  bool online = false;
  String? notice;
  bool lastSaveMerged = false;
  Map<String, dynamic> lastImportSummary = {};
  int _generation = 0;
  Future<void> _cacheWrites = Future<void>.value();
  bool _cacheReady = false;
  String? _recordRevision;
  Object? _matchingSource;
  String? _matchingQuery;
  List<CaseRecord> _matching = [];

  /// Also used by export: it deliberately includes every matching page.
  List<CaseRecord> matchingRecords(
    ArchiveModule module,
    String query,
    String retention,
  ) {
    final normalized = query.trim().toLowerCase();
    final key = '${module.name}\u001f$normalized\u001f$retention';
    if (!identical(_matchingSource, records) || key != _matchingQuery) {
      _matchingSource = records;
      _matchingQuery = key;
      _matching =
          records
              .where(
                (r) =>
                    r.module == module &&
                    (retention.isEmpty ||
                        r.values['retentionType'] == retention) &&
                    (normalized.isEmpty || r.searchText.contains(normalized)),
              )
              .toList()
            ..sort((a, b) {
              final order = b.updatedAt.compareTo(a.updatedAt);
              return order == 0 ? b.id.compareTo(a.id) : order;
            });
    }
    return _matching;
  }

  Future<CaseRecordPage> recordPage(
    ArchiveModule module, {
    String query = '',
    String retention = '',
    int page = 0,
    int size = 50,
  }) async {
    if (size < 1 || size > 200 || page < 0) {
      throw ArgumentError('Некоректна сторінка.');
    }
    if (!canReadModule(profile, module)) return const CaseRecordPage([], 0, 0);
    final generation = _generation;
    final local = store;
    if (_cacheReady && local is RecordPageStore) {
      final result = await (local as RecordPageStore).readRecordPage(
        RecordPageRequest(
          account: cacheKey,
          module: module.name,
          search: query,
          retention: retention,
          page: page,
          size: size,
        ),
      );
      if (generation != _generation || !canReadModule(profile, module)) {
        return const CaseRecordPage([], 0, 0);
      }
      return CaseRecordPage(
        result.records.map(CaseRecord.fromJson).toList(),
        result.total,
        result.page,
      );
    }
    final result = matchingRecords(module, query, retention);
    final last = result.isEmpty ? 0 : (result.length - 1) ~/ size;
    final current = page > last ? last : page;
    return CaseRecordPage(
      result.skip(current * size).take(size).toList(),
      result.length,
      current,
    );
  }

  Future<dynamic> request(
    String method, [
    Map<String, dynamic> args = const {},
  ]) async {
    return requestTo('archive', method, args);
  }

  Future<dynamic> requestTo(
    String endpoint,
    String method,
    Map<String, dynamic> args,
  ) async {
    final task = activity.begin(archiveRequestLabel(method), priority: -1);
    try {
      final raw = await client
          .callServerEndpoint<String>(endpoint, method, args)
          .timeout(
            method == 'commitImport'
                ? const Duration(minutes: 5)
                : method == 'cancelImport'
                ? const Duration(seconds: 3)
                : const Duration(seconds: 20),
          );
      final response = raw.length > 65536
          ? await compute(_decodeArchiveJson, raw)
          : _decodeArchiveJson(raw);
      if (response['ok'] != true) {
        throw ArchiveFailure(
          response['error'] as String,
          denied: response['code'] == 'denied',
        );
      }
      return response['data'];
    } finally {
      activity.end(task);
    }
  }

  Future<void> restore() async {
    final task = activity.begin('Відкриття локальної бази Drift', priority: 1);
    try {
      final raw = await store.read(cacheKey);
      if (raw == null) return;
      final data = raw.length > 65536
          ? await compute(_decodeArchiveJson, raw)
          : _decodeArchiveJson(raw);
      if (data['schemaVersion'] != 1) return;
      profile = Map<String, dynamic>.from(data['profile'] as Map);
      records = (data['records'] as List)
          .map((v) => CaseRecord.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList();
      documents = (data['documents'] as List)
          .map((v) => Map<String, dynamic>.from(v as Map))
          .toList();
      documentFiles = Map<String, String>.from(data['files'] as Map? ?? {});
      audit = (data['audit'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      members = (data['members'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      syncedAt = DateTime.parse(data['syncedAt'] as String);
      _cacheReady = true;
      await attachments.restore();
    } catch (_) {
      notice = 'Локальний кеш не вдалося прочитати. Підключіться до сервера.';
    } finally {
      activity.end(task);
    }
  }

  Future<void> refresh() {
    if (_refreshInFlight != null) return _refreshInFlight!;
    late final Future<void> work;
    work = _refresh().whenComplete(() {
      if (identical(_refreshInFlight, work)) _refreshInFlight = null;
    });
    _refreshInFlight = work;
    return work;
  }

  Future<void> _refresh() async {
    final task = activity.begin(
      'Синхронізація · 1/5: перевірка доступу',
      priority: 1,
    );
    final epoch = _mutationEpoch;
    final generation = _generation;
    try {
      final nextProfile = Map<String, dynamic>.from(
        await request('profile') as Map,
      );
      if (generation != _generation) return;
      final accessChanged = [
        'role',
        'passwordChangeRequired',
        'courtAccess',
        'managementAccess',
      ].any((key) => profile[key] != nextProfile[key]);
      profile = nextProfile;
      if (accessChanged) await attachments.purgeUnauthorized();
      if (profile['role'] != 'admin') {
        audit = [];
        members = [];
      }
      // Purge revoked modules before attempting any further network requests.
      records = records.where((r) => canReadModule(profile, r.module)).toList();
      if (!canReadModule(profile, ArchiveModule.management)) {
        documents = [];
        documentFiles = {};
      }
      if (profile['passwordChangeRequired'] == true ||
          !['reader', 'editor', 'admin'].contains(profile['role'])) {
        records = [];
        documents = [];
        documentFiles = {};
        audit = [];
        members = [];
        _recordRevision = null;
        online = true;
        syncedAt = DateTime.now();
        notice = null;
        await _persist();
        return;
      }
      if (accessChanged) await _persist();
      activity.stage(task, 'Синхронізація · 2/5: перевірка змін справ');
      final revision =
          (await request('recordRevision') as Map)['revision'] as String;
      if (generation != _generation) return;
      final recordsChanged = revision != _recordRevision;
      final nextRecords = revision == _recordRevision
          ? records
          : <CaseRecord>[];
      var cursor = 0;
      while (revision != _recordRevision) {
        activity.stage(
          task,
          'Завантаження справ: ${nextRecords.length} записів',
        );
        final page = await request('records', {'afterId': cursor}) as List;
        if (generation != _generation) return;
        nextRecords.addAll(
          page.map(
            (v) => CaseRecord.fromJson(Map<String, dynamic>.from(v as Map)),
          ),
        );
        if (page.length < 250) break;
        cursor = nextRecords.last.id;
      }
      activity.stage(task, 'Синхронізація · 3/5: номенклатури та документи');
      final nextDocuments = (await request('documents') as List)
          .map((v) => Map<String, dynamic>.from(v as Map))
          .toList();
      if (generation != _generation) return;
      final nextFiles = <String, String>{};
      for (final doc in nextDocuments) {
        activity.stage(
          task,
          'Збереження документів для роботи без сервера',
          completed: nextFiles.length,
          total: nextDocuments.length,
        );
        final id = '${doc['id']}';
        nextFiles[id] =
            documentFiles[id] ??
            ((await request('downloadDocument', {'id': doc['id']})
                    as Map)['content']
                as String);
        if (generation != _generation) return;
      }
      activity.stage(
        task,
        'Синхронізація · 4/5: нові події журналу та користувачі',
      );
      final nextAudit = <Map<String, dynamic>>[];
      var nextMembers = <Map<String, dynamic>>[];
      if (profile['role'] == 'admin') {
        nextMembers = (await request('members') as List)
            .map((m) => Map<String, dynamic>.from(m as Map))
            .toList();
        var before = 0;
        final newestCached = audit.isEmpty ? 0 : audit.first['id'] as int;
        while (true) {
          final page =
              await request('auditEntries', {'beforeId': before, 'query': ''})
                  as Map;
          final items = (page['items'] as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          activity.stage(
            task,
            'Журнал аудиту: отримано ${nextAudit.length} нових подій',
          );
          nextAudit.addAll(items.where((e) => (e['id'] as int) > newestCached));
          if (generation != _generation) return;
          if (items.any((e) => (e['id'] as int) <= newestCached)) {
            nextAudit.addAll(audit);
            break;
          }
          if (page['hasMore'] != true || items.isEmpty) break;
          before = items.last['id'] as int;
        }
      }
      if (generation != _generation || epoch != _mutationEpoch) return;
      final dataChanged =
          recordsChanged ||
          accessChanged ||
          !_sameMetadata(documents, nextDocuments) ||
          !_sameMetadata(members, nextMembers) ||
          nextFiles.keys.any((id) => !documentFiles.containsKey(id)) ||
          audit.length != nextAudit.length ||
          (audit.isNotEmpty &&
              nextAudit.isNotEmpty &&
              audit.first['id'] != nextAudit.first['id']);
      records = nextRecords;
      _recordRevision = revision;
      documents = nextDocuments;
      documentFiles = nextFiles;
      audit = nextAudit;
      members = nextMembers;
      documentFiles.removeWhere(
        (k, _) => !documents.any((d) => '${d['id']}' == k),
      );
      online = true;
      syncedAt = DateTime.now();
      notice = null;
      activity.stage(
        task,
        dataChanged
            ? 'Синхронізація · 5/5: оновлення локальної бази Drift'
            : 'Підтвердження актуальності локальної копії',
      );
      await _persist(metadataOnly: !dataChanged);
      try {
        await attachments.synchronize();
      } catch (_) {
        notice = 'Не всі файли збережено локально. Повторіть оновлення.';
      }
    } on ArchiveFailure catch (e) {
      if (generation != _generation) return;
      online = false;
      notice = e.message;
      if (e.denied) await clear();
    } on ServerpodClientHttpException catch (e) {
      if (generation != _generation) return;
      online = false;
      if (e.statusCode == 401 || e.statusCode == 403) {
        await clear();
        notice = 'Сеанс завершився. Увійдіть знову.';
      } else {
        notice = 'Сервер повернув помилку. Доступна остання збережена копія.';
      }
    } catch (_) {
      if (generation != _generation) return;
      online = false;
      notice =
          'Немає зв’язку із сервером. Доступна остання збережена копія лише для читання.';
    } finally {
      activity.end(
        task,
        result: online
            ? 'Синхронізацію завершено'
            : 'Локальна копія · немає зв’язку із сервером',
      );
    }
  }

  Future<void> _persist({bool metadataOnly = false}) async {
    if (syncedAt == null) return;
    final generation = _generation;
    final local = store;
    if (metadataOnly && _cacheReady && local is SnapshotMetadataStore) {
      final updatedProfile = Map<String, dynamic>.from(profile);
      final timestamp = syncedAt!.toIso8601String();
      try {
        _cacheWrites = _cacheWrites.catchError((Object _) {}).then((_) async {
          if (generation == _generation) {
            await (local as SnapshotMetadataStore).updateMetadata(
              cacheKey,
              updatedProfile,
              timestamp,
            );
          }
        });
        await _cacheWrites;
      } catch (_) {
        _cacheReady = false;
        notice =
            'Не вдалося підтвердити стан локальної копії. Повторіть оновлення.';
      }
      return;
    }
    final snapshot = <String, dynamic>{
      'schemaVersion': 1,
      'profile': profile,
      'records': records.map((r) => r.toJson()).toList(),
      'documents': documents,
      'files': documentFiles,
      'audit': audit,
      'members': members,
      'syncedAt': syncedAt!.toIso8601String(),
    };
    try {
      _cacheWrites = _cacheWrites.catchError((Object _) {}).then((_) async {
        if (generation != _generation) return;
        final content =
            records.length + audit.length > 250 || documentFiles.isNotEmpty
            ? await compute(_encodeArchiveJson, snapshot)
            : _encodeArchiveJson(snapshot);
        if (generation != _generation) return;
        await store.write(cacheKey, content);
        if (generation == _generation) _cacheReady = true;
      });
      await _cacheWrites;
    } catch (_) {
      _cacheReady = false;
      notice =
          'Не вдалося оновити локальну копію. Після втрати зв’язку вона може бути застарілою.';
    }
  }

  Future<void> save(
    ArchiveModule module,
    Map<String, String> values,
    CaseRecord? record,
  ) async {
    _requireWrite(module);
    final task = activity.begin('Збереження справи на сервері', priority: 10);
    final generation = _generation;
    try {
      final saved = Map<String, dynamic>.from(
        await request('saveRecord', {
              'module': module.name,
              'valuesJson': jsonEncode(validateRecord(module, values)),
              'id': record?.id,
              'version': record?.version,
            })
            as Map,
      );
      if (generation != _generation) return;
      _mutationEpoch++;
      _recordRevision = null;
      final updated = CaseRecord.fromJson(saved);
      lastSaveMerged = saved['merged'] == true;
      final removed = record != null && record.id != updated.id
          ? [record.id]
          : <int>[];
      records = [
        for (final current in records)
          if (current.id != updated.id && !removed.contains(current.id))
            current,
        updated,
      ];
      activity.stage(task, 'Оновлення зміненої справи в локальній базі Drift');
      final local = store;
      if (_cacheReady && local is RecordPatchStore) {
        try {
          _cacheWrites = _cacheWrites.catchError((Object _) {}).then((_) async {
            if (generation == _generation) {
              await (local as RecordPatchStore).applyRecordPatch(
                cacheKey,
                updated.toJson(),
                removed,
              );
            }
          });
          await _cacheWrites;
        } catch (_) {
          _cacheReady = false;
          notice =
              'Справу збережено на сервері, але локальну копію не вдалося оновити. Натисніть «Оновити дані».';
        }
      } else {
        await _persist();
      }
      if (lastSaveMerged) await attachments.synchronize();
      activity.end(task, result: 'Справу збережено');
    } catch (_) {
      activity.end(task, result: 'Не вдалося зберегти справу');
      rethrow;
    } finally {
      activity.end(task);
    }
  }

  Future<int> importRows(
    ArchiveModule module,
    List<Map<String, String>> rows, {
    void Function(int processed, int total)? onProgress,
    bool Function()? isCancelled,
    bool replaceExisting = false,
    List<String> sourceNames = const [],
  }) async {
    _requireWrite(module);
    if (rows.isEmpty) throw const ArchiveFailure('Немає записів для імпорту.');
    final task = activity.begin('Підготовка імпорту на сервері', priority: 10);
    try {
      final job =
          await request('beginImport', {
                'module': module.name,
                'replaceExisting': replaceExisting,
                'sourceNames': sourceNames,
              })
              as Map;
      final jobId = job['jobId'] as int;
      final generation = _generation;
      var offset = 0;
      var batch = <String>[];
      var size = 0;
      void checkCancelled() {
        if (generation != _generation || isCancelled?.call() == true) {
          throw const ArchiveImportCancelled();
        }
      }

      Future<void> send() async {
        checkCancelled();
        _requireWrite(module);
        await request('appendImportRows', {
          'jobId': jobId,
          'offset': offset,
          'rows': batch,
        });
        offset += batch.length;
        batch = [];
        size = 0;
        activity.stage(
          task,
          'Передавання записів імпорту',
          completed: offset,
          total: rows.length,
        );
        onProgress?.call(offset, rows.length);
      }

      try {
        for (final row in rows) {
          final encoded = jsonEncode(row);
          final bytes = utf8.encode(encoded).length;
          if (batch.isNotEmpty &&
              (batch.length >= 250 || size + bytes > 256 * 1024)) {
            await send();
          }
          batch.add(encoded);
          size += bytes;
        }
        if (batch.isNotEmpty) await send();
        checkCancelled();
        activity.stage(
          task,
          'Збереження, об’єднання та аудит імпортованих справ',
        );
        final data = await request('commitImport', {'jobId': jobId}) as Map;
        lastImportSummary = Map<String, dynamic>.from(data);
        activity.stage(task, 'Оновлення локальної копії після імпорту');
        await refresh();
        return data['count'] as int;
      } catch (_) {
        // A lost commit response may still mean success. Cancellation also reports
        // the durable status, so the client never retries an already committed file.
        try {
          final status = await request('cancelImport', {'jobId': jobId}) as Map;
          if (status['cancelled'] == false) {
            lastImportSummary = Map<String, dynamic>.from(status);
            activity.stage(task, 'Оновлення локальної копії після імпорту');
            await refresh();
            return status['count'] as int;
          }
        } catch (_) {
          /* Connection loss: staged rows expire on the server. */
        }
        rethrow;
      }
    } finally {
      activity.end(task);
    }
  }

  Future<List<Map<String, dynamic>>> related(CaseRecord record) async {
    if (!online) {
      final participants = (record.values['participants'] ?? '')
          .split(RegExp(r'[;\n]+'))
          .map(normalizeHeader)
          .where((v) => v.isNotEmpty)
          .toSet();
      final candidates = records.where(
        (r) => r.module == ArchiveModule.court && r.id != record.id,
      );
      final same = candidates
          .where((r) => r.reference == record.reference)
          .toList();
      final other = candidates.where(
        (r) =>
            r.reference != record.reference &&
            (r.values['participants'] ?? '')
                .split(RegExp(r'[;\n]+'))
                .map(normalizeHeader)
                .any(participants.contains),
      );
      return [...same, ...other]
          .map(
            (r) => {
              'id': r.id,
              'reference': r.reference,
              'proceeding': r.values['proceedingNumber'] ?? '',
            },
          )
          .toList();
    }
    return (await request('relatedRecords', {'id': record.id}) as List)
        .map((r) => Map<String, dynamic>.from(r as Map))
        .toList();
  }

  Future<List<int>> download(int id) async {
    final cached = documentFiles['$id'];
    if (cached != null) return base64Decode(cached);
    if (!online) {
      throw const ArchiveFailure(
        'Цей документ ще не збережено локально. Потрібне підключення до сервера.',
      );
    }
    final data = await request('downloadDocument', {'id': id}) as Map;
    documentFiles['$id'] = data['content'] as String;
    await _persist();
    return base64Decode(documentFiles['$id']!);
  }

  Future<void> upload(
    String title,
    String name,
    int year,
    List<int> bytes,
  ) async {
    _requireWrite(ArchiveModule.management);
    await request('uploadDocument', {
      'title': title,
      'fileName': name,
      'year': year,
      'contentBase64': base64Encode(bytes),
    });
    await refresh();
  }

  Future<void> deleteRecord(CaseRecord record) async {
    _requireWrite(record.module);
    await request('deleteRecord', {'id': record.id, 'version': record.version});
    await refresh();
  }

  Future<void> restoreRecord(int id) async {
    if (!online) {
      throw const ArchiveFailure('Без зв’язку із сервером зміни недоступні.');
    }
    await request('restoreRecord', {'id': id});
    await refresh();
  }

  Future<void> deleteDocument(int id) async {
    _requireWrite(ArchiveModule.management);
    await request('deleteDocument', {'id': id});
    await refresh();
  }

  Future<void> restoreDocument(int id) async {
    _requireWrite(ArchiveModule.management);
    await request('restoreDocument', {'id': id});
    await refresh();
  }

  void _requireWrite(ArchiveModule module) {
    if (!online) {
      throw const ArchiveFailure('Без зв’язку із сервером зміни недоступні.');
    }
    if (!canWriteModule(profile, module)) {
      throw const ArchiveFailure('Немає прав на редагування.');
    }
  }

  Future<void> prepareForUpdate() async {
    _generation++;
    await attachments.prepareForUpdate();
    await _cacheWrites.catchError((Object _) {});
  }

  Future<void> clear() async {
    _generation++;
    await attachments.clear();
    _cacheReady = false;
    _recordRevision = null;
    profile = {};
    records = [];
    documents = [];
    documentFiles = {};
    audit = [];
    members = [];
    syncedAt = null;
    _cacheWrites = _cacheWrites
        .catchError((Object _) {})
        .then((_) => store.remove(cacheKey));
    await _cacheWrites;
  }
}
