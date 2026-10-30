import 'dart:convert';
import 'dart:typed_data';
import 'package:archive_server/src/generated/protocol.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

Map<String, dynamic> data(String raw) =>
    Map<String, dynamic>.from(jsonDecode(raw)['data'] as Map);
void main() {
  withServerpod('Administrator archive cleanup', (sessions, endpoints) {
    const adminId = '550e8400-e29b-41d4-a716-446655440021';
    const readerId = '550e8400-e29b-41d4-a716-446655440022';
    final admin = sessions.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(adminId, {}),
    );
    final reader = sessions.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(readerId, {}),
    );
    final session = sessions.build();
    setUp(() async {
      await ArchiveMember.db.insertRow(
        session,
        ArchiveMember(
          userId: adminId,
          email: '',
          login: 'admin',
          displayName: 'Admin',
          role: 'admin',
        ),
      );
      await ArchiveMember.db.insertRow(
        session,
        ArchiveMember(
          userId: readerId,
          email: '',
          login: 'reader',
          displayName: 'Reader',
          role: 'reader',
          courtAccess: true,
        ),
      );
      final saved = data(
        await endpoints.archive.saveRecord(
          admin,
          'court',
          jsonEncode({'caseNumber': 'PURGE/1'}),
          null,
          null,
        ),
      );
      final attachment = await ArchiveAttachment.db.insertRow(
        session,
        ArchiveAttachment(
          recordId: saved['id'] as int,
          fileName: 'test.pdf',
          byteLength: 3,
          chunkCount: 1,
          status: 'ready',
          createdBy: adminId,
        ),
      );
      await ArchiveAttachmentChunk.db.insertRow(
        session,
        ArchiveAttachmentChunk(
          attachmentId: attachment.id!,
          chunkIndex: 0,
          content: ByteData.sublistView(Uint8List.fromList([1, 2, 3])),
        ),
      );
      await ArchiveDocument.db.insertRow(
        session,
        ArchiveDocument(
          title: 'Номенклатура',
          fileName: 'test.docx',
          kind: 'nomenclature',
          year: 2026,
          content: ByteData(3),
          createdBy: adminId,
        ),
      );
      final job = await ArchiveImportJob.db.insertRow(
        session,
        ArchiveImportJob(userId: adminId, module: 'court'),
      );
      await ArchiveImportRow.db.insertRow(
        session,
        ArchiveImportRow(
          jobId: job.id!,
          identityKey: 'staged',
          reference: '2',
          proceeding: '',
          valuesJson: '{}',
        ),
      );
    });

    test(
      'requires a current administrator and exact destructive confirmation',
      () async {
        await expectLater(
          endpoints.archiveMaintenance.clearArchive(reader, 'ОЧИСТИТИ АРХІВ'),
          throwsA(isA<ArchiveAuthException>()),
        );
        await expectLater(
          endpoints.archiveMaintenance.clearArchive(admin, ''),
          throwsA(isA<ArchiveAuthException>()),
        );
        await expectLater(
          endpoints.archiveMaintenance.summary(reader),
          throwsA(isA<ArchiveAuthException>()),
        );
        expect(await ArchiveRecord.db.count(session), 1);
        expect(await ArchiveAttachmentChunk.db.count(session), 1);
        expect(await ArchiveAudit.db.count(session), 1);
      },
    );

    test(
      'delete all cards cascades to file chunks and staging while preserving nomenclatures and audit',
      () async {
        final summary = data(await endpoints.archiveMaintenance.summary(admin));
        expect(summary, {'records': 1, 'files': 1, 'documents': 1, 'audit': 1});
        final baseline =
            data(await endpoints.archiveSync.changes(reader, -1, 0))['cursor']
                as int;
        final revision = data(
          await endpoints.archive.recordRevision(reader),
        )['revision'];
        await endpoints.archiveMaintenance.clearRecords(
          admin,
          'ВИДАЛИТИ ВСІ СПРАВИ',
        );
        expect(
          data(await endpoints.archive.recordRevision(reader))['revision'],
          isNot(revision),
        );
        expect(await ArchiveRecord.db.count(session), 0);
        expect(await ArchiveAttachment.db.count(session), 0);
        expect(await ArchiveAttachmentChunk.db.count(session), 0);
        expect(await ArchiveImportJob.db.count(session), 0);
        expect(await ArchiveImportRow.db.count(session), 0);
        expect(await ArchiveDocument.db.count(session), 1);
        expect(await ArchiveAudit.db.count(session), 3);
        expect(
          data(
            await endpoints.archiveSync.changes(reader, baseline, 0),
          )['reset'],
          true,
        );
      },
    );

    test(
      'full cleanup leaves audit empty and invalidates old caches even after newer writes overtake them',
      () async {
        final baseline =
            data(await endpoints.archiveSync.changes(reader, -1, 0))['cursor']
                as int;
        await endpoints.archiveMaintenance.clearArchive(
          admin,
          'ОЧИСТИТИ АРХІВ',
        );
        expect(await ArchiveRecord.db.count(session), 0);
        expect(await ArchiveDocument.db.count(session), 0);
        expect(await ArchiveAttachmentChunk.db.count(session), 0);
        expect(await ArchiveImportRow.db.count(session), 0);
        expect(await ArchiveAudit.db.count(session), 0);
        expect(await ArchiveMember.db.count(session), 2);
        final reset =
            data(await endpoints.archiveSync.changes(reader, -1, 0))['cursor']
                as int;
        expect(reset, greaterThan(baseline));
        await endpoints.archive.saveRecord(
          admin,
          'court',
          jsonEncode({'caseNumber': 'NEW/1'}),
          null,
          null,
        );
        expect(
          data(
            await endpoints.archiveSync.changes(reader, baseline, 0),
          )['reset'],
          true,
        );
        final next = data(
          await endpoints.archiveSync.changes(reader, reset, 0),
        );
        expect(
          (next['items'] as List).single['record']['values']['caseNumber'],
          'NEW/1',
        );
      },
    );
  });
}
