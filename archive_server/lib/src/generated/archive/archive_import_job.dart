/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;

abstract class ArchiveImportJob
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ArchiveImportJob._({
    this.id,
    required this.userId,
    required this.module,
    String? status,
    int? receivedRows,
    int? skippedRows,
    int? lastOffset,
    String? lastBatchJson,
    bool? replaceExisting,
    String? sourceNamesJson,
    String? resultJson,
    DateTime? createdAt,
  }) : status = status ?? 'open',
       receivedRows = receivedRows ?? 0,
       skippedRows = skippedRows ?? 0,
       lastOffset = lastOffset ?? -1,
       lastBatchJson = lastBatchJson ?? '',
       replaceExisting = replaceExisting ?? false,
       sourceNamesJson = sourceNamesJson ?? '[]',
       resultJson = resultJson ?? '{}',
       createdAt = createdAt ?? DateTime.now();

  factory ArchiveImportJob({
    int? id,
    required String userId,
    required String module,
    String? status,
    int? receivedRows,
    int? skippedRows,
    int? lastOffset,
    String? lastBatchJson,
    bool? replaceExisting,
    String? sourceNamesJson,
    String? resultJson,
    DateTime? createdAt,
  }) = _ArchiveImportJobImpl;

  factory ArchiveImportJob.fromJson(Map<String, dynamic> jsonSerialization) {
    return ArchiveImportJob(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      module: jsonSerialization['module'] as String,
      status: jsonSerialization['status'] as String?,
      receivedRows: jsonSerialization['receivedRows'] as int?,
      skippedRows: jsonSerialization['skippedRows'] as int?,
      lastOffset: jsonSerialization['lastOffset'] as int?,
      lastBatchJson: jsonSerialization['lastBatchJson'] as String?,
      replaceExisting: jsonSerialization['replaceExisting'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['replaceExisting'],
            ),
      sourceNamesJson: jsonSerialization['sourceNamesJson'] as String?,
      resultJson: jsonSerialization['resultJson'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = ArchiveImportJobTable();

  static const db = ArchiveImportJobRepository._();

  @override
  int? id;

  String userId;

  String module;

  String status;

  int receivedRows;

  int skippedRows;

  int lastOffset;

  String lastBatchJson;

  bool replaceExisting;

  String sourceNamesJson;

  String resultJson;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ArchiveImportJob]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ArchiveImportJob copyWith({
    int? id,
    String? userId,
    String? module,
    String? status,
    int? receivedRows,
    int? skippedRows,
    int? lastOffset,
    String? lastBatchJson,
    bool? replaceExisting,
    String? sourceNamesJson,
    String? resultJson,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ArchiveImportJob',
      if (id != null) 'id': id,
      'userId': userId,
      'module': module,
      'status': status,
      'receivedRows': receivedRows,
      'skippedRows': skippedRows,
      'lastOffset': lastOffset,
      'lastBatchJson': lastBatchJson,
      'replaceExisting': replaceExisting,
      'sourceNamesJson': sourceNamesJson,
      'resultJson': resultJson,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ArchiveImportJobInclude include() {
    return ArchiveImportJobInclude._();
  }

  static ArchiveImportJobIncludeList includeList({
    _is.WhereExpressionBuilder<ArchiveImportJobTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchiveImportJobTable>? orderBy,
    _is.OrderByListBuilder<ArchiveImportJobTable>? orderByList,
    ArchiveImportJobInclude? include,
  }) {
    return ArchiveImportJobIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ArchiveImportJob.t),
      orderByList: orderByList?.call(ArchiveImportJob.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ArchiveImportJobImpl extends ArchiveImportJob {
  _ArchiveImportJobImpl({
    int? id,
    required String userId,
    required String module,
    String? status,
    int? receivedRows,
    int? skippedRows,
    int? lastOffset,
    String? lastBatchJson,
    bool? replaceExisting,
    String? sourceNamesJson,
    String? resultJson,
    DateTime? createdAt,
  }) : super._(
         id: id,
         userId: userId,
         module: module,
         status: status,
         receivedRows: receivedRows,
         skippedRows: skippedRows,
         lastOffset: lastOffset,
         lastBatchJson: lastBatchJson,
         replaceExisting: replaceExisting,
         sourceNamesJson: sourceNamesJson,
         resultJson: resultJson,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ArchiveImportJob]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ArchiveImportJob copyWith({
    Object? id = _Undefined,
    String? userId,
    String? module,
    String? status,
    int? receivedRows,
    int? skippedRows,
    int? lastOffset,
    String? lastBatchJson,
    bool? replaceExisting,
    String? sourceNamesJson,
    String? resultJson,
    DateTime? createdAt,
  }) {
    return ArchiveImportJob(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      module: module ?? this.module,
      status: status ?? this.status,
      receivedRows: receivedRows ?? this.receivedRows,
      skippedRows: skippedRows ?? this.skippedRows,
      lastOffset: lastOffset ?? this.lastOffset,
      lastBatchJson: lastBatchJson ?? this.lastBatchJson,
      replaceExisting: replaceExisting ?? this.replaceExisting,
      sourceNamesJson: sourceNamesJson ?? this.sourceNamesJson,
      resultJson: resultJson ?? this.resultJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ArchiveImportJobUpdateTable
    extends _is.UpdateTable<ArchiveImportJobTable> {
  ArchiveImportJobUpdateTable(super.table);

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> module(String value) => _is.ColumnValue(
    table.module,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<int, int> receivedRows(int value) => _is.ColumnValue(
    table.receivedRows,
    value,
  );

  _is.ColumnValue<int, int> skippedRows(int value) => _is.ColumnValue(
    table.skippedRows,
    value,
  );

  _is.ColumnValue<int, int> lastOffset(int value) => _is.ColumnValue(
    table.lastOffset,
    value,
  );

  _is.ColumnValue<String, String> lastBatchJson(String value) =>
      _is.ColumnValue(
        table.lastBatchJson,
        value,
      );

  _is.ColumnValue<bool, bool> replaceExisting(bool value) => _is.ColumnValue(
    table.replaceExisting,
    value,
  );

  _is.ColumnValue<String, String> sourceNamesJson(String value) =>
      _is.ColumnValue(
        table.sourceNamesJson,
        value,
      );

  _is.ColumnValue<String, String> resultJson(String value) => _is.ColumnValue(
    table.resultJson,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class ArchiveImportJobTable extends _is.Table<int?> {
  ArchiveImportJobTable({super.tableRelation})
    : super(tableName: 'archive_import_job') {
    updateTable = ArchiveImportJobUpdateTable(this);
    userId = _is.ColumnString(
      'userId',
      this,
    );
    module = _is.ColumnString(
      'module',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
      hasDefault: true,
    );
    receivedRows = _is.ColumnInt(
      'receivedRows',
      this,
      hasDefault: true,
    );
    skippedRows = _is.ColumnInt(
      'skippedRows',
      this,
      hasDefault: true,
    );
    lastOffset = _is.ColumnInt(
      'lastOffset',
      this,
      hasDefault: true,
    );
    lastBatchJson = _is.ColumnString(
      'lastBatchJson',
      this,
      hasDefault: true,
    );
    replaceExisting = _is.ColumnBool(
      'replaceExisting',
      this,
      hasDefault: true,
    );
    sourceNamesJson = _is.ColumnString(
      'sourceNamesJson',
      this,
      hasDefault: true,
    );
    resultJson = _is.ColumnString(
      'resultJson',
      this,
      hasDefault: true,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final ArchiveImportJobUpdateTable updateTable;

  late final _is.ColumnString userId;

  late final _is.ColumnString module;

  late final _is.ColumnString status;

  late final _is.ColumnInt receivedRows;

  late final _is.ColumnInt skippedRows;

  late final _is.ColumnInt lastOffset;

  late final _is.ColumnString lastBatchJson;

  late final _is.ColumnBool replaceExisting;

  late final _is.ColumnString sourceNamesJson;

  late final _is.ColumnString resultJson;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    module,
    status,
    receivedRows,
    skippedRows,
    lastOffset,
    lastBatchJson,
    replaceExisting,
    sourceNamesJson,
    resultJson,
    createdAt,
  ];
}

class ArchiveImportJobInclude extends _is.IncludeObject {
  ArchiveImportJobInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ArchiveImportJob.t;
}

class ArchiveImportJobIncludeList extends _is.IncludeList {
  ArchiveImportJobIncludeList._({
    _is.WhereExpressionBuilder<ArchiveImportJobTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ArchiveImportJob.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ArchiveImportJob.t;
}

class ArchiveImportJobRepository {
  const ArchiveImportJobRepository._();

  /// Returns a list of [ArchiveImportJob]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<ArchiveImportJob>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchiveImportJobTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchiveImportJobTable>? orderBy,
    _is.OrderByListBuilder<ArchiveImportJobTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ArchiveImportJob>(
      where: where?.call(ArchiveImportJob.t),
      orderBy: orderBy?.call(ArchiveImportJob.t),
      orderByList: orderByList?.call(ArchiveImportJob.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ArchiveImportJob] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<ArchiveImportJob?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchiveImportJobTable>? where,
    int? offset,
    _is.OrderByBuilder<ArchiveImportJobTable>? orderBy,
    _is.OrderByListBuilder<ArchiveImportJobTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ArchiveImportJob>(
      where: where?.call(ArchiveImportJob.t),
      orderBy: orderBy?.call(ArchiveImportJob.t),
      orderByList: orderByList?.call(ArchiveImportJob.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ArchiveImportJob] by its [id] or null if no such row exists.
  Future<ArchiveImportJob?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ArchiveImportJob>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ArchiveImportJob]s in the list and returns the inserted rows.
  ///
  /// The returned [ArchiveImportJob]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveImportJob>> insert(
    _is.DatabaseSession session,
    List<ArchiveImportJob> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ArchiveImportJob>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ArchiveImportJob] and returns the inserted row.
  ///
  /// The returned [ArchiveImportJob] will have its `id` field set.
  Future<ArchiveImportJob> insertRow(
    _is.DatabaseSession session,
    ArchiveImportJob row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ArchiveImportJob>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ArchiveImportJob]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [ArchiveImportJob]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveImportJob>> upsert(
    _is.DatabaseSession session,
    List<ArchiveImportJob> rows, {
    required _is.ColumnSelections<ArchiveImportJobTable> conflictColumns,
    _is.ColumnSelections<ArchiveImportJobTable>? updateColumns,
    _is.WhereExpressionBuilder<ArchiveImportJobTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ArchiveImportJob>(
      rows,
      conflictColumns: conflictColumns(ArchiveImportJob.t),
      updateColumns: updateColumns?.call(ArchiveImportJob.t),
      updateWhere: updateWhere?.call(ArchiveImportJob.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ArchiveImportJob] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [ArchiveImportJob] will have its `id` field set.
  Future<ArchiveImportJob?> upsertRow(
    _is.DatabaseSession session,
    ArchiveImportJob row, {
    required _is.ColumnSelections<ArchiveImportJobTable> conflictColumns,
    _is.ColumnSelections<ArchiveImportJobTable>? updateColumns,
    _is.WhereExpressionBuilder<ArchiveImportJobTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ArchiveImportJob>(
      row,
      conflictColumns: conflictColumns(ArchiveImportJob.t),
      updateColumns: updateColumns?.call(ArchiveImportJob.t),
      updateWhere: updateWhere?.call(ArchiveImportJob.t),
      transaction: transaction,
    );
  }

  /// Updates all [ArchiveImportJob]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveImportJob>> update(
    _is.DatabaseSession session,
    List<ArchiveImportJob> rows, {
    _is.ColumnSelections<ArchiveImportJobTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ArchiveImportJob>(
      rows,
      columns: columns?.call(ArchiveImportJob.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ArchiveImportJob]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ArchiveImportJob> updateRow(
    _is.DatabaseSession session,
    ArchiveImportJob row, {
    _is.ColumnSelections<ArchiveImportJobTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ArchiveImportJob>(
      row,
      columns: columns?.call(ArchiveImportJob.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ArchiveImportJob] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ArchiveImportJob?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ArchiveImportJobUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ArchiveImportJob>(
      id,
      columnValues: columnValues(ArchiveImportJob.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ArchiveImportJob]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveImportJob>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ArchiveImportJobUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<ArchiveImportJobTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchiveImportJobTable>? orderBy,
    _is.OrderByListBuilder<ArchiveImportJobTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ArchiveImportJob>(
      columnValues: columnValues(ArchiveImportJob.t.updateTable),
      where: where(ArchiveImportJob.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ArchiveImportJob.t),
      orderByList: orderByList?.call(ArchiveImportJob.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ArchiveImportJob]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveImportJob>> delete(
    _is.DatabaseSession session,
    List<ArchiveImportJob> rows, {
    _is.OrderByBuilder<ArchiveImportJobTable>? orderBy,
    _is.OrderByListBuilder<ArchiveImportJobTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ArchiveImportJob>(
      rows,
      orderBy: orderBy?.call(ArchiveImportJob.t),
      orderByList: orderByList?.call(ArchiveImportJob.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ArchiveImportJob].
  Future<ArchiveImportJob> deleteRow(
    _is.DatabaseSession session,
    ArchiveImportJob row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ArchiveImportJob>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveImportJob>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ArchiveImportJobTable> where,
    _is.OrderByBuilder<ArchiveImportJobTable>? orderBy,
    _is.OrderByListBuilder<ArchiveImportJobTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ArchiveImportJob>(
      where: where(ArchiveImportJob.t),
      orderBy: orderBy?.call(ArchiveImportJob.t),
      orderByList: orderByList?.call(ArchiveImportJob.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchiveImportJobTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ArchiveImportJob>(
      where: where?.call(ArchiveImportJob.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ArchiveImportJob] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ArchiveImportJobTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ArchiveImportJob>(
      where: where(ArchiveImportJob.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
