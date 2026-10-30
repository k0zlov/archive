import 'dart:async';
import 'dart:typed_data';
import 'package:archive_flutter/data/archive_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'archive_repository_test.dart' show TestClient, MemoryStore;

class WaitingStore extends MemoryStore {
  Completer<void>? gate;
  final started = Completer<void>();
  @override
  Future<void> write(String key, String value) async {
    if (gate != null) {
      if (!started.isCompleted) started.complete();
      await gate!.future;
    }
    await super.write(key, value);
  }
}

void main() {
  test(
    'update preparation waits for pending disk writes and preserves the authorized archive and attachment cache',
    () async {
      final store = WaitingStore();
      final repository = ArchiveRepository(
        client: TestClient(),
        store: store,
        server: 'test',
        userId: 'one',
      );
      await repository.refresh();
      await repository.attachments.cache.syncAttachments(repository.cacheKey, [
        {
          'id': 1,
          'recordId': 1,
          'module': 'court',
          'fileName': 'Матеріали.pdf',
          'byteLength': 3,
          'chunkCount': 1,
        },
      ]);
      await repository.attachments.cache.putAttachmentChunk(
        repository.cacheKey,
        1,
        0,
        Uint8List.fromList([1, 2, 3]),
      );
      await repository.attachments.cache.completeAttachment(
        repository.cacheKey,
        1,
      );
      store.gate = Completer<void>();
      final refresh = repository.refresh();
      await store.started.future;
      var prepared = false;
      final prepare = repository.prepareForUpdate().then(
        (_) => prepared = true,
      );
      await Future<void>.delayed(Duration.zero);
      expect(prepared, isFalse);
      store.gate!.complete();
      await refresh;
      await prepare;
      expect(store.data[repository.cacheKey], isNotNull);
      expect(repository.profile['role'], 'editor');
      expect(repository.records.single.reference, '001/26');
      expect(
        await repository.attachments.cache.readAttachmentChunk(
          repository.cacheKey,
          1,
          0,
        ),
        [1, 2, 3],
      );
      expect(
        (await repository.attachments.cache.readAttachments(
          repository.cacheKey,
        )).single['cached'],
        isTrue,
      );
      repository.attachments.dispose();
      repository.activity.dispose();
    },
  );
}
