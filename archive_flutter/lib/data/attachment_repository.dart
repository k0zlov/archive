import 'dart:convert';
import 'dart:typed_data';
import 'package:archive_shared/archive_schema.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'archive_repository.dart';
import 'attachment_cache.dart';
import 'cache_store.dart';

String _encodePart(Uint8List bytes) => base64Encode(bytes);
Uint8List _decodePart(String content) => base64Decode(content);

class AttachmentRepository extends ChangeNotifier {
  AttachmentRepository(this.repository)
    : cache = repository.store is AttachmentCache
          ? repository.store as AttachmentCache
          : _FallbackAttachmentCache(repository.store);
  final ArchiveRepository repository;
  final AttachmentCache cache;
  List<Map<String, dynamic>> files = [];
  Future<void> _writes = Future.value();
  int _epoch = 0, _revision = 0;
  bool _disposed = false;
  bool _uploading = false;
  String get account => repository.cacheKey;
  List<Map<String, dynamic>> forRecord(int recordId) =>
      files.where((f) => f['recordId'] == recordId && _allowed(f)).toList()
        ..sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
  bool _allowed(Map<String, dynamic> file) => canReadModule(
    repository.profile,
    ArchiveModule.values.byName(file['module'] as String),
  );
  Future<dynamic> _request(
    String method, [
    Map<String, dynamic> args = const {},
  ]) => repository.requestTo('attachment', method, args);
  Future<void> _write(int epoch, Future<void> Function() work) {
    final next = _writes.catchError((Object _) {}).then((_) async {
      if (epoch == _epoch && !_disposed) await work();
    });
    _writes = next;
    return next;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> restore() async {
    final epoch = _epoch;
    final data = await cache.readAttachments(account);
    if (epoch != _epoch || _disposed) return;
    files = data.where(_allowed).toList();
    _notify();
  }

  Future<void> purgeUnauthorized() async {
    final epoch = ++_epoch;
    _revision++;
    final stored = await cache.readAttachments(account);
    if (epoch != _epoch || _disposed) return;
    files = stored.where(_allowed).toList();
    if (files.length != stored.length) {
      await _write(epoch, () => cache.syncAttachments(account, files));
    }
    _notify();
  }

  Future<void> synchronize({bool downloadFiles = true}) async {
    if (_uploading || _disposed) return;
    final epoch = _epoch, revision = _revision;
    final incoming = <Map<String, dynamic>>[];
    var cursor = 0;
    while (true) {
      final page = (await _request('list', {'afterId': cursor}) as List)
          .map((f) => Map<String, dynamic>.from(f as Map))
          .toList();
      if (epoch != _epoch || revision != _revision || _disposed) return;
      incoming.addAll(page.where(_allowed));
      if (page.length < 250) break;
      cursor = page.last['id'] as int;
    }
    final existing = {
      for (final file in files)
        file['id']: Map<String, dynamic>.from(file)..remove('cached'),
    };
    final changed =
        incoming.length != existing.length ||
        incoming.any((file) => !mapEquals(existing[file['id']], file));
    if (changed) {
      await _write(epoch, () async {
        if (revision == _revision) {
          await cache.syncAttachments(account, incoming);
        }
      });
    }
    if (epoch != _epoch || revision != _revision || _disposed) return;
    await restore();
    if (downloadFiles) {
      for (final file in List.of(files)) {
        if (epoch != _epoch || revision != _revision || _disposed) return;
        if (file['cached'] != true) await _download(file, epoch);
      }
      await restore();
    }
  }

  Future<void> upload(CaseRecord record, XFile source) async {
    if (!repository.online ||
        !canWriteModule(repository.profile, record.module)) {
      throw const ArchiveFailure('Немає доступу до додавання файлів.');
    }
    if (_uploading) {
      throw const ArchiveFailure('Дочекайтеся завершення завантаження.');
    }
    _uploading = true;
    final epoch = _epoch;
    _revision++;
    final task = repository.activity.begin('Завантаження файлу', priority: 10);
    int? id;
    var committed = false;
    try {
      final begin =
          await _request('begin', {
                'recordId': record.id,
                'fileName': source.name,
                'byteLength': await source.length(),
              })
              as Map;
      id = begin['id'] as int;
      final chunkSize = begin['chunkSize'] as int;
      var index = 0;
      var buffer = BytesBuilder(copy: false);
      Future<void> send(Uint8List bytes) async {
        if (epoch != _epoch || _disposed) {
          throw const ArchiveFailure('Сеанс завершено.');
        }
        final content = await compute(_encodePart, bytes);
        await _request('append', {
          'id': id,
          'chunkIndex': index,
          'content': content,
        });
        final part = index++;
        await _write(
          epoch,
          () => cache.putAttachmentChunk(account, id!, part, bytes),
        );
      }

      await for (final block in source.openRead()) {
        var offset = 0;
        while (offset < block.length) {
          final length = (chunkSize - buffer.length).clamp(
            0,
            block.length - offset,
          );
          buffer.add(Uint8List.sublistView(block, offset, offset + length));
          offset += length;
          if (buffer.length == chunkSize) {
            await send(buffer.takeBytes());
            buffer = BytesBuilder(copy: false);
          }
        }
      }
      if (buffer.isNotEmpty) await send(buffer.takeBytes());
      final metadata = Map<String, dynamic>.from(
        await _request('finish', {'id': id}) as Map,
      );
      committed = true;
      if (epoch != _epoch || _disposed) return;
      _revision++;
      files = [...files.where((f) => f['id'] != id), metadata];
      await _write(epoch, () async {
        await cache.syncAttachments(account, files);
        await cache.completeAttachment(account, id!);
      });
      await restore();
    } finally {
      if (!committed && id != null) {
        try {
          await _request('cancel', {'id': id});
        } catch (_) {
          /* A private interrupted upload expires on the server. */
        }
      }
      if (!committed && id != null) {
        try {
          await _write(epoch, () => cache.syncAttachments(account, files));
        } catch (_) {
          /* Retried on the next synchronization. */
        }
      }
      _uploading = false;
      _revision++;
      repository.activity.end(task);
    }
  }

  Future<void> _download(Map<String, dynamic> file, int epoch) async {
    if (!_allowed(file)) throw const ArchiveFailure('Немає доступу до файлу.');
    final id = file['id'] as int;
    for (var index = 0; index < (file['chunkCount'] as int); index++) {
      if (epoch != _epoch || _disposed) return;
      if (await cache.readAttachmentChunk(account, id, index) != null) continue;
      if (!repository.online) {
        throw const ArchiveFailure(
          'Файл ще не завантажено для роботи без сервера.',
        );
      }
      final response =
          await _request('download', {'id': id, 'chunkIndex': index}) as Map;
      final bytes = await compute(_decodePart, response['content'] as String);
      final part = index;
      await _write(
        epoch,
        () => cache.putAttachmentChunk(account, id, part, bytes),
      );
    }
    await _write(epoch, () => cache.completeAttachment(account, id));
  }

  Stream<Uint8List> content(int id) async* {
    final file = files.where((f) => f['id'] == id && _allowed(f)).firstOrNull;
    if (file == null) throw const ArchiveFailure('Файл недоступний.');
    final epoch = _epoch;
    final task = repository.activity.begin('Завантаження файлу', priority: 10);
    try {
      if (file['cached'] != true) {
        await _download(file, epoch);
        await restore();
      }
      for (var index = 0; index < (file['chunkCount'] as int); index++) {
        if (epoch != _epoch || !_allowed(file) || _disposed) {
          throw const ArchiveFailure('Сеанс завершено.');
        }
        final bytes = await cache.readAttachmentChunk(account, id, index);
        if (bytes == null) {
          throw const ArchiveFailure('Локальна копія файлу неповна.');
        }
        yield bytes;
      }
    } finally {
      repository.activity.end(task);
    }
  }

  Future<void> delete(int id) async {
    if (!repository.online) {
      throw const ArchiveFailure(
        'Зміни доступні після підключення до сервера.',
      );
    }
    final epoch = _epoch;
    await _request('delete', {'id': id});
    if (epoch != _epoch || _disposed) return;
    _revision++;
    files = files.where((f) => f['id'] != id).toList();
    await _write(epoch, () => cache.syncAttachments(account, files));
    _notify();
  }

  Future<void> restoreFile(int id) async {
    if (!repository.online) {
      throw const ArchiveFailure(
        'Зміни доступні після підключення до сервера.',
      );
    }
    final epoch = _epoch;
    await _request('restore', {'id': id});
    if (epoch != _epoch || _disposed) return;
    _revision++;
    await synchronize();
  }

  Future<void> prepareForUpdate() async {
    _epoch++;
    _revision++;
    await _writes.catchError((Object _) {});
  }

  Future<void> clear() async {
    _epoch++;
    _revision++;
    files = [];
    await _writes.catchError((Object _) {});
    if (cache is _FallbackAttachmentCache) {
      await (cache as _FallbackAttachmentCache).remove(account);
    }
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    _epoch++;
    super.dispose();
  }
}

/// Small fallback for browser storage and injected non-native test stores.
class _FallbackAttachmentCache implements AttachmentCache {
  _FallbackAttachmentCache(this.store);
  final CacheStore store;
  Future<Map<String, dynamic>> _read(String account) async =>
      jsonDecode(
            await store.read('$account-attachments') ??
                '{"files":[],"parts":{}}',
          )
          as Map<String, dynamic>;
  Future<void> _save(String account, Map<String, dynamic> data) =>
      store.write('$account-attachments', jsonEncode(data));
  Future<void> remove(String account) => store.remove('$account-attachments');
  @override
  Future<List<Map<String, dynamic>>> readAttachments(String account) async =>
      (await _read(account))['files']
          .map<Map<String, dynamic>>((f) => Map<String, dynamic>.from(f as Map))
          .toList();
  @override
  Future<void> syncAttachments(
    String account,
    List<Map<String, dynamic>> files,
  ) async {
    final data = await _read(account);
    final before = {for (final f in data['files'] as List) f['id']: f};
    final ids = files.map((f) => f['id']).toSet();
    data['files'] = [
      for (final file in files)
        {...file, 'cached': before[file['id']]?['cached'] == true},
    ];
    (data['parts'] as Map).removeWhere(
      (k, v) => !ids.contains(int.parse((k as String).split(':').first)),
    );
    await _save(account, data);
  }

  @override
  Future<void> putAttachmentChunk(
    String account,
    int id,
    int index,
    Uint8List bytes,
  ) async {
    final data = await _read(account);
    (data['parts'] as Map)['$id:$index'] = base64Encode(bytes);
    await _save(account, data);
  }

  @override
  Future<Uint8List?> readAttachmentChunk(
    String account,
    int id,
    int index,
  ) async {
    final value = (await _read(account))['parts']['$id:$index'] as String?;
    return value == null ? null : base64Decode(value);
  }

  @override
  Future<void> completeAttachment(String account, int id) async {
    final data = await _read(account);
    final file = (data['files'] as List).cast<Map>().singleWhere(
      (f) => f['id'] == id,
    );
    var size = 0;
    for (var i = 0; i < (file['chunkCount'] as int); i++) {
      final part = data['parts']['$id:$i'] as String?;
      if (part == null) throw StateError('Локальна копія файлу неповна.');
      size += base64Decode(part).length;
    }
    if (size != file['byteLength']) {
      throw StateError('Локальна копія файлу неповна.');
    }
    file['cached'] = true;
    await _save(account, data);
  }
}
