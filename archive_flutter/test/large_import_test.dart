import 'dart:convert';
import 'package:archive_client/archive_client.dart';
import 'package:archive_shared/archive_shared.dart';
import 'package:archive_flutter/data/archive_repository.dart';
import 'package:archive_flutter/data/workbook_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'archive_repository_test.dart' show TestClient, MemoryStore;

class ImportClient extends TestClient {
  int staged = 0;
  int commits = 0;
  bool loseCommitResponse = false;
  final batchSizes = <int>[];
  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) async {
    dynamic data;
    switch (method) {
      case 'beginImport':
        data = {'jobId': 1};
      case 'appendImportRows':
        expect(args['offset'], staged);
        final count = (args['rows'] as List).length;
        batchSizes.add(count);
        staged += count;
        data = {'received': staged};
      case 'commitImport':
        commits++;
        if (loseCommitResponse) {
          throw const ServerpodClientNetworkException(
            'Response lost after commit',
          );
        }
        data = {'count': staged};
      case 'cancelImport':
        data = {'cancelled': commits == 0, 'count': staged};
        if (commits == 0) staged = 0;
      default:
        return super.callServerEndpoint<T>(
          endpoint,
          method,
          args,
          authenticated: authenticated,
        );
    }
    return jsonEncode({'ok': true, 'data': data}) as T;
  }
}

void main() {
  List<Map<String, String>> rows(int n) =>
      List.generate(n, (i) => {'caseNumber': 'ТЕСТ/$i'});
  Future<ArchiveRepository> repo(ImportClient client) async {
    final repository = ArchiveRepository(
      client: client,
      store: MemoryStore(),
      server: 'test',
      userId: 'one',
    );
    await repository.refresh();
    return repository;
  }

  test('preview accepts thousands of rows without a row limit', () {
    final sheet = WorkbookSheet('Дані', {
      1: {0: const WorkbookCell('Справа №')},
      for (var i = 0; i < 6001; i++) i + 2: {0: WorkbookCell('ТЕСТ/$i')},
    }, false);
    final preview = WorkbookService().preview(sheet, ArchiveModule.court, {
      0: 'caseNumber',
    });
    expect(preview.errors, isEmpty);
    expect(preview.records, hasLength(6001));
  });
  test(
    'an entire file larger than 500 rows commits once after all batches',
    () async {
      final client = ImportClient();
      final repository = await repo(client);
      final progress = <int>[];
      expect(
        await repository.importRows(
          ArchiveModule.court,
          rows(1201),
          onProgress: (done, _) => progress.add(done),
        ),
        1201,
      );
      expect(client.commits, 1);
      expect(client.batchSizes, hasLength(5));
      expect(progress.last, 1201);
    },
  );
  test('cancelling after a batch leaves no committed rows', () async {
    final client = ImportClient();
    final repository = await repo(client);
    var cancel = false;
    await expectLater(
      repository.importRows(
        ArchiveModule.court,
        rows(1201),
        onProgress: (_, _) => cancel = true,
        isCancelled: () => cancel,
      ),
      throwsA(isA<ArchiveImportCancelled>()),
    );
    expect(client.commits, 0);
    expect(client.staged, 0);
  });
  test(
    'a lost successful commit response is recovered without importing twice',
    () async {
      final client = ImportClient()..loseCommitResponse = true;
      final repository = await repo(client);
      expect(
        await repository.importRows(ArchiveModule.court, rows(1201)),
        1201,
      );
      expect(client.commits, 1);
    },
  );
}
