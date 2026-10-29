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

/// History of changes to archive cards and account permissions.
abstract class ArchiveAudit
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ArchiveAudit._({
    this.id,
    required this.actorId,
    required this.action,
    required this.target,
    String? actorEmail,
    String? module,
    String? beforeJson,
    String? afterJson,
    String? detailsJson,
    DateTime? createdAt,
  }) : actorEmail = actorEmail ?? '',
       module = module ?? '',
       beforeJson = beforeJson ?? '{}',
       afterJson = afterJson ?? '{}',
       detailsJson = detailsJson ?? '{}',
       createdAt = createdAt ?? DateTime.now();

  factory ArchiveAudit({
    int? id,
    required String actorId,
    required String action,
    required String target,
    String? actorEmail,
    String? module,
    String? beforeJson,
    String? afterJson,
    String? detailsJson,
    DateTime? createdAt,
  }) = _ArchiveAuditImpl;

  factory ArchiveAudit.fromJson(Map<String, dynamic> jsonSerialization) {
    return ArchiveAudit(
      id: jsonSerialization['id'] as int?,
      actorId: jsonSerialization['actorId'] as String,
      action: jsonSerialization['action'] as String,
      target: jsonSerialization['target'] as String,
      actorEmail: jsonSerialization['actorEmail'] as String?,
      module: jsonSerialization['module'] as String?,
      beforeJson: jsonSerialization['beforeJson'] as String?,
      afterJson: jsonSerialization['afterJson'] as String?,
      detailsJson: jsonSerialization['detailsJson'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = ArchiveAuditTable();

  static const db = ArchiveAuditRepository._();

  @override
  int? id;

  String actorId;

  String action;

  String target;

  String actorEmail;

  String module;

  String beforeJson;

  String afterJson;

  String detailsJson;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ArchiveAudit]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ArchiveAudit copyWith({
    int? id,
    String? actorId,
    String? action,
    String? target,
    String? actorEmail,
    String? module,
    String? beforeJson,
    String? afterJson,
    String? detailsJson,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ArchiveAudit',
      if (id != null) 'id': id,
      'actorId': actorId,
      'action': action,
      'target': target,
      'actorEmail': actorEmail,
      'module': module,
      'beforeJson': beforeJson,
      'afterJson': afterJson,
      'detailsJson': detailsJson,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ArchiveAuditInclude include() {
    return ArchiveAuditInclude._();
  }

  static ArchiveAuditIncludeList includeList({
    _is.WhereExpressionBuilder<ArchiveAuditTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchiveAuditTable>? orderBy,
    _is.OrderByListBuilder<ArchiveAuditTable>? orderByList,
    ArchiveAuditInclude? include,
  }) {
    return ArchiveAuditIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ArchiveAudit.t),
      orderByList: orderByList?.call(ArchiveAudit.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ArchiveAuditImpl extends ArchiveAudit {
  _ArchiveAuditImpl({
    int? id,
    required String actorId,
    required String action,
    required String target,
    String? actorEmail,
    String? module,
    String? beforeJson,
    String? afterJson,
    String? detailsJson,
    DateTime? createdAt,
  }) : super._(
         id: id,
         actorId: actorId,
         action: action,
         target: target,
         actorEmail: actorEmail,
         module: module,
         beforeJson: beforeJson,
         afterJson: afterJson,
         detailsJson: detailsJson,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ArchiveAudit]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ArchiveAudit copyWith({
    Object? id = _Undefined,
    String? actorId,
    String? action,
    String? target,
    String? actorEmail,
    String? module,
    String? beforeJson,
    String? afterJson,
    String? detailsJson,
    DateTime? createdAt,
  }) {
    return ArchiveAudit(
      id: id is int? ? id : this.id,
      actorId: actorId ?? this.actorId,
      action: action ?? this.action,
      target: target ?? this.target,
      actorEmail: actorEmail ?? this.actorEmail,
      module: module ?? this.module,
      beforeJson: beforeJson ?? this.beforeJson,
      afterJson: afterJson ?? this.afterJson,
      detailsJson: detailsJson ?? this.detailsJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ArchiveAuditUpdateTable extends _is.UpdateTable<ArchiveAuditTable> {
  ArchiveAuditUpdateTable(super.table);

  _is.ColumnValue<String, String> actorId(String value) => _is.ColumnValue(
    table.actorId,
    value,
  );

  _is.ColumnValue<String, String> action(String value) => _is.ColumnValue(
    table.action,
    value,
  );

  _is.ColumnValue<String, String> target(String value) => _is.ColumnValue(
    table.target,
    value,
  );

  _is.ColumnValue<String, String> actorEmail(String value) => _is.ColumnValue(
    table.actorEmail,
    value,
  );

  _is.ColumnValue<String, String> module(String value) => _is.ColumnValue(
    table.module,
    value,
  );

  _is.ColumnValue<String, String> beforeJson(String value) => _is.ColumnValue(
    table.beforeJson,
    value,
  );

  _is.ColumnValue<String, String> afterJson(String value) => _is.ColumnValue(
    table.afterJson,
    value,
  );

  _is.ColumnValue<String, String> detailsJson(String value) => _is.ColumnValue(
    table.detailsJson,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class ArchiveAuditTable extends _is.Table<int?> {
  ArchiveAuditTable({super.tableRelation}) : super(tableName: 'archive_audit') {
    updateTable = ArchiveAuditUpdateTable(this);
    actorId = _is.ColumnString(
      'actorId',
      this,
    );
    action = _is.ColumnString(
      'action',
      this,
    );
    target = _is.ColumnString(
      'target',
      this,
    );
    actorEmail = _is.ColumnString(
      'actorEmail',
      this,
      hasDefault: true,
    );
    module = _is.ColumnString(
      'module',
      this,
      hasDefault: true,
    );
    beforeJson = _is.ColumnString(
      'beforeJson',
      this,
      hasDefault: true,
    );
    afterJson = _is.ColumnString(
      'afterJson',
      this,
      hasDefault: true,
    );
    detailsJson = _is.ColumnString(
      'detailsJson',
      this,
      hasDefault: true,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final ArchiveAuditUpdateTable updateTable;

  late final _is.ColumnString actorId;

  late final _is.ColumnString action;

  late final _is.ColumnString target;

  late final _is.ColumnString actorEmail;

  late final _is.ColumnString module;

  late final _is.ColumnString beforeJson;

  late final _is.ColumnString afterJson;

  late final _is.ColumnString detailsJson;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    actorId,
    action,
    target,
    actorEmail,
    module,
    beforeJson,
    afterJson,
    detailsJson,
    createdAt,
  ];
}

class ArchiveAuditInclude extends _is.IncludeObject {
  ArchiveAuditInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ArchiveAudit.t;
}

class ArchiveAuditIncludeList extends _is.IncludeList {
  ArchiveAuditIncludeList._({
    _is.WhereExpressionBuilder<ArchiveAuditTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ArchiveAudit.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ArchiveAudit.t;
}

class ArchiveAuditRepository {
  const ArchiveAuditRepository._();

  /// Returns a list of [ArchiveAudit]s matching the given query parameters.
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
  Future<List<ArchiveAudit>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchiveAuditTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchiveAuditTable>? orderBy,
    _is.OrderByListBuilder<ArchiveAuditTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ArchiveAudit>(
      where: where?.call(ArchiveAudit.t),
      orderBy: orderBy?.call(ArchiveAudit.t),
      orderByList: orderByList?.call(ArchiveAudit.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ArchiveAudit] matching the given query parameters.
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
  Future<ArchiveAudit?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchiveAuditTable>? where,
    int? offset,
    _is.OrderByBuilder<ArchiveAuditTable>? orderBy,
    _is.OrderByListBuilder<ArchiveAuditTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ArchiveAudit>(
      where: where?.call(ArchiveAudit.t),
      orderBy: orderBy?.call(ArchiveAudit.t),
      orderByList: orderByList?.call(ArchiveAudit.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ArchiveAudit] by its [id] or null if no such row exists.
  Future<ArchiveAudit?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ArchiveAudit>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ArchiveAudit]s in the list and returns the inserted rows.
  ///
  /// The returned [ArchiveAudit]s will have their `id` fields set.
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
  Future<List<ArchiveAudit>> insert(
    _is.DatabaseSession session,
    List<ArchiveAudit> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ArchiveAudit>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ArchiveAudit] and returns the inserted row.
  ///
  /// The returned [ArchiveAudit] will have its `id` field set.
  Future<ArchiveAudit> insertRow(
    _is.DatabaseSession session,
    ArchiveAudit row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ArchiveAudit>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ArchiveAudit]s in the list and returns the resulting rows.
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
  /// The returned [ArchiveAudit]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveAudit>> upsert(
    _is.DatabaseSession session,
    List<ArchiveAudit> rows, {
    required _is.ColumnSelections<ArchiveAuditTable> conflictColumns,
    _is.ColumnSelections<ArchiveAuditTable>? updateColumns,
    _is.WhereExpressionBuilder<ArchiveAuditTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ArchiveAudit>(
      rows,
      conflictColumns: conflictColumns(ArchiveAudit.t),
      updateColumns: updateColumns?.call(ArchiveAudit.t),
      updateWhere: updateWhere?.call(ArchiveAudit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ArchiveAudit] and returns the resulting row.
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
  /// The returned [ArchiveAudit] will have its `id` field set.
  Future<ArchiveAudit?> upsertRow(
    _is.DatabaseSession session,
    ArchiveAudit row, {
    required _is.ColumnSelections<ArchiveAuditTable> conflictColumns,
    _is.ColumnSelections<ArchiveAuditTable>? updateColumns,
    _is.WhereExpressionBuilder<ArchiveAuditTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ArchiveAudit>(
      row,
      conflictColumns: conflictColumns(ArchiveAudit.t),
      updateColumns: updateColumns?.call(ArchiveAudit.t),
      updateWhere: updateWhere?.call(ArchiveAudit.t),
      transaction: transaction,
    );
  }

  /// Updates all [ArchiveAudit]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveAudit>> update(
    _is.DatabaseSession session,
    List<ArchiveAudit> rows, {
    _is.ColumnSelections<ArchiveAuditTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ArchiveAudit>(
      rows,
      columns: columns?.call(ArchiveAudit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ArchiveAudit]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ArchiveAudit> updateRow(
    _is.DatabaseSession session,
    ArchiveAudit row, {
    _is.ColumnSelections<ArchiveAuditTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ArchiveAudit>(
      row,
      columns: columns?.call(ArchiveAudit.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ArchiveAudit] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ArchiveAudit?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ArchiveAuditUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ArchiveAudit>(
      id,
      columnValues: columnValues(ArchiveAudit.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ArchiveAudit]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveAudit>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ArchiveAuditUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ArchiveAuditTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchiveAuditTable>? orderBy,
    _is.OrderByListBuilder<ArchiveAuditTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ArchiveAudit>(
      columnValues: columnValues(ArchiveAudit.t.updateTable),
      where: where(ArchiveAudit.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ArchiveAudit.t),
      orderByList: orderByList?.call(ArchiveAudit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ArchiveAudit]s in the list and returns the deleted rows.
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
  Future<List<ArchiveAudit>> delete(
    _is.DatabaseSession session,
    List<ArchiveAudit> rows, {
    _is.OrderByBuilder<ArchiveAuditTable>? orderBy,
    _is.OrderByListBuilder<ArchiveAuditTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ArchiveAudit>(
      rows,
      orderBy: orderBy?.call(ArchiveAudit.t),
      orderByList: orderByList?.call(ArchiveAudit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ArchiveAudit].
  Future<ArchiveAudit> deleteRow(
    _is.DatabaseSession session,
    ArchiveAudit row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ArchiveAudit>(
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
  Future<List<ArchiveAudit>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ArchiveAuditTable> where,
    _is.OrderByBuilder<ArchiveAuditTable>? orderBy,
    _is.OrderByListBuilder<ArchiveAuditTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ArchiveAudit>(
      where: where(ArchiveAudit.t),
      orderBy: orderBy?.call(ArchiveAudit.t),
      orderByList: orderByList?.call(ArchiveAudit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchiveAuditTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ArchiveAudit>(
      where: where?.call(ArchiveAudit.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ArchiveAudit] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ArchiveAuditTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ArchiveAudit>(
      where: where(ArchiveAudit.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
