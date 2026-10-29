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

abstract class ArchiveImportRow
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ArchiveImportRow._({
    this.id,
    required this.jobId,
    required this.identityKey,
    required this.reference,
    required this.proceeding,
    required this.valuesJson,
  });

  factory ArchiveImportRow({
    int? id,
    required int jobId,
    required String identityKey,
    required String reference,
    required String proceeding,
    required String valuesJson,
  }) = _ArchiveImportRowImpl;

  factory ArchiveImportRow.fromJson(Map<String, dynamic> jsonSerialization) {
    return ArchiveImportRow(
      id: jsonSerialization['id'] as int?,
      jobId: jsonSerialization['jobId'] as int,
      identityKey: jsonSerialization['identityKey'] as String,
      reference: jsonSerialization['reference'] as String,
      proceeding: jsonSerialization['proceeding'] as String,
      valuesJson: jsonSerialization['valuesJson'] as String,
    );
  }

  static final t = ArchiveImportRowTable();

  static const db = ArchiveImportRowRepository._();

  @override
  int? id;

  int jobId;

  String identityKey;

  String reference;

  String proceeding;

  String valuesJson;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ArchiveImportRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ArchiveImportRow copyWith({
    int? id,
    int? jobId,
    String? identityKey,
    String? reference,
    String? proceeding,
    String? valuesJson,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ArchiveImportRow',
      if (id != null) 'id': id,
      'jobId': jobId,
      'identityKey': identityKey,
      'reference': reference,
      'proceeding': proceeding,
      'valuesJson': valuesJson,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ArchiveImportRowInclude include() {
    return ArchiveImportRowInclude._();
  }

  static ArchiveImportRowIncludeList includeList({
    _is.WhereExpressionBuilder<ArchiveImportRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchiveImportRowTable>? orderBy,
    _is.OrderByListBuilder<ArchiveImportRowTable>? orderByList,
    ArchiveImportRowInclude? include,
  }) {
    return ArchiveImportRowIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ArchiveImportRow.t),
      orderByList: orderByList?.call(ArchiveImportRow.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ArchiveImportRowImpl extends ArchiveImportRow {
  _ArchiveImportRowImpl({
    int? id,
    required int jobId,
    required String identityKey,
    required String reference,
    required String proceeding,
    required String valuesJson,
  }) : super._(
         id: id,
         jobId: jobId,
         identityKey: identityKey,
         reference: reference,
         proceeding: proceeding,
         valuesJson: valuesJson,
       );

  /// Returns a shallow copy of this [ArchiveImportRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ArchiveImportRow copyWith({
    Object? id = _Undefined,
    int? jobId,
    String? identityKey,
    String? reference,
    String? proceeding,
    String? valuesJson,
  }) {
    return ArchiveImportRow(
      id: id is int? ? id : this.id,
      jobId: jobId ?? this.jobId,
      identityKey: identityKey ?? this.identityKey,
      reference: reference ?? this.reference,
      proceeding: proceeding ?? this.proceeding,
      valuesJson: valuesJson ?? this.valuesJson,
    );
  }
}

class ArchiveImportRowUpdateTable
    extends _is.UpdateTable<ArchiveImportRowTable> {
  ArchiveImportRowUpdateTable(super.table);

  _is.ColumnValue<int, int> jobId(int value) => _is.ColumnValue(
    table.jobId,
    value,
  );

  _is.ColumnValue<String, String> identityKey(String value) => _is.ColumnValue(
    table.identityKey,
    value,
  );

  _is.ColumnValue<String, String> reference(String value) => _is.ColumnValue(
    table.reference,
    value,
  );

  _is.ColumnValue<String, String> proceeding(String value) => _is.ColumnValue(
    table.proceeding,
    value,
  );

  _is.ColumnValue<String, String> valuesJson(String value) => _is.ColumnValue(
    table.valuesJson,
    value,
  );
}

class ArchiveImportRowTable extends _is.Table<int?> {
  ArchiveImportRowTable({super.tableRelation})
    : super(tableName: 'archive_import_row') {
    updateTable = ArchiveImportRowUpdateTable(this);
    jobId = _is.ColumnInt(
      'jobId',
      this,
    );
    identityKey = _is.ColumnString(
      'identityKey',
      this,
    );
    reference = _is.ColumnString(
      'reference',
      this,
    );
    proceeding = _is.ColumnString(
      'proceeding',
      this,
    );
    valuesJson = _is.ColumnString(
      'valuesJson',
      this,
    );
  }

  late final ArchiveImportRowUpdateTable updateTable;

  late final _is.ColumnInt jobId;

  late final _is.ColumnString identityKey;

  late final _is.ColumnString reference;

  late final _is.ColumnString proceeding;

  late final _is.ColumnString valuesJson;

  @override
  List<_is.Column> get columns => [
    id,
    jobId,
    identityKey,
    reference,
    proceeding,
    valuesJson,
  ];
}

class ArchiveImportRowInclude extends _is.IncludeObject {
  ArchiveImportRowInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ArchiveImportRow.t;
}

class ArchiveImportRowIncludeList extends _is.IncludeList {
  ArchiveImportRowIncludeList._({
    _is.WhereExpressionBuilder<ArchiveImportRowTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ArchiveImportRow.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ArchiveImportRow.t;
}

class ArchiveImportRowRepository {
  const ArchiveImportRowRepository._();

  /// Returns a list of [ArchiveImportRow]s matching the given query parameters.
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
  Future<List<ArchiveImportRow>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchiveImportRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchiveImportRowTable>? orderBy,
    _is.OrderByListBuilder<ArchiveImportRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ArchiveImportRow>(
      where: where?.call(ArchiveImportRow.t),
      orderBy: orderBy?.call(ArchiveImportRow.t),
      orderByList: orderByList?.call(ArchiveImportRow.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ArchiveImportRow] matching the given query parameters.
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
  Future<ArchiveImportRow?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchiveImportRowTable>? where,
    int? offset,
    _is.OrderByBuilder<ArchiveImportRowTable>? orderBy,
    _is.OrderByListBuilder<ArchiveImportRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ArchiveImportRow>(
      where: where?.call(ArchiveImportRow.t),
      orderBy: orderBy?.call(ArchiveImportRow.t),
      orderByList: orderByList?.call(ArchiveImportRow.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ArchiveImportRow] by its [id] or null if no such row exists.
  Future<ArchiveImportRow?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ArchiveImportRow>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ArchiveImportRow]s in the list and returns the inserted rows.
  ///
  /// The returned [ArchiveImportRow]s will have their `id` fields set.
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
  Future<List<ArchiveImportRow>> insert(
    _is.DatabaseSession session,
    List<ArchiveImportRow> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ArchiveImportRow>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ArchiveImportRow] and returns the inserted row.
  ///
  /// The returned [ArchiveImportRow] will have its `id` field set.
  Future<ArchiveImportRow> insertRow(
    _is.DatabaseSession session,
    ArchiveImportRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ArchiveImportRow>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ArchiveImportRow]s in the list and returns the resulting rows.
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
  /// The returned [ArchiveImportRow]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveImportRow>> upsert(
    _is.DatabaseSession session,
    List<ArchiveImportRow> rows, {
    required _is.ColumnSelections<ArchiveImportRowTable> conflictColumns,
    _is.ColumnSelections<ArchiveImportRowTable>? updateColumns,
    _is.WhereExpressionBuilder<ArchiveImportRowTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ArchiveImportRow>(
      rows,
      conflictColumns: conflictColumns(ArchiveImportRow.t),
      updateColumns: updateColumns?.call(ArchiveImportRow.t),
      updateWhere: updateWhere?.call(ArchiveImportRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ArchiveImportRow] and returns the resulting row.
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
  /// The returned [ArchiveImportRow] will have its `id` field set.
  Future<ArchiveImportRow?> upsertRow(
    _is.DatabaseSession session,
    ArchiveImportRow row, {
    required _is.ColumnSelections<ArchiveImportRowTable> conflictColumns,
    _is.ColumnSelections<ArchiveImportRowTable>? updateColumns,
    _is.WhereExpressionBuilder<ArchiveImportRowTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ArchiveImportRow>(
      row,
      conflictColumns: conflictColumns(ArchiveImportRow.t),
      updateColumns: updateColumns?.call(ArchiveImportRow.t),
      updateWhere: updateWhere?.call(ArchiveImportRow.t),
      transaction: transaction,
    );
  }

  /// Updates all [ArchiveImportRow]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveImportRow>> update(
    _is.DatabaseSession session,
    List<ArchiveImportRow> rows, {
    _is.ColumnSelections<ArchiveImportRowTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ArchiveImportRow>(
      rows,
      columns: columns?.call(ArchiveImportRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ArchiveImportRow]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ArchiveImportRow> updateRow(
    _is.DatabaseSession session,
    ArchiveImportRow row, {
    _is.ColumnSelections<ArchiveImportRowTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ArchiveImportRow>(
      row,
      columns: columns?.call(ArchiveImportRow.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ArchiveImportRow] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ArchiveImportRow?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ArchiveImportRowUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ArchiveImportRow>(
      id,
      columnValues: columnValues(ArchiveImportRow.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ArchiveImportRow]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveImportRow>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ArchiveImportRowUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<ArchiveImportRowTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchiveImportRowTable>? orderBy,
    _is.OrderByListBuilder<ArchiveImportRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ArchiveImportRow>(
      columnValues: columnValues(ArchiveImportRow.t.updateTable),
      where: where(ArchiveImportRow.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ArchiveImportRow.t),
      orderByList: orderByList?.call(ArchiveImportRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ArchiveImportRow]s in the list and returns the deleted rows.
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
  Future<List<ArchiveImportRow>> delete(
    _is.DatabaseSession session,
    List<ArchiveImportRow> rows, {
    _is.OrderByBuilder<ArchiveImportRowTable>? orderBy,
    _is.OrderByListBuilder<ArchiveImportRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ArchiveImportRow>(
      rows,
      orderBy: orderBy?.call(ArchiveImportRow.t),
      orderByList: orderByList?.call(ArchiveImportRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ArchiveImportRow].
  Future<ArchiveImportRow> deleteRow(
    _is.DatabaseSession session,
    ArchiveImportRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ArchiveImportRow>(
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
  Future<List<ArchiveImportRow>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ArchiveImportRowTable> where,
    _is.OrderByBuilder<ArchiveImportRowTable>? orderBy,
    _is.OrderByListBuilder<ArchiveImportRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ArchiveImportRow>(
      where: where(ArchiveImportRow.t),
      orderBy: orderBy?.call(ArchiveImportRow.t),
      orderByList: orderByList?.call(ArchiveImportRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchiveImportRowTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ArchiveImportRow>(
      where: where?.call(ArchiveImportRow.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ArchiveImportRow] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ArchiveImportRowTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ArchiveImportRow>(
      where: where(ArchiveImportRow.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
