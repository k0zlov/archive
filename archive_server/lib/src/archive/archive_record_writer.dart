import '../sync/archive_events.dart';
import 'dart:convert';
import 'package:archive_shared/archive_schema.dart';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

Map<String, dynamic> archiveAttachmentJson(
  ArchiveAttachment a,
  String module,
) => {
  'id': a.id,
  'recordId': a.recordId,
  'module': module,
  'fileName': a.fileName,
  'byteLength': a.byteLength,
  'chunkCount': a.chunkCount,
  'createdAt': a.createdAt.toIso8601String(),
  'deletedAt': a.deletedAt?.toIso8601String(),
};

Map<String, String> recordValues(ArchiveRecord record) =>
    Map<String, String>.from(jsonDecode(record.valuesJson) as Map);
Map<String, dynamic> archiveRecordJson(ArchiveRecord r) => {
  'id': r.id,
  'module': r.module,
  'version': r.version,
  'values': jsonDecode(r.valuesJson),
  'updatedAt': r.updatedAt.toIso8601String(),
  'deletedAt': r.deletedAt?.toIso8601String(),
};
Map<String, dynamic> archiveDocumentJson(ArchiveDocument d) => {
  'id': d.id,
  'title': d.title,
  'fileName': d.fileName,
  'kind': d.kind,
  'year': d.year,
  'deletedAt': d.deletedAt?.toIso8601String(),
};
Map<String, dynamic> archiveMemberJson(ArchiveMember m) => {
  'id': m.id,
  'userId': m.userId,
  'email': m.email,
  'login': m.login,
  'passwordChangeRequired': m.passwordChangeRequired,
  'displayName': m.displayName,
  'role': m.role,
  'managementAccess': m.managementAccess,
  'courtAccess': m.courtAccess,
};

ArchiveAudit archiveChange(
  ArchiveMember actor,
  String action,
  String target, {
  String module = '',
  Map<String, dynamic> before = const {},
  Map<String, dynamic> after = const {},
  Map<String, dynamic> details = const {},
}) => ArchiveAudit(
  actorId: actor.userId,
  actorEmail: actor.login ?? actor.email,
  action: action,
  target: target,
  module: module,
  beforeJson: jsonEncode(before),
  afterJson: jsonEncode(after),
  detailsJson: jsonEncode(details),
);

Future<void> lockArchiveRecords(Session session, Transaction tx) => session.db
    .unsafeExecute(
      'LOCK TABLE archive_record IN SHARE ROW EXCLUSIVE MODE',
      transaction: tx,
    )
    .then((_) {});

class ArchiveRecordWriter {
  ArchiveRecordWriter(this.session, this.actor);
  final Session session;
  final ArchiveMember actor;

  Future<Map<String, dynamic>> save(
    ArchiveModule module,
    Map<String, String> values,
    int? id,
    int? version,
  ) => archiveTransaction(session, (tx) async {
    await lockArchiveRecords(session, tx);
    ArchiveRecord? current;
    if (id != null) {
      current = await ArchiveRecord.db.findById(session, id, transaction: tx);
      if (current == null ||
          current.module != module.name ||
          current.deletedAt != null) {
        throw const FormatException('Запис не знайдено.');
      }
      if (current.version != version) {
        throw const FormatException(
          'Запис уже змінено іншим користувачем. Оновіть дані та відкрийте картку знову.',
        );
      }
    }
    final key = recordIdentity(module, values);
    final existing = await ArchiveRecord.db.findFirstRow(
      session,
      where: (t) => t.identityKey.equals(key) & t.deletedAt.equals(null),
      transaction: tx,
    );
    final merging = existing != null && existing.id != current?.id;
    final target = merging ? existing : current;
    final nextValues = validateRecord(
      module,
      merging ? mergeRecordValues(recordValues(existing), values) : values,
    );
    final before = target == null
        ? <String, dynamic>{}
        : archiveRecordJson(target);
    var next = target == null
        ? ArchiveRecord(
            module: module.name,
            identityKey: key,
            reference: recordReference(module, nextValues),
            proceeding: nextValues['proceedingNumber'] ?? '',
            valuesJson: jsonEncode(nextValues),
            createdBy: actor.userId,
            updatedBy: actor.userId,
          )
        : target.copyWith(
            identityKey: key,
            reference: recordReference(module, nextValues),
            proceeding: nextValues['proceedingNumber'] ?? '',
            valuesJson: jsonEncode(nextValues),
            version: target.version + 1,
            updatedBy: actor.userId,
            updatedAt: DateTime.now().toUtc(),
          );
    if (merging && current != null) {
      final files = await ArchiveAttachment.db.find(
        session,
        where: (t) => t.recordId.equals(current!.id!),
        transaction: tx,
      );
      for (final file in files) {
        final moved = file.copyWith(recordId: target!.id!);
        await ArchiveAttachment.db.updateRow(session, moved, transaction: tx);
        if (file.status == 'ready') {
          await writeArchiveAudit(
            session,
            archiveChange(
              actor,
              'attachment.move',
              '${file.id}',
              module: module.name,
              before: archiveAttachmentJson(file, module.name),
              after: archiveAttachmentJson(moved, module.name),
            ),
            transaction: tx,
          );
        }
      }
      final removed = current.copyWith(
        identityKey: 'deleted:${current.id}:${current.identityKey}',
        deletedAt: DateTime.now().toUtc(),
        deletedBy: actor.userId,
        version: current.version + 1,
      );
      await ArchiveRecord.db.updateRow(session, removed, transaction: tx);
      await writeArchiveAudit(
        session,
        archiveChange(
          actor,
          'record.merge',
          '${current.id}',
          module: module.name,
          before: archiveRecordJson(current),
          after: archiveRecordJson(removed),
          details: {'mergedInto': target!.id},
        ),
        transaction: tx,
      );
    }
    next = target == null
        ? await ArchiveRecord.db.insertRow(session, next, transaction: tx)
        : await ArchiveRecord.db.updateRow(session, next, transaction: tx);
    await writeArchiveAudit(
      session,
      archiveChange(
        actor,
        merging
            ? 'record.merge'
            : target == null
            ? 'record.create'
            : 'record.update',
        '${next.id}',
        module: module.name,
        before: before,
        after: archiveRecordJson(next),
      ),
      transaction: tx,
    );
    return {...archiveRecordJson(next), 'merged': merging};
  });

