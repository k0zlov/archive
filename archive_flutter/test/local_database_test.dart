import 'dart:convert';
import 'dart:io';
import 'package:archive_flutter/data/local_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> snapshot({bool revoked = false}) => {
    'profile': {'role': 'admin'},
    'syncedAt': '2026-10-29T10:00:00Z',
    'records': revoked
        ? []
        : [
            {
              'id': 1,
              'module': 'court',
              'version': 1,
              'values': {'caseNumber': '001'},
              'updatedAt': '2026-10-29T10:00:00Z',
            },
          ],
    'documents': revoked
        ? []
        : [
            {'id': 2, 'title': 'Номенклатура', 'fileName': 'a.docx'},
          ],
    'files': revoked
        ? {}
        : {
            '2': base64Encode([1, 2, 3]),
          },
    'audit': revoked
        ? []
        : [
            {'id': 3, 'action': 'record.create'},
          ],
    'members': revoked
        ? []
        : [
            {'id': 4, 'email': 'admin@example.test'},
          ],
  };
  test(
    'Drift persists an isolated full snapshot, survives reopening and removes revoked data',
    () async {
      final dir = await Directory.systemTemp.createTemp('archive-drift-test');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/local.sqlite');
      var database = ArchiveLocalDatabase(NativeDatabase(file));
      await database.replaceSnapshot('account-one', jsonEncode(snapshot()));
      await database.replaceSnapshot(
        'account-two',
        jsonEncode(snapshot(revoked: true)),
      );
      await database.close();
      database = ArchiveLocalDatabase(NativeDatabase(file));
      addTearDown(() => database.close());
      final restored =
          jsonDecode((await database.readSnapshot('account-one'))!) as Map;
      expect((restored['records'] as List).single['values'], {
        'caseNumber': '001',
      });
      expect(base64Decode((restored['files'] as Map)['2'] as String), [
        1,
        2,
        3,
      ]);
      expect(restored['audit'], hasLength(1));
      expect(restored['members'], hasLength(1));
      expect(
        (jsonDecode((await database.readSnapshot('account-two'))!)
            as Map)['records'],
        isEmpty,
      );
      await expectLater(
        database.replaceSnapshot(
          'account-one',
          jsonEncode({
            ...snapshot(),
            'records': [
              {'id': 'invalid'},
            ],
          }),
        ),
        throwsA(anything),
      );
      expect(
        (jsonDecode((await database.readSnapshot('account-one'))!)
            as Map)['records'],
        hasLength(1),
      );
      await database.replaceSnapshot(
        'account-one',
        jsonEncode(snapshot(revoked: true)),
      );
      final revoked =
          jsonDecode((await database.readSnapshot('account-one'))!) as Map;
      expect(revoked['records'], isEmpty);
      expect(revoked['files'], isEmpty);
      expect(revoked['audit'], isEmpty);
      await database.removeSnapshot('account-one');
      expect(await database.readSnapshot('account-one'), isNull);
      expect(await database.readSnapshot('account-two'), isNotNull);
    },
  );
}
