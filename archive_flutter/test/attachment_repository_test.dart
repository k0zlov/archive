import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive_flutter/data/archive_repository.dart';
import 'package:archive_flutter/data/cache_store_native.dart';
import 'package:archive_flutter/data/local_database.dart';
import 'package:archive_flutter/data/file_actions.dart';
import 'package:drift/native.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'archive_repository_test.dart';

class AttachmentClient extends TestClient {
  final metadata = <int, Map<String, dynamic>>{};
  final chunks = <int, List<Uint8List>>{};
  final ready = <int>{};
  int sequence = 0, downloads = 0, recordDownloads = 0;
  Completer<void>? downloadGate;
  bool failSecondChunk = false;
  final downloadStarted = Completer<void>();
  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) async {
    if (endpoint != 'attachment') {
      if (method == 'records') recordDownloads++;
      return super.callServerEndpoint<T>(
        endpoint,
        method,
        args,
        authenticated: authenticated,
      );
    }
    if (offline) throw StateError('offline');
    dynamic result;
    switch (method) {
      case 'list':
        result = ready.map((id) => metadata[id]!).toList();
      case 'begin':
        final id = ++sequence;
        metadata[id] = {
          'id': id,
          'recordId': args['recordId'],
          'module': 'court',
          'fileName': args['fileName'],
          'byteLength': args['byteLength'],
          'chunkCount': 0,
          'createdAt': '2026-10-29T10:00:00Z',
          'deletedAt': null,
        };
        chunks[id] = [];
        result = {'id': id, 'chunkSize': 256 * 1024};
      case 'append':
        if (failSecondChunk && args['chunkIndex'] == 1) {
          throw StateError('connection lost');
        }
        final id = args['id'] as int;
        final bytes = base64Decode(args['content'] as String);
        expect(bytes.length, lessThanOrEqualTo(256 * 1024));
        chunks[id]!.add(bytes);
        metadata[id]!['chunkCount'] = chunks[id]!.length;
        result = {'received': chunks[id]!.fold<int>(0, (a, b) => a + b.length)};
      case 'finish':
        final id = args['id'] as int;
        ready.add(id);
        result = metadata[id];
      case 'download':
        downloads++;
        if (!downloadStarted.isCompleted) downloadStarted.complete();
        if (downloadGate != null) await downloadGate!.future;
        result = {
          'content': base64Encode(
            chunks[args['id']]![args['chunkIndex'] as int],
          ),
        };
      case 'delete':
        ready.remove(args['id']);
        result = {};
      case 'restore':
        ready.add(args['id'] as int);
        result = {};
      case 'cancel':
        result = {};
      default:
        throw StateError(method);
    }
    return jsonEncode({'ok': true, 'data': result}) as T;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'large streamed upload persists binary Drift chunks and reopens completely offline without redownloading records',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'archive-files-test',
      );
      addTearDown(() => directory.delete(recursive: true));
      final store = DriftCacheStore(
        databasePath: () async => '${directory.path}/files.sqlite',
      );
      final client = AttachmentClient();
      ArchiveRepository repo() => ArchiveRepository(
        client: client,
        store: store,
        server: 'test',
        userId: 'one',
      );
      final online = repo();
      await online.refresh();
      final recordRequests = client.recordDownloads;
      final bytes = Uint8List.fromList(
        List.generate(600 * 1024 + 7, (i) => i % 253),
      );
      await online.attachments.upload(
        online.records.single,
        XFile.fromData(bytes, name: 'Скан.pdf', path: 'Скан.pdf'),
      );
      expect(client.chunks[1], hasLength(3));
      expect(client.recordDownloads, recordRequests);
      expect(online.attachments.files.single['cached'], true);
      await online.refresh();
      expect(client.downloads, 0);
      expect(online.attachments.files.single['cached'], true);
      client.offline = true;
      final offline = repo();
      await offline.restore();
      expect(offline.attachments.forRecord(1).single['fileName'], 'Скан.pdf');
      final actual = BytesBuilder();
      await for (final part in offline.attachments.content(1)) {
        actual.add(part);
      }
      expect(actual.takeBytes(), bytes);
      expect(client.downloads, 0);
      expect(await store.readAttachments('another-account'), isEmpty);
      expect(await store.readAttachmentChunk('another-account', 1, 0), isNull);
      await offline.clear();
      expect(await store.readAttachments(offline.cacheKey), isEmpty);
      expect(await store.readAttachmentChunk(offline.cacheKey, 1, 0), isNull);
    },
  );
  test(
    'revocation purges file contents and a late download after logout cannot recreate them',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'archive-files-race',
      );
      addTearDown(() => directory.delete(recursive: true));
      final store = DriftCacheStore(
        databasePath: () async => '${directory.path}/files.sqlite',
      );
      final client = AttachmentClient();
      final repo = ArchiveRepository(
        client: client,
        store: store,
        server: 'test',
        userId: 'one',
      );
      await repo.refresh();
      await repo.attachments.upload(
        repo.records.single,
        XFile.fromData(
          Uint8List.fromList([1, 2, 3]),
          name: 'a.pdf',
          path: 'a.pdf',
        ),
      );
      client.revoked = true;
      await repo.refresh();
      expect(repo.attachments.files, isEmpty);
      expect(await store.readAttachmentChunk(repo.cacheKey, 1, 0), isNull);
      client.revoked = false;
      client.downloadGate = Completer<void>();
      final refresh = repo.refresh();
      await client.downloadStarted.future;
      await repo.clear();
      client.downloadGate!.complete();
      await refresh;
      expect(await store.readAttachments(repo.cacheKey), isEmpty);
      expect(await store.readAttachmentChunk(repo.cacheKey, 1, 0), isNull);
      expect(await store.read(repo.cacheKey), isNull);
    },
  );
  test(
    'a failed upload discards private partial chunks from the local cache',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'archive-files-failure',
      );
      addTearDown(() => directory.delete(recursive: true));
      final store = DriftCacheStore(
        databasePath: () async => '${directory.path}/files.sqlite',
      );
      final client = AttachmentClient()..failSecondChunk = true;
      final repo = ArchiveRepository(
        client: client,
        store: store,
        server: 'test',
        userId: 'one',
      );
      await repo.refresh();
      await expectLater(
        repo.attachments.upload(
          repo.records.single,
          XFile.fromData(Uint8List(300 * 1024), path: 'partial.pdf'),
        ),
        throwsStateError,
      );
      expect(repo.attachments.files, isEmpty);
      expect(await store.readAttachmentChunk(repo.cacheKey, 1, 0), isNull);
    },
  );
  test(
    'incomplete cache is never marked ready, and main snapshots preserve file chunks',
    () async {
      final db = ArchiveLocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final file = {
        'id': 1,
        'recordId': 5,
        'module': 'court',
        'fileName': 'a.pdf',
        'byteLength': 3,
        'chunkCount': 2,
      };
      await db.syncAttachments('one', [file]);
      await db.putAttachmentChunk('one', 1, 0, Uint8List.fromList([1, 2]));
      await expectLater(db.completeAttachment('one', 1), throwsStateError);
      expect((await db.readAttachments('one')).single['cached'], false);
      await db.putAttachmentChunk('one', 1, 1, Uint8List.fromList([3]));
      await db.completeAttachment('one', 1);
      await db.replaceSnapshot(
        'one',
        jsonEncode({
          'schemaVersion': 1,
          'profile': {'role': 'reader'},
          'syncedAt': '2026-10-29T10:00:00Z',
          'records': [],
          'documents': [],
          'files': {},
          'audit': [],
          'members': [],
        }),
      );
      expect((await db.readAttachments('one')).single['cached'], true);
      expect(await db.readAttachmentChunk('one', 1, 1), [3]);
      await db.syncAttachments('one', []);
      expect(await db.readAttachmentChunk('one', 1, 0), isNull);
    },
  );
  test(
    'only document and image types are opened directly by the operating system',
    () {
      expect(canOpenAttachment('документ.PDF'), true);
      expect(canOpenAttachment('application.exe'), false);
      expect(canOpenAttachment('shortcut.lnk'), false);
      expect(canOpenAttachment('script.bat'), false);
    },
  );
}