  /// Bulk upsert preserves a complete before/after event for every changed card.
  Future<Map<String, int>> importPage(
    ArchiveModule module,
    List<ArchiveImportRow> staged,
    bool replaceExisting,
    Transaction tx,
    List<String> sources,
  ) async {
    final keys = staged.map((r) => r.identityKey).toSet();
    final existing = {
      for (final r in await ArchiveRecord.db.find(
        session,
        where: (t) => t.identityKey.inSet(keys) & t.deletedAt.equals(null),
        transaction: tx,
      ))
        r.identityKey: r,
    };
    final payload = <Map<String, dynamic>>[];
    final prepared = <String, Map<String, String>>{};
    var created = 0;
    var updated = 0;
    var unchanged = 0;
    var warnings = 0;
    for (final row in staged) {
      final prior = existing[row.identityKey];
      final incoming = Map<String, String>.from(
        jsonDecode(row.valuesJson) as Map,
      );
      final merged = validateRecord(
        module,
        prior == null
            ? incoming
            : mergeRecordValues(
                recordValues(prior),
                incoming,
                replaceExisting: replaceExisting,
              ),
        allowDateOrderWarnings: true,
      );
      warnings += recordDateWarnings(module, merged).length;
      if (prior != null && sameRecordValues(recordValues(prior), merged)) {
        unchanged++;
        continue;
      }
      if (prior == null) {
        created++;
      } else {
        updated++;
      }
      prepared[row.identityKey] = merged;
      payload.add({
        'identityKey': row.identityKey,
        'reference': recordReference(module, merged),
        'proceeding': merged['proceedingNumber'] ?? '',
        'valuesJson': jsonEncode(merged),
      });
    }
    if (payload.isNotEmpty) {
      final saved = await session.db.unsafeQuery(
        '''
        INSERT INTO archive_record ("module", "identityKey", "reference", "proceeding", "valuesJson", "version", "createdBy", "updatedBy", "createdAt", "updatedAt")
        SELECT @module, p."identityKey", p."reference", p."proceeding", p."valuesJson", 1, @actor, @actor, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        FROM jsonb_to_recordset(CAST(@payload AS jsonb)) AS p("identityKey" text, "reference" text, "proceeding" text, "valuesJson" text)
        ON CONFLICT ("identityKey") DO UPDATE SET "reference" = EXCLUDED."reference", "proceeding" = EXCLUDED."proceeding", "valuesJson" = EXCLUDED."valuesJson",
          "version" = archive_record."version" + 1, "updatedBy" = EXCLUDED."updatedBy", "updatedAt" = EXCLUDED."updatedAt"
        RETURNING "id", "identityKey", "version", "updatedAt"
      ''',
        parameters: QueryParameters.named({
          'module': module.name,
          'actor': actor.userId,
          'payload': jsonEncode(payload),
        }),
        transaction: tx,
        timeoutInSeconds: 300,
      );
      final events = <ArchiveAudit>[];
      for (final row in saved) {
        final key = row[1] as String;
        final prior = existing[key];
        events.add(
          archiveChange(
            actor,
            prior == null ? 'record.import.create' : 'record.import.update',
            '${row[0]}',
            module: module.name,
            before: prior == null ? {} : archiveRecordJson(prior),
            after: {
              'id': row[0],
              'module': module.name,
              'version': row[2],
              'values': prepared[key],
              'updatedAt': (row[3] as DateTime).toIso8601String(),
              'deletedAt': null,
            },
            details: {'sources': sources},
          ),
        );
      }
      await writeArchiveAudits(session, events, transaction: tx);
    }
    return {
      'created': created,
      'updated': updated,
      'unchanged': unchanged,
      'warnings': warnings,
    };
  }
}
