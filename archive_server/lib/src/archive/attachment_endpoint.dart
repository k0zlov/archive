import '../sync/archive_events.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:archive_shared/archive_schema.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../generated/protocol.dart';
import 'archive_record_writer.dart';

class AttachmentEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;
  static const chunkSize = 256 * 1024;

  Future<ArchiveMember> _member(Session session, {Transaction? tx}) async {
    final member = await ArchiveMember.db.findFirstRow(
      session,
      where: (t) =>
          t.userId.equals(session.authenticated!.authUserId.toString()),
      transaction: tx,
    );
    if (member == null ||
        member.passwordChangeRequired ||
        !['admin', 'editor', 'reader'].contains(member.role)) {
      throw const _AttachmentDenied();
    }
    return member;
  }

  Future<ArchiveRecord> _record(
    Session session,
    ArchiveMember member,
    int id, {
    bool write = false,
    Transaction? tx,
  }) async {
    final record = await ArchiveRecord.db.findById(
      session,
      id,
      transaction: tx,
    );
    if (record == null || record.deletedAt != null) {
      throw const FormatException('Справу не знайдено.');
    }
    final module = ArchiveModule.values.byName(record.module);
    if (!(write
        ? canWriteModule(archiveMemberJson(member), module)
        : canReadModule(archiveMemberJson(member), module))) {
      throw const _AttachmentDenied();
    }
    return record;
  }

  Future<ArchiveAttachment> _file(
    Session session,
    int id, {
    Transaction? tx,
  }) async {
    final file = await ArchiveAttachment.db.findById(
      session,
      id,
      transaction: tx,
    );
    if (file == null) throw const FormatException('Файл не знайдено.');
    return file;
  }

  Future<String> _respond(Future<Object?> Function() work) async {
    try {
      return jsonEncode({'ok': true, 'data': await work()});
    } on _AttachmentDenied {
      return jsonEncode({
        'ok': false,
        'code': 'denied',
        'error': 'Немає доступу до файлів цієї справи.',
      });
    } on FormatException catch (e) {
      return jsonEncode({
        'ok': false,
        'code': 'validation',
        'error': e.message,
      });
    }
  }

  Future<String> list(Session session, int afterId) => _respond(() async {
    final member = await _member(session);
    final modules = ArchiveModule.values
        .where((m) => canReadModule(archiveMemberJson(member), m))
        .map((m) => m.name)
        .toSet();
    final files = await ArchiveAttachment.db.find(
      session,
      where: (t) =>
          (t.id > afterId) &
          t.status.equals('ready') &
          t.deletedAt.equals(null) &
          t.record.deletedAt.equals(null) &
          t.record.module.inSet(modules),
      include: ArchiveAttachment.include(record: ArchiveRecord.include()),
      orderBy: (t) => t.id,
      limit: 250,
    );
    return files
        .map((f) => archiveAttachmentJson(f, f.record!.module))
        .toList();
  });

  Future<String> begin(
    Session session,
    int recordId,
    String fileName,
    int byteLength,
  ) => _respond(() async {
    if (byteLength < 0 ||
        fileName.trim().isEmpty ||
        fileName.length > 255 ||
        RegExp(r'[/\\\x00-\x1f]').hasMatch(fileName)) {
      throw const FormatException('Некоректна назва або розмір файлу.');
    }
    return archiveTransaction(session, (tx) async {
      await lockArchiveRecords(session, tx);
      final actor = await _member(session, tx: tx);
      await _record(session, actor, recordId, write: true, tx: tx);
      // Interrupted uploads are private to their owner and expire automatically.
      await ArchiveAttachment.db.deleteWhere(
        session,
        where: (t) =>
            t.status.equals('uploading') &
            (t.createdAt <
                DateTime.now().toUtc().subtract(const Duration(days: 1))),
        transaction: tx,
      );
      final file = await ArchiveAttachment.db.insertRow(
        session,
        ArchiveAttachment(
          recordId: recordId,
          fileName: fileName.trim(),
          byteLength: byteLength,
          createdBy: actor.userId,
        ),
        transaction: tx,
      );
      return {'id': file.id, 'chunkSize': chunkSize};
    });
  });

  Future<String> append(
    Session session,
    int id,
    int chunkIndex,
    String content,
  ) => _respond(() async {
    if (chunkIndex < 0 || content.length > (chunkSize * 4 ~/ 3) + 8) {
      throw const FormatException('Некоректна частина файлу.');
    }
    final bytes = base64Decode(content);
    if (bytes.isEmpty || bytes.length > chunkSize) {
      throw const FormatException('Некоректна частина файлу.');
    }
    return archiveTransaction(session, (tx) async {
      await lockArchiveRecords(session, tx);
      final actor = await _member(session, tx: tx);
      final file = await _file(session, id, tx: tx);
      await _record(session, actor, file.recordId, write: true, tx: tx);
      if (file.createdBy != actor.userId || file.deletedAt != null) {
        throw const _AttachmentDenied();
      }
      if (chunkIndex < file.chunkCount) {
        final prior = await ArchiveAttachmentChunk.db.findFirstRow(
          session,
          where: (t) =>
              t.attachmentId.equals(id) & t.chunkIndex.equals(chunkIndex),
          transaction: tx,
        );
        if (prior == null ||
            base64Encode(
                  prior.content.buffer.asUint8List(
                    prior.content.offsetInBytes,
                    prior.content.lengthInBytes,
                  ),
                ) !=
                content) {
          throw const FormatException('Ця частина файлу вже має інший вміст.');
        }
        return {'received': file.uploadedBytes};
      }
      if (file.status != 'uploading' ||
          chunkIndex != file.chunkCount ||
          file.uploadedBytes + bytes.length > file.byteLength) {
        throw const FormatException('Порушено порядок частин файлу.');
      }
      await ArchiveAttachmentChunk.db.insertRow(
        session,
        ArchiveAttachmentChunk(
          attachmentId: id,
          chunkIndex: chunkIndex,
          content: ByteData.sublistView(bytes),
        ),
        transaction: tx,
      );
      await ArchiveAttachment.db.updateRow(
        session,
        file.copyWith(
          uploadedBytes: file.uploadedBytes + bytes.length,
          chunkCount: file.chunkCount + 1,
        ),
        transaction: tx,
      );
      return {'received': file.uploadedBytes + bytes.length};
    });
  });

  Future<String> finish(Session session, int id) => _respond(() async {
    return archiveTransaction(session, (tx) async {
      await lockArchiveRecords(session, tx);
      final actor = await _member(session, tx: tx);
      final file = await _file(session, id, tx: tx);
      final record = await _record(
        session,
        actor,
        file.recordId,
        write: true,
        tx: tx,
      );
      if (file.createdBy != actor.userId || file.deletedAt != null) {
        throw const _AttachmentDenied();
      }
      if (file.status == 'ready') {
        return archiveAttachmentJson(file, record.module);
      }
      if (file.uploadedBytes != file.byteLength) {
        throw const FormatException('Файл завантажено не повністю.');
      }
      final ready = await ArchiveAttachment.db.updateRow(
        session,
        file.copyWith(status: 'ready'),
        transaction: tx,
      );
      await writeArchiveAudit(
        session,
        archiveChange(
          actor,
          'attachment.create',
          '$id',
          module: record.module,
          after: archiveAttachmentJson(ready, record.module),
        ),
        transaction: tx,
      );
      return archiveAttachmentJson(ready, record.module);
    });
  });

  Future<String> cancel(Session session, int id) => _respond(() async {
    return archiveTransaction(session, (tx) async {
      await lockArchiveRecords(session, tx);
      final actor = await _member(session, tx: tx);
      final file = await _file(session, id, tx: tx);
      await _record(session, actor, file.recordId, write: true, tx: tx);
      if (file.createdBy != actor.userId) throw const _AttachmentDenied();
      if (file.status == 'uploading') {
        await ArchiveAttachment.db.deleteRow(session, file, transaction: tx);
      }
      return {'cancelled': file.status == 'uploading'};
    });
  });

  Future<String> download(Session session, int id, int chunkIndex) =>
      _respond(() async {
        final actor = await _member(session);
        final file = await _file(session, id);
        await _record(session, actor, file.recordId);
        if (file.status != 'ready' ||
            file.deletedAt != null ||
            chunkIndex < 0 ||
            chunkIndex >= file.chunkCount) {
          throw const FormatException('Файл недоступний.');
        }
        final chunk = await ArchiveAttachmentChunk.db.findFirstRow(
          session,
          where: (t) =>
              t.attachmentId.equals(id) & t.chunkIndex.equals(chunkIndex),
        );
        if (chunk == null) {
          throw const FormatException('Частину файлу не знайдено.');
        }
        return {
          'content': base64Encode(
            chunk.content.buffer.asUint8List(
              chunk.content.offsetInBytes,
              chunk.content.lengthInBytes,
            ),
          ),
        };
      });

  Future<String> delete(Session session, int id) =>
      _visibility(session, id, true);
  Future<String> restore(Session session, int id) =>
      _visibility(session, id, false);
  Future<String> _visibility(Session session, int id, bool deleting) =>
      _respond(() async {
        return archiveTransaction(session, (tx) async {
          await lockArchiveRecords(session, tx);
          final actor = await _member(session, tx: tx);
          final file = await _file(session, id, tx: tx);
          final record = await _record(
            session,
            actor,
            file.recordId,
            write: true,
            tx: tx,
          );
          if (file.status != 'ready') {
            throw const FormatException('Завантаження файлу не завершено.');
          }
          if ((file.deletedAt != null) == deleting) {
            return archiveAttachmentJson(file, record.module);
          }
          final next = file.copyWith(
            deletedAt: deleting ? DateTime.now().toUtc() : null,
            deletedBy: deleting ? actor.userId : null,
          );
          await ArchiveAttachment.db.updateRow(session, next, transaction: tx);
          await writeArchiveAudit(
            session,
            archiveChange(
              actor,
              deleting ? 'attachment.delete' : 'attachment.restore',
              '$id',
              module: record.module,
              before: archiveAttachmentJson(file, record.module),
              after: archiveAttachmentJson(next, record.module),
            ),
            transaction: tx,
          );
          return archiveAttachmentJson(next, record.module);
        });
      });
}

class _AttachmentDenied implements Exception {
  const _AttachmentDenied();
}
