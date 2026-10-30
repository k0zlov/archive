import '../sync/archive_sync_endpoint.dart';
import '../sync/archive_events.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive_shared/archive_schema.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';
import 'archive_record_writer.dart';

/// Server-side authorization is rechecked for every operation, including reads.
class ArchiveEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<String> profile(Session session) => _respond(() async {
    final userId = session.authenticated!.authUserId.toString();
    var member = await ArchiveMember.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
    );
    if (member == null) {
      final profile = await session.authenticated!.userProfile(session);
      final email = (profile?.email ?? '').toLowerCase();
      final configuredAdmin =
          (Platform.environment['ARCHIVE_ADMIN_EMAIL'] ??
                  session.serverpod.getPassword('archiveBootstrapAdminEmail') ??
                  '')
              .trim()
              .toLowerCase();
      final isAdmin = configuredAdmin.isNotEmpty && email == configuredAdmin;
      try {
        member = await archiveTransaction(session, (tx) async {
          final created = await ArchiveMember.db.insertRow(
            session,
            ArchiveMember(
              userId: userId,
              email: email,
              login: 'user-${userId.replaceAll('-', '')}',
              displayName: profile?.fullName ?? email,
              role: isAdmin ? 'admin' : 'pending',
              managementAccess: isAdmin,
              courtAccess: isAdmin,
            ),
            transaction: tx,
          );
          await writeArchiveAudit(
            session,
            archiveChange(
              created,
              isAdmin ? 'member.bootstrap' : 'member.create',
              created.userId,
              after: archiveMemberJson(created),
            ),
            transaction: tx,
          );
          return created;
        });
      } on DatabaseUniqueViolationException {
        member = await ArchiveMember.db.findFirstRow(
          session,
          where: (t) => t.userId.equals(userId),
        );
        if (member == null) rethrow;
      }
    }
    if (member!.role == 'deleted' || member.role == 'blocked') {
      throw const _Denied();
    }
    return _memberJson(member);
  });

  Future<String> records(Session session, int afterId) => _respond(() async {
    final m = await _member(session);
    final modules = ArchiveModule.values
        .where((v) => canReadModule(_memberJson(m), v))
        .map((v) => v.name)
        .toSet();
    if (modules.isEmpty) return <dynamic>[];
    final rows = await ArchiveRecord.db.find(
      session,
      where: (t) =>
          (t.id > afterId) & t.module.inSet(modules) & t.deletedAt.equals(null),
      orderBy: (t) => t.id,
      limit: 250,
    );
    return rows.map(_recordJson).toList();
  });

  /// Every committed card mutation writes its audit event in the same transaction.
  Future<String> recordRevision(Session session) => _respond(() async {
    final member = await _member(session);
    final modules =
        ArchiveModule.values
            .where((m) => canReadModule(_memberJson(member), m))
            .map((m) => m.name)
            .toList()
          ..sort();
    final last = modules.isEmpty
        ? null
        : await ArchiveAudit.db.findFirstRow(
            session,
            where: (t) =>
                t.module.inSet(modules.toSet()) & t.action.like('record.%'),
            orderBy: (t) => t.id.desc(),
          );
    return {'revision': '${modules.join(',')}:${last?.id ?? 0}'};
  });

  Future<String> saveRecord(
    Session session,
    String module,
    String valuesJson,
    int? id,
    int? version,
  ) => _respond(() async {
    final kind = ArchiveModule.values.byName(module);
    final actor = await _access(session, kind, write: true);
    final values = validateRecord(
      kind,
      Map<String, String>.from(jsonDecode(valuesJson) as Map),
    );
    return ArchiveRecordWriter(session, actor).save(kind, values, id, version);
  });

  Future<String> importRecords(
    Session session,
    String module,
    List<String> rows,
  ) => _respond(() async {
    final job = _unwrap(await beginImport(session, module)) as Map;
    final id = job['jobId'] as int;
    try {
      _unwrap(await appendImportRows(session, id, 0, rows));
      return _unwrap(await commitImport(session, id));
    } catch (_) {
      await cancelImport(session, id);
      rethrow;
    }
  });

  Future<String> beginImport(
    Session session,
    String module, {
    bool replaceExisting = false,
    List<String> sourceNames = const [],
  }) => _respond(() async {
    final kind = ArchiveModule.values.byName(module);
    final actor = await _access(session, kind, write: true);
    return archiveTransaction(session, (tx) async {
      await ArchiveImportJob.db.deleteWhere(
        session,
        where: (t) =>
            t.userId.equals(actor.userId) &
            (t.createdAt <
                DateTime.now().toUtc().subtract(const Duration(days: 1))),
        transaction: tx,
      );
      final job = await ArchiveImportJob.db.insertRow(
        session,
        ArchiveImportJob(
          userId: actor.userId,
          module: module,
          replaceExisting: replaceExisting,
          sourceNamesJson: jsonEncode(sourceNames),
        ),
        transaction: tx,
      );
      await writeArchiveAudit(
        session,
        archiveChange(
          actor,
          'import.begin',
          '${job.id}',
          module: module,
          details: {'sources': sourceNames, 'replaceExisting': replaceExisting},
        ),
        transaction: tx,
      );
      return {'jobId': job.id};
    });
  });

  Future<String> appendImportRows(
    Session session,
    int jobId,
    int offset,
    List<String> rows,
  ) => _respond(() async {
    if (rows.isEmpty) throw const FormatException('Порожня порція імпорту.');
    return archiveTransaction(session, (tx) async {
      final job = await _importJob(session, jobId, tx);
      if (job.status != 'open') {
        throw const FormatException('Імпорт уже завершено.');
      }
      final batch = jsonEncode(rows);
      if (job.lastOffset == offset && job.lastBatchJson == batch) {
        return {'received': job.receivedRows};
      }
      if (offset != job.receivedRows) {
        throw const FormatException(
          'Порушено порядок передачі записів. Повторіть імпорт.',
        );
      }
      final kind = ArchiveModule.values.byName(job.module);
      final grouped = <String, Map<String, String>>{};
      var skipped = 0;
      for (final row in rows) {
        final incoming = Map<String, String>.from(jsonDecode(row) as Map);
        if (kind == ArchiveModule.court &&
            (incoming['caseNumber'] ?? '').trim().isEmpty) {
          skipped++;
          continue;
        }
        final values = validateRecord(
          kind,
          incoming,
          partial: true,
          allowDateOrderWarnings: true,
        );
        final key = recordIdentity(kind, values);
        grouped[key] = mergeRecordValues(
          grouped[key] ?? {},
          values,
          replaceExisting: job.replaceExisting,
        );
      }
      final previous = {
        for (final r in await ArchiveImportRow.db.find(
          session,
          where: (t) =>
              t.jobId.equals(jobId) & t.identityKey.inSet(grouped.keys.toSet()),
          transaction: tx,
        ))
          r.identityKey: r,
      };
      final inserts = <ArchiveImportRow>[];
      final updates = <ArchiveImportRow>[];
      for (final entry in grouped.entries) {
        final prior = previous[entry.key];
        final values = prior == null
            ? entry.value
            : mergeRecordValues(
                Map<String, String>.from(jsonDecode(prior.valuesJson) as Map),
                entry.value,
                replaceExisting: job.replaceExisting,
              );
        if (prior == null) {
          inserts.add(
            ArchiveImportRow(
              jobId: jobId,
              identityKey: entry.key,
              reference: recordReference(kind, values),
              proceeding: values['proceedingNumber'] ?? '',
              valuesJson: jsonEncode(values),
            ),
          );
        } else {
          updates.add(
            prior.copyWith(
              reference: recordReference(kind, values),
              proceeding: values['proceedingNumber'] ?? '',
              valuesJson: jsonEncode(values),
            ),
          );
        }
      }
      if (inserts.isNotEmpty) {
        await ArchiveImportRow.db.insert(session, inserts, transaction: tx);
      }
      if (updates.isNotEmpty) {
        await ArchiveImportRow.db.update(session, updates, transaction: tx);
      }
      await ArchiveImportJob.db.updateRow(
        session,
        job.copyWith(
          receivedRows: offset + rows.length,
          skippedRows: job.skippedRows + skipped,
          lastOffset: offset,
          lastBatchJson: batch,
        ),
        transaction: tx,
      );
      return {'received': offset + rows.length};
    });
  });

  Future<String> commitImport(Session session, int jobId) => _respond(() async {
    return archiveTransaction(session, (tx) async {
      final job = await _importJob(session, jobId, tx);
      if (job.status == 'committed') return jsonDecode(job.resultJson);
      if (job.receivedRows == 0) {
        throw const FormatException('У файлі немає записів для імпорту.');
      }
      final actor = await _access(
        session,
        ArchiveModule.values.byName(job.module),
        write: true,
      );
      await lockArchiveRecords(session, tx);
      final writer = ArchiveRecordWriter(session, actor);
      var cursor = 0;
      var count = 0;
      var created = 0;
      var updated = 0;
      var unchanged = 0;
      var warnings = 0;
      final sources = List<String>.from(
        jsonDecode(job.sourceNamesJson) as List,
      );
      while (true) {
        final page = await ArchiveImportRow.db.find(
          session,
          where: (t) => t.jobId.equals(jobId) & (t.id > cursor),
          orderBy: (t) => t.id,
          limit: 250,
          transaction: tx,
        );
        if (page.isEmpty) break;
        final stats = await writer.importPage(
          ArchiveModule.values.byName(job.module),
          page,
          job.replaceExisting,
          tx,
          sources,
        );
        count += page.length;
        created += stats['created']!;
        updated += stats['updated']!;
        unchanged += stats['unchanged']!;
        warnings += stats['warnings']!;
        cursor = page.last.id!;
      }
      final result = {
        'count': count,
        'rows': job.receivedRows,
        'created': created,
        'updated': updated,
        'unchanged': unchanged,
        'merged': job.receivedRows - job.skippedRows - count,
        'skipped': job.skippedRows,
        'warnings': warnings,
      };
      await ArchiveImportJob.db.updateRow(
        session,
        job.copyWith(
          status: 'committed',
          lastBatchJson: '',
          resultJson: jsonEncode(result),
        ),
        transaction: tx,
      );
      await ArchiveImportRow.db.deleteWhere(
        session,
        where: (t) => t.jobId.equals(jobId),
        transaction: tx,
      );
      await writeArchiveAudit(
        session,
        archiveChange(
          actor,
          'import.commit',
          '$jobId',
          module: job.module,
          details: {
            ...result,
            'sources': sources,
            'replaceExisting': job.replaceExisting,
          },
        ),
        transaction: tx,
      );
      return result;
    });
  });

  Future<String> cancelImport(Session session, int jobId) => _respond(() async {
    return archiveTransaction(session, (tx) async {
      final job = await _importJob(session, jobId, tx);
      if (job.status != 'committed') {
        final actor = await _member(session);
        await writeArchiveAudit(
          session,
          archiveChange(
            actor,
            'import.cancel',
            '$jobId',
            module: job.module,
            details: {
              'rows': job.receivedRows,
              'sources': jsonDecode(job.sourceNamesJson),
            },
          ),
          transaction: tx,
        );
        await ArchiveImportJob.db.deleteRow(session, job, transaction: tx);
      }
      return {
        'cancelled': job.status != 'committed',
        'count': job.receivedRows,
        if (job.status == 'committed')
          ...Map<String, dynamic>.from(jsonDecode(job.resultJson) as Map),
      };
    });
  });

  Future<ArchiveImportJob> _importJob(
    Session session,
    int id,
    Transaction tx,
  ) async {
    final job = await ArchiveImportJob.db.findById(
      session,
      id,
      transaction: tx,
      lockMode: LockMode.forUpdate,
    );
    if (job == null ||
        job.userId != session.authenticated!.authUserId.toString()) {
      throw const _Denied();
    }
    await _access(
      session,
      ArchiveModule.values.byName(job.module),
      write: true,
    );
    return job;
  }

  dynamic _unwrap(String response) {
    final data = jsonDecode(response) as Map;
    if (data['code'] == 'denied') throw const _Denied();
    if (data['ok'] != true) throw FormatException(data['error'] as String);
    return data['data'];
  }

  Future<String> relatedRecords(Session session, int id) => _respond(() async {
    await _access(session, ArchiveModule.court);
    final source = await ArchiveRecord.db.findById(session, id);
    if (source == null ||
        source.module != 'court' ||
        source.deletedAt != null) {
      throw const FormatException('Справу не знайдено.');
    }
    final values = Map<String, String>.from(
      jsonDecode(source.valuesJson) as Map,
    );
    final participants = _participants(values['participants'] ?? '');
    final same = await ArchiveRecord.db.find(
      session,
      where: (t) =>
          t.module.equals('court') &
          t.reference.equals(source.reference) &
          t.deletedAt.equals(null) &
          t.id.notEquals(id),
      orderBy: (t) => t.id,
    );
    final found = {for (final row in same) row.id!: row};
    if (participants.isNotEmpty) {
      var cursor = 0;
      while (true) {
        final page = await ArchiveRecord.db.find(
          session,
          where: (t) =>
              t.module.equals('court') &
              (t.id > cursor) &
              t.id.notEquals(id) &
              t.deletedAt.equals(null),
          orderBy: (t) => t.id,
          limit: 250,
        );
        for (final row in page) {
          final other = Map<String, String>.from(
            jsonDecode(row.valuesJson) as Map,
          );
          if (_participants(
            other['participants'] ?? '',
          ).intersection(participants).isNotEmpty) {
            found.putIfAbsent(row.id!, () => row);
          }
        }
        if (page.length < 250) break;
        cursor = page.last.id!;
      }
    }
    // Related cards are deliberately not loaded here.
    return found.values
        .map(
          (r) => {
            'id': r.id,
            'reference': r.reference,
            'proceeding': r.proceeding,
          },
        )
        .toList();
  });

  Future<String> members(Session session) => _respond(() async {
    await _admin(session);
    final status = await archiveSessionStatus(session);
    return (await ArchiveMember.db.find(
          session,
          where: (t) => t.role.notEquals('deleted'),
          orderBy: (t) => t.createdAt,
        ))
        .map(
          (m) => {
            ..._memberJson(m),
            'online': status[m.userId]?['online'] ?? false,
            'activeSessions': status[m.userId]?['activeSessions'] ?? 0,
          },
        )
        .toList();
  });

  Future<String> setMemberAccess(
    Session session,
    int memberId,
    String role,
    bool managementAccess,
    bool courtAccess,
  ) => _respond(() async {
    final actor = await _admin(session);
    if (!roleLabels.containsKey(role)) {
      throw const FormatException('Невідома роль.');
    }
    if (memberId == actor.id) {
      throw const FormatException(
        'Змінити власні права в цій панелі неможливо.',
      );
    }
    final target = await ArchiveMember.db.findById(session, memberId);
    if (target == null || target.role == 'deleted') {
      throw const FormatException('Користувача не знайдено.');
    }
    await archiveTransaction(session, (tx) async {
      final changed = await ArchiveMember.db.updateRow(
        session,
        target.copyWith(
          role: role,
          managementAccess: managementAccess,
          courtAccess: courtAccess,
        ),
        transaction: tx,
      );
      await writeArchiveAudit(
        session,
        archiveChange(
          actor,
          'member.access',
          target.userId,
          before: archiveMemberJson(target),
          after: archiveMemberJson(changed),
        ),
        transaction: tx,
      );
    });
    if (role == 'blocked') {
      await AuthServices.instance.tokenManager.revokeAllTokens(
        session,
        authUserId: UuidValue.fromString(target.userId),
      );
    }
    return {'saved': true};
  });

  Future<String> documents(Session session) => _respond(() async {
    final member = await _member(session);
    if (!canReadModule(_memberJson(member), ArchiveModule.management)) {
      return <dynamic>[];
    }
    return (await ArchiveDocument.db.find(
      session,
      where: (t) => t.deletedAt.equals(null),
      orderBy: (t) => t.year.desc(),
    )).map(archiveDocumentJson).toList();
  });

  Future<String> uploadDocument(
    Session session,
    String title,
    String fileName,
    int year,
    String contentBase64,
  ) => _respond(() async {
    final member = await _access(
      session,
      ArchiveModule.management,
      write: true,
    );
    if (title.trim().isEmpty ||
        title.length > 300 ||
        year < 1900 ||
        year > 2200) {
      throw const FormatException('Перевірте назву та рік номенклатури.');
    }
    if (!RegExp(r'^[^/\\]+\.docx?$', caseSensitive: false).hasMatch(fileName)) {
      throw const FormatException('Оберіть документ Word (.doc або .docx).');
    }
    if (contentBase64.length > 7000000) {
      throw const FormatException('Документ має бути не більшим за 5 МБ.');
    }
    final bytes = base64Decode(contentBase64);
    if (bytes.isEmpty || bytes.length > 5 * 1024 * 1024) {
      throw const FormatException('Документ порожній або перевищує 5 МБ.');
    }
    return archiveTransaction(session, (tx) async {
      final d = await ArchiveDocument.db.insertRow(
        session,
        ArchiveDocument(
          title: title.trim(),
          fileName: fileName,
          kind: 'nomenclature',
          year: year,
          content: ByteData.sublistView(bytes),
          createdBy: member.userId,
        ),
        transaction: tx,
      );
      await writeArchiveAudit(
        session,
        archiveChange(
          member,
          'document.create',
          '${d.id}',
          module: 'management',
          after: archiveDocumentJson(d),
        ),
        transaction: tx,
      );
      return {'id': d.id};
    });
  });

  Future<String> downloadDocument(Session session, int id) =>
      _respond(() async {
        await _access(session, ArchiveModule.management);
        final doc = await ArchiveDocument.db.findById(session, id);
        if (doc == null || doc.deletedAt != null) {
          throw const FormatException('Документ не знайдено.');
        }
        return {
          'content': base64Encode(
            doc.content.buffer.asUint8List(
              doc.content.offsetInBytes,
              doc.content.lengthInBytes,
            ),
          ),
        };
      });

  Future<String> deleteRecord(Session session, int id, int version) =>
      _respond(() async {
        return archiveTransaction(session, (tx) async {
          await lockArchiveRecords(session, tx);
          final record = await ArchiveRecord.db.findById(
            session,
            id,
            transaction: tx,
          );
          if (record == null || record.deletedAt != null) {
            throw const FormatException('Справу не знайдено.');
          }
          final actor = await _access(
            session,
            ArchiveModule.values.byName(record.module),
            write: true,
          );
          if (record.version != version) {
            throw const FormatException(
              'Справу вже змінено. Оновіть дані перед видаленням.',
            );
          }
          final deleted = record.copyWith(
            deletedAt: DateTime.now().toUtc(),
            deletedBy: actor.userId,
            identityKey: 'deleted:$id:${record.identityKey}',
            version: version + 1,
            updatedBy: actor.userId,
            updatedAt: DateTime.now().toUtc(),
          );
          await ArchiveRecord.db.updateRow(session, deleted, transaction: tx);
          await writeArchiveAudit(
            session,
            archiveChange(
              actor,
              'record.delete',
              '$id',
              module: record.module,
              before: archiveRecordJson(record),
              after: archiveRecordJson(deleted),
            ),
            transaction: tx,
          );
          return {'deleted': true};
        });
      });

  Future<String> restoreRecord(Session session, int id) => _respond(() async {
    return archiveTransaction(session, (tx) async {
      await lockArchiveRecords(session, tx);
      final record = await ArchiveRecord.db.findById(
        session,
        id,
        transaction: tx,
      );
      if (record == null || record.deletedAt == null) {
        throw const FormatException('Справу вже відновлено або не знайдено.');
      }
      final kind = ArchiveModule.values.byName(record.module);
      final actor = await _access(session, kind, write: true);
      final key = recordIdentity(kind, recordValues(record));
      if (await ArchiveRecord.db.findFirstRow(
            session,
            where: (t) => t.identityKey.equals(key),
            transaction: tx,
          ) !=
          null) {
        throw const FormatException(
          'В архіві вже є справа з таким номером. Перегляньте її перед відновленням.',
        );
      }
      final restored = record.copyWith(
        deletedAt: null,
        deletedBy: null,
        identityKey: key,
        version: record.version + 1,
        updatedBy: actor.userId,
        updatedAt: DateTime.now().toUtc(),
      );
      await ArchiveRecord.db.updateRow(session, restored, transaction: tx);
      await writeArchiveAudit(
        session,
        archiveChange(
          actor,
          'record.restore',
          '$id',
          module: record.module,
          before: archiveRecordJson(record),
          after: archiveRecordJson(restored),
        ),
        transaction: tx,
      );
      return archiveRecordJson(restored);
    });
  });

  Future<String> deleteDocument(Session session, int id) => _respond(() async {
    final actor = await _access(session, ArchiveModule.management, write: true);
    return archiveTransaction(session, (tx) async {
      final doc = await ArchiveDocument.db.findById(
        session,
        id,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (doc == null || doc.deletedAt != null) {
        throw const FormatException('Документ не знайдено.');
      }
      final deleted = doc.copyWith(
        deletedAt: DateTime.now().toUtc(),
        deletedBy: actor.userId,
      );
      await ArchiveDocument.db.updateRow(session, deleted, transaction: tx);
      await writeArchiveAudit(
        session,
        archiveChange(
          actor,
          'document.delete',
          '$id',
          module: 'management',
          before: archiveDocumentJson(doc),
          after: archiveDocumentJson(deleted),
        ),
        transaction: tx,
      );
      return {'deleted': true};
    });
  });

  Future<String> restoreDocument(Session session, int id) => _respond(() async {
    final actor = await _access(session, ArchiveModule.management, write: true);
    return archiveTransaction(session, (tx) async {
      final doc = await ArchiveDocument.db.findById(
        session,
        id,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (doc == null || doc.deletedAt == null) {
        throw const FormatException('Документ уже відновлено або не знайдено.');
      }
      final restored = doc.copyWith(deletedAt: null, deletedBy: null);
      await ArchiveDocument.db.updateRow(session, restored, transaction: tx);
      await writeArchiveAudit(
        session,
        archiveChange(
          actor,
          'document.restore',
          '$id',
          module: 'management',
          before: archiveDocumentJson(doc),
          after: archiveDocumentJson(restored),
        ),
        transaction: tx,
      );
      return archiveDocumentJson(restored);
    });
  });

  Future<String> auditEntries(Session session, int beforeId, String query) =>
      _respond(() async {
        await _admin(session);
        final term = query.trim();
        final items = await ArchiveAudit.db.find(
          session,
          where: (t) =>
              (beforeId == 0 ? Constant.bool(true) : t.id < beforeId) &
              (term.isEmpty
                  ? Constant.bool(true)
                  : t.actorEmail.ilike('%$term%') |
                        t.action.ilike('%$term%') |
                        t.target.ilike('%$term%')),
          orderBy: (t) => t.id.desc(),
          limit: 101,
        );
        final page = items.take(100).toList();
        final actors = {
          for (final m in await ArchiveMember.db.find(
            session,
            where: (t) => t.userId.inSet(page.map((e) => e.actorId).toSet()),
          ))
            m.userId: m.login ?? m.email,
        };
        return {
          'hasMore': items.length > 100,
          'items': page
              .map(
                (e) => {
                  'id': e.id,
                  'actor': e.actorEmail.isEmpty
                      ? actors[e.actorId] ?? e.actorId
                      : e.actorEmail,
                  'action': e.action,
                  'target': e.target,
                  'module': e.module,
                  'at': e.createdAt.toIso8601String(),
                  'before': jsonDecode(e.beforeJson),
                  'after': jsonDecode(e.afterJson),
                  'details': jsonDecode(e.detailsJson),
                },
              )
              .toList(),
        };
      });

  Future<ArchiveMember> _member(Session session) async {
    final id = session.authenticated!.authUserId.toString();
    final m = await ArchiveMember.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(id),
    );
    if (m == null ||
        m.passwordChangeRequired ||
        !['reader', 'editor', 'admin'].contains(m.role)) {
      throw const _Denied();
    }
    return m;
  }

  Future<ArchiveMember> _access(
    Session session,
    ArchiveModule module, {
    bool write = false,
  }) async {
    final m = await _member(session);
    if (!(write
        ? canWriteModule(_memberJson(m), module)
        : canReadModule(_memberJson(m), module))) {
      throw const _Denied();
    }
    return m;
  }

  Future<ArchiveMember> _admin(Session session) async {
    final m = await _member(session);
    if (m.role != 'admin') throw const _Denied();
    return m;
  }

  Future<String> _respond(Future<Object?> Function() action) async {
    try {
      return jsonEncode({'ok': true, 'data': await action()});
    } on _Denied {
      return jsonEncode({
        'ok': false,
        'code': 'denied',
        'error': 'Немає дозволу на цю дію. Оновіть права доступу.',
      });
    } on FormatException catch (e) {
      return jsonEncode({
        'ok': false,
        'code': 'validation',
        'error': e.message,
      });
    } on DatabaseUniqueViolationException {
      return jsonEncode({
        'ok': false,
        'code': 'duplicate',
        'error': 'Така справа вже існує. Зміни не збережено.',
      });
    }
  }

  Map<String, dynamic> _memberJson(ArchiveMember m) => archiveMemberJson(m);
  Map<String, dynamic> _recordJson(ArchiveRecord r) => archiveRecordJson(r);
  Set<String> _participants(String value) => value
      .split(RegExp(r'[;\n]+'))
      .map(normalizeHeader)
      .where((v) => v.isNotEmpty)
      .toSet();
}

class _Denied implements Exception {
  const _Denied();
}
