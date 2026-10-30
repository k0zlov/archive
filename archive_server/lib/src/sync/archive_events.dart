import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

const archiveEventsChannel = 'archive-changes-v1';
final _notifyingSessions = Expando<bool>();

/// Ordinary archive writes share this lock; maintenance takes it exclusively.
/// Acquire before touching rows, so cleanup cannot deadlock with imports/files.
Future<T> archiveTransaction<T>(
  Session session,
  Future<T> Function(Transaction) work,
) => session.db.transaction((tx) async {
  await session.db.unsafeQuery(
    'SELECT pg_advisory_xact_lock_shared(418243, 2)',
    transaction: tx,
  );
  return work(tx);
});

Future<int> archiveResetCursor(
  Session session, {
  Transaction? transaction,
}) async =>
    (await ArchiveSyncState.db.findById(
      session,
      1,
      transaction: transaction,
    ))?.resetCursor ??
    0;

/// Reserve a journal ID without writing an audit row. This still invalidates old
/// cursors when new events overtake them after a complete audit purge.
Future<void> resetArchiveCursor(
  Session session,
  Transaction transaction,
) async {
  final rows = await session.db.unsafeQuery(
    "SELECT nextval(pg_get_serial_sequence('archive_audit', 'id'))",
    transaction: transaction,
  );
  final cursor = rows.single[0] as int;
  await session.db.unsafeExecute(
    'INSERT INTO archive_sync_state (id, "resetCursor") VALUES (1, @cursor) '
    'ON CONFLICT (id) DO UPDATE SET "resetCursor" = EXCLUDED."resetCursor"',
    parameters: QueryParameters.named({'cursor': cursor}),
    transaction: transaction,
  );
}

/// Allocate journal IDs under a transaction lock so cursor order is commit order.
/// Notifications are only hints: a reconnect always reads the durable journal.
Future<void> writeArchiveAudit(
  Session session,
  ArchiveAudit event, {
  required Transaction transaction,
}) => writeArchiveAudits(session, [event], transaction: transaction);

Future<void> writeArchiveAudits(
  Session session,
  List<ArchiveAudit> events, {
  required Transaction transaction,
}) async {
  await session.db.unsafeQuery(
    'SELECT pg_advisory_xact_lock(418243, 1)',
    transaction: transaction,
  );
  await ArchiveAudit.db.insert(session, events, transaction: transaction);
  if (_notifyingSessions[session] != true) {
    _notifyingSessions[session] = true;
    session.addWillCloseListener((s) => notifyArchive(s, 'data'));
  }
}

Future<void> notifyArchive(Session session, String kind) async {
  try {
    await session.messages.postMessage(
      archiveEventsChannel,
      ArchiveSignal(kind: kind),
    );
  } catch (_) {
    // A committed mutation must not fail because best-effort notification failed.
    session.log(
      'Archive notification deferred to reconciliation.',
      level: LogLevel.warning,
    );
  }
}

Map<String, dynamic> archiveAuditJson(ArchiveAudit event) => {
  'id': event.id,
  'actor': event.actorEmail.isEmpty ? event.actorId : event.actorEmail,
  'action': event.action,
  'target': event.target,
  'module': event.module,
  'at': event.createdAt.toIso8601String(),
};
