import 'dart:convert';
import 'dart:io';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:archive_shared/archive_shared.dart';
import 'package:archive_server/src/generated/protocol.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

Map<String, dynamic> response(String value) =>
    jsonDecode(value) as Map<String, dynamic>;
Map<String, dynamic> data(String value) =>
    response(value)['data'] as Map<String, dynamic>;

void main() {
  withServerpod('Given the archive with per-user module permissions', (
    sessions,
    endpoints,
  ) {
    const editorId = '550e8400-e29b-41d4-a716-446655440001';
    const readerId = '550e8400-e29b-41d4-a716-446655440002';
    const adminId = '550e8400-e29b-41d4-a716-446655440003';
    final editor = sessions.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(editorId, {}),
    );
    final reader = sessions.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(readerId, {}),
    );
    final admin = sessions.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(adminId, {}),
    );
    final session = sessions.build();
    setUpAll(
      () => session.serverpod.initializeAuthServices(
        tokenManagerBuilders: [
          JwtConfig(
            algorithm: JwtAlgorithm.hmacSha512(
              SecretKey('archive-isolated-integration-tests-only'),
            ),
            refreshTokenHashPepper: 'archive-test-refresh-pepper',
          ),
        ],
        identityProviderBuilders: [
          EmailIdpConfig(secretHashPepper: 'archive-test-password-pepper'),
        ],
      ),
    );
    late ArchiveMember readerMember;
    setUp(() async {
      await ArchiveMember.db.insertRow(
        session,
        ArchiveMember(
          userId: editorId,
          email: 'editor@example.test',
          displayName: 'Редактор',
          role: 'editor',
          courtAccess: true,
        ),
      );
      readerMember = await ArchiveMember.db.insertRow(
        session,
        ArchiveMember(
          userId: readerId,
          email: 'reader@example.test',
          displayName: 'Читач',
          role: 'reader',
          courtAccess: true,
        ),
      );
      await ArchiveMember.db.insertRow(
        session,
        ArchiveMember(
          userId: adminId,
          email: 'admin@example.test',
          displayName: 'Адміністратор',
          role: 'admin',
        ),
      );
    });
    test('when unauthenticated then archive records require login', () async {
      await expectLater(
        endpoints.archive.records(sessions, 0),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });
    test(
      'when a reader writes or editor crosses module boundary then access is denied',
      () async {
        final deniedWrite = response(
          await endpoints.archive.saveRecord(
            reader,
            'court',
            jsonEncode({'caseNumber': '1'}),
            null,
            null,
          ),
        );
        final deniedModule = response(
          await endpoints.archive.saveRecord(
            editor,
            'management',
            jsonEncode({'caseIndex': '1', 'title': 'Накази'}),
            null,
            null,
          ),
        );
        expect(deniedWrite['code'], 'denied');
        expect(deniedModule['code'], 'denied');
        expect(await ArchiveRecord.db.count(session), 0);
      },
    );
    test(
      'when a card changes then stale versions cannot overwrite it',
      () async {
        final first = data(
          await endpoints.archive.saveRecord(
            editor,
            'court',
            jsonEncode({'caseNumber': '001/26', 'judge': 'Суддя А'}),
            null,
            null,
          ),
        );
        final updated = data(
          await endpoints.archive.saveRecord(
            editor,
            'court',
            jsonEncode({'caseNumber': '001/26', 'judge': 'Суддя Б'}),
            first['id'] as int,
            1,
          ),
        );
        expect(updated['version'], 2);
        final stale = response(
          await endpoints.archive.saveRecord(
            editor,
            'court',
            jsonEncode({'caseNumber': '001/26', 'judge': 'Суддя В'}),
            first['id'] as int,
            1,
          ),
        );
        expect(stale['ok'], false);
        expect(
          (await ArchiveRecord.db.findById(
            session,
            first['id'] as int,
          ))!.valuesJson,
          contains('Суддя Б'),
        );
      },
    );
    test(
      'existing imported cards are supplemented and new cards are added',
      () async {
        await endpoints.archive.saveRecord(
          editor,
          'court',
          jsonEncode({'caseNumber': 'existing'}),
          null,
          null,
        );
        final result = response(
          await endpoints.archive.importRecords(editor, 'court', [
            jsonEncode({'caseNumber': 'new'}),
            jsonEncode({'caseNumber': 'existing'}),
          ]),
        );
        expect(result['ok'], true);
        expect(await ArchiveRecord.db.count(session), 2);
        expect(
          await ArchiveRecord.db.findFirstRow(
            session,
            where: (t) => t.reference.equals('new'),
          ),
          isNotNull,
        );
      },
    );
    test('when imported data is invalid then no records are written', () async {
      final result = response(
        await endpoints.archive.importRecords(editor, 'court', [
          jsonEncode({'caseNumber': 'one'}),
          jsonEncode({'caseNumber': 'two', 'receivedDate': '31.02.2026'}),
        ]),
      );
      expect(result['code'], 'validation');
      expect(await ArchiveRecord.db.count(session), 0);
    });
    test(
      'when module access is revoked then subsequent reads and writes are denied',
      () async {
        final result = response(
          await endpoints.archive.setMemberAccess(
            admin,
            readerMember.id!,
            'blocked',
            true,
            true,
          ),
        );
        expect(result['ok'], true);
        expect(
          response(await endpoints.archive.records(reader, 0))['code'],
          'denied',
        );
        expect(
          response(await endpoints.archive.members(reader))['code'],
          'denied',
        );
      },
    );
    test(
      'when a non-admin grants rights then existing permissions stay intact',
      () async {
        expect(
          response(
            await endpoints.archive.setMemberAccess(
              editor,
              readerMember.id!,
              'admin',
              true,
              true,
            ),
          )['code'],
          'denied',
        );
        expect(
          (await ArchiveMember.db.findById(session, readerMember.id!))!.role,
          'reader',
        );
      },
    );
    test(
      'large staged imports remain invisible until one idempotent commit',
      () async {
        final job =
            data(
                  await endpoints.archive.beginImport(
                    editor,
                    'court',
                    replaceExisting: false,
                    sourceNames: const [],
                  ),
                )['jobId']
                as int;
        for (var offset = 0; offset < 1201; offset += 250) {
          final end = offset + 250 < 1201 ? offset + 250 : 1201;
          final batch = [
            for (var i = offset; i < end; i++)
              jsonEncode({'caseNumber': 'large/$i'}),
          ];
          expect(
            data(
              await endpoints.archive.appendImportRows(
                editor,
                job,
                offset,
                batch,
              ),
            )['received'],
            end,
          );
        }
        expect(await ArchiveRecord.db.count(session), 0);
        expect(
          data(await endpoints.archive.commitImport(editor, job))['count'],
          1201,
        );
        expect(
          data(await endpoints.archive.commitImport(editor, job))['count'],
          1201,
        );
        expect(await ArchiveRecord.db.count(session), 1201);
        expect(await ArchiveImportRow.db.count(session), 0);
      },
    );
    test(
      'existing identities across staged batches merge successfully',
      () async {
        await endpoints.archive.saveRecord(
          editor,
          'court',
          jsonEncode({'caseNumber': 'existing'}),
          null,
          null,
        );
        final job =
            data(
                  await endpoints.archive.beginImport(
                    editor,
                    'court',
                    replaceExisting: false,
                    sourceNames: const [],
                  ),
                )['jobId']
                as int;
        await endpoints.archive.appendImportRows(editor, job, 0, [
          jsonEncode({'caseNumber': 'new'}),
        ]);
        await endpoints.archive.appendImportRows(editor, job, 1, [
          jsonEncode({'caseNumber': 'existing'}),
        ]);
        expect(
          data(await endpoints.archive.commitImport(editor, job))['unchanged'],
          1,
        );
        expect(await ArchiveRecord.db.count(session), 2);
        await endpoints.archive.cancelImport(editor, job);
        expect(await ArchiveImportRow.db.count(session), 0);
      },
    );
    test(
      'staged requests are idempotent and another account cannot append or commit',
      () async {
        final job =
            data(
                  await endpoints.archive.beginImport(
                    editor,
                    'court',
                    replaceExisting: false,
                    sourceNames: const [],
                  ),
                )['jobId']
                as int;
        final batch = [
          jsonEncode({'caseNumber': 'one'}),
        ];
        await endpoints.archive.appendImportRows(editor, job, 0, batch);
        expect(
          data(
            await endpoints.archive.appendImportRows(editor, job, 0, batch),
          )['received'],
          1,
        );
        expect(await ArchiveImportRow.db.count(session), 1);
        expect(
          response(
            await endpoints.archive.appendImportRows(reader, job, 1, [
              jsonEncode({'caseNumber': 'two'}),
            ]),
          )['code'],
          'denied',
        );
        expect(
          response(await endpoints.archive.commitImport(reader, job))['code'],
          'denied',
        );
        expect(
          data(await endpoints.archive.cancelImport(editor, job))['cancelled'],
          true,
        );
        expect(await ArchiveImportRow.db.count(session), 0);
        expect(await ArchiveRecord.db.count(session), 0);
      },
    );
    test(
      'when related records are requested then case matches precede participant matches and expose only references',
      () async {
        final source = data(
          await endpoints.archive.saveRecord(
            editor,
            'court',
            jsonEncode({
              'caseNumber': '20/26',
              'proceedingNumber': '1',
              'participants': 'Петренко Іван; Коваль Олена',
            }),
            null,
            null,
          ),
        );
        await endpoints.archive.saveRecord(
          editor,
          'court',
          jsonEncode({
            'caseNumber': '20/26',
            'proceedingNumber': '2',
            'notes': 'Не повертати зайві поля',
          }),
          null,
          null,
        );
        await endpoints.archive.saveRecord(
          editor,
          'court',
          jsonEncode({'caseNumber': '30/26', 'participants': 'Петренко Іван'}),
          null,
          null,
        );
        await endpoints.archive.saveRecord(
          editor,
          'court',
          jsonEncode({'caseNumber': '40/26', 'participants': 'Інша особа'}),
          null,
          null,
        );
        final records =
            response(
                  await endpoints.archive.relatedRecords(
                    editor,
                    source['id'] as int,
                  ),
                )['data']
                as List;
        expect(records.map((r) => r['reference']), ['30/26']);
        expect((records.first as Map).keys.toSet(), {
          'id',
          'reference',
          'proceeding',
        });
      },
    );
    test(
      'multi-file chunks preserve participant roles and proceedings, skip missing numbers and support overwrite',
      () async {
        final first = data(
          await endpoints.archive.saveRecord(
            editor,
            'court',
            jsonEncode({'caseNumber': 'A/1', 'judge': 'Перший суддя'}),
            null,
            null,
          ),
        );
        final job =
            data(
                  await endpoints.archive.beginImport(
                    editor,
                    'court',
                    replaceExisting: false,
                    sourceNames: ['a.xlsx', 'b.xlsx'],
                  ),
                )['jobId']
                as int;
        await endpoints.archive.appendImportRows(editor, job, 0, [
          jsonEncode({
            'caseNumber': ' A/1 ',
            'judge': 'Новий суддя',
            ...participantValues([
              const CaseParticipant(
                'Олена',
                role: 'позивач',
                proceeding: '2/1',
              ),
            ]),
          }),
          jsonEncode({'proceedingNumber': 'без справи'}),
        ]);
        await endpoints.archive.appendImportRows(editor, job, 2, [
          jsonEncode({
            'caseNumber': 'A/1',
            'category': 'Нова категорія',
            ...participantValues([
              const CaseParticipant(
                'Іван',
                role: 'відповідач',
                proceeding: '2/2',
              ),
            ]),
          }),
        ]);
        final result = data(await endpoints.archive.commitImport(editor, job));
        expect(result, containsPair('skipped', 1));
        expect(result['merged'], 1);
        expect(result['updated'], 1);
        final saved = (await ArchiveRecord.db.findById(
          session,
          first['id'] as int,
        ))!;
        final values = Map<String, String>.from(
          jsonDecode(saved.valuesJson) as Map,
        );
        expect(values['judge'], 'Перший суддя');
        expect(values['category'], 'Нова категорія');
        expect(caseParticipants(values).map((p) => p.proceeding), [
          '2/1',
          '2/2',
        ]);
        expect(caseParticipants(values).map((p) => p.role), [
          'позивач',
          'відповідач',
        ]);
        final replace =
            data(
                  await endpoints.archive.beginImport(
                    editor,
                    'court',
                    replaceExisting: true,
                    sourceNames: [],
                  ),
                )['jobId']
                as int;
        await endpoints.archive.appendImportRows(editor, replace, 0, [
          jsonEncode({
            'caseNumber': 'A/1',
            'judge': 'Новий суддя',
            'category': '',
          }),
        ]);
        await endpoints.archive.commitImport(editor, replace);
        final replaced = Map<String, String>.from(
          jsonDecode(
                (await ArchiveRecord.db.findById(
                  session,
                  first['id'] as int,
                ))!.valuesJson,
              )
              as Map,
        );
        expect(replaced['judge'], 'Новий суддя');
        expect(replaced['category'], 'Нова категорія');
        expect(caseParticipants(replaced), hasLength(2));
      },
    );
    test(
      'deletion is permission checked, versioned, reversible and audited with snapshots',
      () async {
        final first = data(
          await endpoints.archive.saveRecord(
            editor,
            'court',
            jsonEncode({'caseNumber': 'DELETE/1'}),
            null,
            null,
          ),
        );
        final id = first['id'] as int;
        expect(
          response(await endpoints.archive.deleteRecord(reader, id, 1))['code'],
          'denied',
        );
        expect(
          response(await endpoints.archive.deleteRecord(editor, id, 0))['ok'],
          false,
        );
        expect(
          response(await endpoints.archive.deleteRecord(editor, id, 1))['ok'],
          true,
        );
        expect(
          response(await endpoints.archive.records(editor, 0))['data'],
          isEmpty,
        );
        final stored = (await ArchiveRecord.db.findById(session, id))!;
        expect(stored.deletedAt, isNotNull);
        final events =
            data(await endpoints.archive.auditEntries(admin, 0, ''))['items']
                as List;
        final deletion =
            events.firstWhere((e) => e['action'] == 'record.delete') as Map;
        expect(deletion['actor'], 'editor@example.test');
        expect((deletion['before'] as Map)['values'], {
          'caseNumber': 'DELETE/1',
        });
        expect((deletion['after'] as Map)['deletedAt'], isNotNull);
        expect(
          response(await endpoints.archive.auditEntries(reader, 0, ''))['code'],
          'denied',
        );
        expect(
          response(await endpoints.archive.restoreRecord(editor, id))['ok'],
          true,
        );
        expect(
          (await ArchiveRecord.db.findById(session, id))!.deletedAt,
          isNull,
        );
        expect(
          (response(await endpoints.archive.records(editor, 0))['data']
              as List),
          hasLength(1),
        );
      },
    );
    test(
      'legacy identity migration keeps every original row and merges participants without losing fields',
      () async {
        for (var n = 1; n <= 2; n++) {
          await ArchiveRecord.db.insertRow(
            session,
            ArchiveRecord(
              module: 'court',
              identityKey: 'legacy-$n',
              reference: '243/1',
              proceeding: '2/$n',
              valuesJson: jsonEncode({
                'caseNumber': '243/1',
                'proceedingNumber': '2/$n',
                'participants': n == 1 ? 'Олена' : 'Іван',
                if (n == 1) 'judge': 'Суддя',
                if (n == 2) 'category': 'Категорія',
              }),
              createdBy: editorId,
              updatedBy: editorId,
            ),
          );
        }
        await session.db.unsafeExecute(
          await File('tool/sql/merge_court_identities.sql').readAsString(),
        );
        final all = await ArchiveRecord.db.find(session);
        expect(all, hasLength(2));
        final active = all.where((r) => r.deletedAt == null).single;
        expect(active.identityKey, 'court:case:243/1');
        final values = jsonDecode(active.valuesJson) as Map;
        expect(values['judge'], 'Суддя');
        expect(values['category'], 'Категорія');
        expect(values['participants'], 'Олена\nІван');
        expect(values['proceedingNumber'], '2/1\n2/2');
        expect(
          (jsonDecode(all.singleWhere((r) => r.deletedAt != null).valuesJson)
              as Map)['participants'],
          'Іван',
        );
        expect(await ArchiveAudit.db.count(session), 3);
      },
    );
    test(
      'import preserves reversed dates with a warning and accepts structured participants',
      () async {
        final job =
            data(
                  await endpoints.archive.beginImport(
                    editor,
                    'court',
                    replaceExisting: false,
                    sourceNames: [],
                  ),
                )['jobId']
                as int;
        await endpoints.archive.appendImportRows(editor, job, 0, [
          jsonEncode({'caseNumber': 'valid'}),
          jsonEncode({'caseNumber': 'bad', 'receivedDate': '2026-10-10'}),
        ]);
        await endpoints.archive.appendImportRows(editor, job, 2, [
          jsonEncode({
            'caseNumber': 'bad',
            'hearingDate': '2026-01-01',
            ...participantValues([
              const CaseParticipant('Іван', role: 'позивач', proceeding: '2/1'),
            ]),
          }),
        ]);
        expect(
          data(await endpoints.archive.commitImport(editor, job))['warnings'],
          1,
        );
        expect(await ArchiveRecord.db.count(session), 2);
        final imported = (await ArchiveRecord.db.findFirstRow(
          session,
          where: (t) => t.reference.equals('bad'),
        ))!;
        final values = Map<String, String>.from(
          jsonDecode(imported.valuesJson) as Map,
        );
        expect(values['receivedDate'], '2026-10-10');
        expect(values['hearingDate'], '2026-01-01');
        expect(caseParticipants(values).single.role, 'позивач');
      },
    );
    test(
      'nomenclature deletion keeps file bytes for restoration and audits metadata',
      () async {
        final created = data(
          await endpoints.archive.uploadDocument(
            admin,
            'Номенклатура',
            'n.docx',
            2026,
            base64Encode([1, 2, 3]),
          ),
        );
        final id = created['id'] as int;
        expect(
          response(await endpoints.archive.deleteDocument(editor, id))['code'],
          'denied',
        );
        expect(
          response(await endpoints.archive.deleteDocument(admin, id))['ok'],
          true,
        );
        expect(
          response(await endpoints.archive.documents(admin))['data'],
          isEmpty,
        );
        expect(
          response(await endpoints.archive.downloadDocument(admin, id))['ok'],
          false,
        );
        expect(
          response(await endpoints.archive.restoreDocument(admin, id))['ok'],
          true,
        );
        expect(
          data(await endpoints.archive.downloadDocument(admin, id))['content'],
          base64Encode([1, 2, 3]),
        );
        final events = await ArchiveAudit.db.find(session);
        expect(events.map((e) => e.action), [
          'document.create',
          'document.delete',
          'document.restore',
        ]);
        expect(
          events.every(
            (e) =>
                !e.beforeJson.contains('content') &&
                !e.afterJson.contains('content'),
          ),
          true,
        );
      },
    );
    test(
      'record revisions change on edits and deletion but exclude inaccessible modules',
      () async {
        final initial = data(
          await endpoints.archive.recordRevision(editor),
        )['revision'];
        final created = data(
          await endpoints.archive.saveRecord(
            editor,
            'court',
            jsonEncode({'caseNumber': 'REV/1'}),
            null,
            null,
          ),
        );
        final first = data(
          await endpoints.archive.recordRevision(editor),
        )['revision'];
        expect(first, isNot(initial));
        await endpoints.archive.saveRecord(
          admin,
          'management',
          jsonEncode({'caseIndex': 'M/1', 'title': 'Накази'}),
          null,
          null,
        );
        expect(
          data(await endpoints.archive.recordRevision(editor))['revision'],
          first,
        );
        await endpoints.archive.deleteRecord(editor, created['id'] as int, 1);
        expect(
          data(await endpoints.archive.recordRevision(editor))['revision'],
          isNot(first),
        );
      },
    );
  });
}
