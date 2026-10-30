import 'dart:convert';
import 'dart:typed_data';
import 'package:archive_server/src/generated/protocol.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

Map<String, dynamic> _result(String value) =>
    jsonDecode(value) as Map<String, dynamic>;
Map<String, dynamic> _data(String value) =>
    _result(value)['data'] as Map<String, dynamic>;
void main() {
  withServerpod('Files attached to archive records', (sessions, endpoints) {
    const editorId = '550e8400-e29b-41d4-a716-446655440011';
    const readerId = '550e8400-e29b-41d4-a716-446655440012';
    const otherId = '550e8400-e29b-41d4-a716-446655440013';
    final editor = sessions.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(editorId, {}),
    );
    final reader = sessions.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(readerId, {}),
    );
    final other = sessions.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(otherId, {}),
    );
    final session = sessions.build();
    late int recordId;
    setUp(() async {
      for (final user in [
        (editorId, 'editor', true),
        (readerId, 'reader', true),
        (otherId, 'editor', false),
      ]) {
        await ArchiveMember.db.insertRow(
          session,
          ArchiveMember(
            userId: user.$1,
            email: '',
            displayName: user.$1,
            role: user.$2,
            courtAccess: user.$3,
            managementAccess: !user.$3,
          ),
        );
      }
      recordId =
          _data(
                await endpoints.archive.saveRecord(
                  editor,
                  'court',
                  jsonEncode({'caseNumber': 'ATT/1'}),
                  null,
                  null,
                ),
              )['id']
              as int;
    });
    Future<int> begin({int size = 3, String name = 'Документ.pdf'}) async =>
        _data(
              await endpoints.attachment.begin(editor, recordId, name, size),
            )['id']
            as int;
    Future<int> ready() async {
      final id = await begin();
      expect(
        _result(
          await endpoints.attachment.append(
            editor,
            id,
            0,
            base64Encode([1, 2, 3]),
          ),
        )['ok'],
        true,
      );
      expect(
        _result(await endpoints.attachment.finish(editor, id))['ok'],
        true,
      );
      return id;
    }

    test(
      'bounded chunks are private until complete and retry safely without duplicate audit events',
      () async {
        final bytes = Uint8List.fromList(
          List.generate(256 * 1024, (i) => i % 251),
        );
        final id = await begin(size: bytes.length + 3);
        expect(
          _result(await endpoints.attachment.list(reader, 0))['data'],
          isEmpty,
        );
        expect(
          _result(await endpoints.attachment.download(reader, id, 0))['ok'],
          false,
        );
        expect(
          _result(await endpoints.attachment.finish(editor, id))['ok'],
          false,
        );
        final first = base64Encode(bytes);
        await endpoints.attachment.append(editor, id, 0, first);
        await endpoints.attachment.append(editor, id, 0, first);
        expect(
          _result(
            await endpoints.attachment.append(editor, id, 0, base64Encode([9])),
          )['ok'],
          false,
        );
        expect(
          _result(
            await endpoints.attachment.append(editor, id, 2, base64Encode([9])),
          )['ok'],
          false,
        );
        await endpoints.attachment.append(
          editor,
          id,
          1,
          base64Encode([4, 5, 6]),
        );
        await endpoints.attachment.finish(editor, id);
        await endpoints.attachment.finish(editor, id);
        final metadata =
            (_result(await endpoints.attachment.list(reader, 0))['data']
                        as List)
                    .single
                as Map;
        expect(metadata['recordId'], recordId);
        expect(metadata['byteLength'], bytes.length + 3);
        expect(metadata['chunkCount'], 2);
        expect(metadata.containsKey('content'), false);
        expect(
          base64Decode(
            _data(await endpoints.attachment.download(reader, id, 0))['content']
                as String,
          ),
          bytes,
        );
        expect(
          base64Decode(
            _data(await endpoints.attachment.download(reader, id, 1))['content']
                as String,
          ),
          [4, 5, 6],
        );
        expect(await ArchiveAttachmentChunk.db.count(session), 2);
        expect(
          (await ArchiveAudit.db.find(
            session,
          )).where((a) => a.action == 'attachment.create'),
          hasLength(1),
        );
      },
    );
    test(
      'server checks reader, module, owner, revoked rights and password reset on every operation',
      () async {
        final id = await ready();
        expect(
          _result(
            await endpoints.attachment.begin(reader, recordId, 'read.pdf', 1),
          )['code'],
          'denied',
        );
        expect(
          _result(await endpoints.attachment.delete(reader, id))['code'],
          'denied',
        );
        expect(
          _result(await endpoints.attachment.download(other, id, 0))['code'],
          'denied',
        );
        expect(
          _result(await endpoints.attachment.list(other, 0))['data'],
          isEmpty,
        );
        await expectLater(
          endpoints.attachment.list(sessions, 0),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
        final pending = await begin();
        expect(
          _result(
            await endpoints.attachment.append(
              other,
              pending,
              0,
              base64Encode([1]),
            ),
          )['code'],
          'denied',
        );
        final editorMember = (await ArchiveMember.db.findFirstRow(
          session,
          where: (t) => t.userId.equals(editorId),
        ))!;
        await ArchiveMember.db.updateRow(
          session,
          editorMember.copyWith(passwordChangeRequired: true),
        );
        expect(
          _result(await endpoints.attachment.download(editor, id, 0))['code'],
          'denied',
        );
        expect(
          _result(
            await endpoints.attachment.append(
              editor,
              pending,
              0,
              base64Encode([1]),
            ),
          )['code'],
          'denied',
        );
        final readMember = (await ArchiveMember.db.findFirstRow(
          session,
          where: (t) => t.userId.equals(readerId),
        ))!;
        await ArchiveMember.db.updateRow(
          session,
          readMember.copyWith(courtAccess: false),
        );
        expect(
          _result(await endpoints.attachment.download(reader, id, 0))['code'],
          'denied',
        );
      },
    );
    test(
      'soft delete, restoration and parent deletion keep file data and audit history',
      () async {
        final id = await ready();
        await endpoints.attachment.delete(editor, id);
        expect(
          _result(await endpoints.attachment.list(reader, 0))['data'],
          isEmpty,
        );
        expect(
          _result(await endpoints.attachment.download(reader, id, 0))['ok'],
          false,
        );
        expect(await ArchiveAttachmentChunk.db.count(session), 1);
        await endpoints.attachment.restore(editor, id);
        expect(
          _result(await endpoints.attachment.download(reader, id, 0))['ok'],
          true,
        );
        final record = (await ArchiveRecord.db.findById(session, recordId))!;
        await endpoints.archive.deleteRecord(editor, recordId, record.version);
        expect(
          _result(await endpoints.attachment.list(reader, 0))['data'],
          isEmpty,
        );
        expect(
          _result(await endpoints.attachment.download(reader, id, 0))['ok'],
          false,
        );
        await endpoints.archive.restoreRecord(editor, recordId);
        expect(
          _result(await endpoints.attachment.download(reader, id, 0))['ok'],
          true,
        );
        final actions = (await ArchiveAudit.db.find(
          session,
        )).map((a) => a.action);
        expect(
          actions,
          containsAll([
            'attachment.create',
            'attachment.delete',
            'attachment.restore',
          ]),
        );
      },
    );
    test(
      'merging cards transfers file ownership to the surviving case',
      () async {
        final id = await ready();
        final target = _data(
          await endpoints.archive.saveRecord(
            editor,
            'court',
            jsonEncode({'caseNumber': 'ATT/2'}),
            null,
            null,
          ),
        );
        final donor = (await ArchiveRecord.db.findById(session, recordId))!;
        final merged = _data(
          await endpoints.archive.saveRecord(
            editor,
            'court',
            jsonEncode({'caseNumber': 'ATT/2'}),
            recordId,
            donor.version,
          ),
        );
        expect(merged['id'], target['id']);
        expect(
          (await ArchiveAttachment.db.findById(session, id))!.recordId,
          target['id'],
        );
        expect(
          _result(await endpoints.attachment.download(reader, id, 0))['ok'],
          true,
        );
        expect(
          (await ArchiveAudit.db.find(
            session,
          )).where((a) => a.action == 'attachment.move'),
          hasLength(1),
        );
      },
    );
    test(
      'cancellation removes only unfinished uploads, zero-byte files are supported and names are safe',
      () async {
        final id = await begin();
        await endpoints.attachment.append(
          editor,
          id,
          0,
          base64Encode([1, 2, 3]),
        );
        await endpoints.attachment.cancel(editor, id);
        expect(await ArchiveAttachment.db.findById(session, id), isNull);
        expect(await ArchiveAttachmentChunk.db.count(session), 0);
        final complete = await ready();
        await endpoints.attachment.cancel(editor, complete);
        expect(
          await ArchiveAttachment.db.findById(session, complete),
          isNotNull,
        );
        final empty = await begin(size: 0, name: 'порожній.txt');
        expect(
          _result(await endpoints.attachment.finish(editor, empty))['ok'],
          true,
        );
        for (final name in [
          '../outside.pdf',
          'bad\\path.pdf',
          'bad\u0000file.pdf',
          '',
        ]) {
          expect(
            _result(
              await endpoints.attachment.begin(editor, recordId, name, 0),
            )['ok'],
            false,
          );
        }
      },
    );
  });
}
