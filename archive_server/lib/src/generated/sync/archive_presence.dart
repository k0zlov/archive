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

/// An expiring connection lease, not an authentication token.
abstract class ArchivePresence
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ArchivePresence._({
    this.id,
    required this.userId,
    required this.authId,
    required this.expiresAt,
  });

  factory ArchivePresence({
    int? id,
    required String userId,
    required String authId,
    required DateTime expiresAt,
  }) = _ArchivePresenceImpl;

  factory ArchivePresence.fromJson(Map<String, dynamic> jsonSerialization) {
    return ArchivePresence(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      authId: jsonSerialization['authId'] as String,
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  static final t = ArchivePresenceTable();

  static const db = ArchivePresenceRepository._();

  @override
  int? id;

  String userId;

  String authId;

  DateTime expiresAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ArchivePresence]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ArchivePresence copyWith({
    int? id,
    String? userId,
    String? authId,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ArchivePresence',
      if (id != null) 'id': id,
      'userId': userId,
      'authId': authId,
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ArchivePresenceInclude include() {
    return ArchivePresenceInclude._();
  }

  static ArchivePresenceIncludeList includeList({
    _is.WhereExpressionBuilder<ArchivePresenceTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchivePresenceTable>? orderBy,
    _is.OrderByListBuilder<ArchivePresenceTable>? orderByList,
    ArchivePresenceInclude? include,
  }) {
    return ArchivePresenceIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ArchivePresence.t),
      orderByList: orderByList?.call(ArchivePresence.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ArchivePresenceImpl extends ArchivePresence {
  _ArchivePresenceImpl({
    int? id,
    required String userId,
    required String authId,
    required DateTime expiresAt,
  }) : super._(
         id: id,
         userId: userId,
         authId: authId,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [ArchivePresence]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ArchivePresence copyWith({
    Object? id = _Undefined,
    String? userId,
    String? authId,
    DateTime? expiresAt,
  }) {
    return ArchivePresence(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      authId: authId ?? this.authId,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class ArchivePresenceUpdateTable extends _is.UpdateTable<ArchivePresenceTable> {
  ArchivePresenceUpdateTable(super.table);

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> authId(String value) => _is.ColumnValue(
    table.authId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );
}

class ArchivePresenceTable extends _is.Table<int?> {
  ArchivePresenceTable({super.tableRelation})
    : super(tableName: 'archive_presence') {
    updateTable = ArchivePresenceUpdateTable(this);
    userId = _is.ColumnString(
      'userId',
      this,
    );
    authId = _is.ColumnString(
      'authId',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
  }

  late final ArchivePresenceUpdateTable updateTable;

  late final _is.ColumnString userId;

  late final _is.ColumnString authId;

  late final _is.ColumnDateTime expiresAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    authId,
    expiresAt,
  ];
}

class ArchivePresenceInclude extends _is.IncludeObject {
  ArchivePresenceInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ArchivePresence.t;
}

class ArchivePresenceIncludeList extends _is.IncludeList {
  ArchivePresenceIncludeList._({
    _is.WhereExpressionBuilder<ArchivePresenceTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ArchivePresence.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ArchivePresence.t;
}

class ArchivePresenceRepository {
  const ArchivePresenceRepository._();

  /// Returns a list of [ArchivePresence]s matching the given query parameters.
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
  Future<List<ArchivePresence>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchivePresenceTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchivePresenceTable>? orderBy,
    _is.OrderByListBuilder<ArchivePresenceTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ArchivePresence>(
      where: where?.call(ArchivePresence.t),
      orderBy: orderBy?.call(ArchivePresence.t),
      orderByList: orderByList?.call(ArchivePresence.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ArchivePresence] matching the given query parameters.
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
  Future<ArchivePresence?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchivePresenceTable>? where,
    int? offset,
    _is.OrderByBuilder<ArchivePresenceTable>? orderBy,
    _is.OrderByListBuilder<ArchivePresenceTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ArchivePresence>(
      where: where?.call(ArchivePresence.t),
      orderBy: orderBy?.call(ArchivePresence.t),
      orderByList: orderByList?.call(ArchivePresence.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ArchivePresence] by its [id] or null if no such row exists.
  Future<ArchivePresence?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ArchivePresence>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ArchivePresence]s in the list and returns the inserted rows.
  ///
  /// The returned [ArchivePresence]s will have their `id` fields set.
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
  Future<List<ArchivePresence>> insert(
    _is.DatabaseSession session,
    List<ArchivePresence> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ArchivePresence>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ArchivePresence] and returns the inserted row.
  ///
  /// The returned [ArchivePresence] will have its `id` field set.
  Future<ArchivePresence> insertRow(
    _is.DatabaseSession session,
    ArchivePresence row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ArchivePresence>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ArchivePresence]s in the list and returns the resulting rows.
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
  /// The returned [ArchivePresence]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchivePresence>> upsert(
    _is.DatabaseSession session,
    List<ArchivePresence> rows, {
    required _is.ColumnSelections<ArchivePresenceTable> conflictColumns,
    _is.ColumnSelections<ArchivePresenceTable>? updateColumns,
    _is.WhereExpressionBuilder<ArchivePresenceTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ArchivePresence>(
      rows,
      conflictColumns: conflictColumns(ArchivePresence.t),
      updateColumns: updateColumns?.call(ArchivePresence.t),
      updateWhere: updateWhere?.call(ArchivePresence.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ArchivePresence] and returns the resulting row.
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
  /// The returned [ArchivePresence] will have its `id` field set.
  Future<ArchivePresence?> upsertRow(
    _is.DatabaseSession session,
    ArchivePresence row, {
    required _is.ColumnSelections<ArchivePresenceTable> conflictColumns,
    _is.ColumnSelections<ArchivePresenceTable>? updateColumns,
    _is.WhereExpressionBuilder<ArchivePresenceTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ArchivePresence>(
      row,
      conflictColumns: conflictColumns(ArchivePresence.t),
      updateColumns: updateColumns?.call(ArchivePresence.t),
      updateWhere: updateWhere?.call(ArchivePresence.t),
      transaction: transaction,
    );
  }

  /// Updates all [ArchivePresence]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchivePresence>> update(
    _is.DatabaseSession session,
    List<ArchivePresence> rows, {
    _is.ColumnSelections<ArchivePresenceTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ArchivePresence>(
      rows,
      columns: columns?.call(ArchivePresence.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ArchivePresence]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ArchivePresence> updateRow(
    _is.DatabaseSession session,
    ArchivePresence row, {
    _is.ColumnSelections<ArchivePresenceTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ArchivePresence>(
      row,
      columns: columns?.call(ArchivePresence.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ArchivePresence] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ArchivePresence?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ArchivePresenceUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ArchivePresence>(
      id,
      columnValues: columnValues(ArchivePresence.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ArchivePresence]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchivePresence>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ArchivePresenceUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<ArchivePresenceTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchivePresenceTable>? orderBy,
    _is.OrderByListBuilder<ArchivePresenceTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ArchivePresence>(
      columnValues: columnValues(ArchivePresence.t.updateTable),
      where: where(ArchivePresence.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ArchivePresence.t),
      orderByList: orderByList?.call(ArchivePresence.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ArchivePresence]s in the list and returns the deleted rows.
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
  Future<List<ArchivePresence>> delete(
    _is.DatabaseSession session,
    List<ArchivePresence> rows, {
    _is.OrderByBuilder<ArchivePresenceTable>? orderBy,
    _is.OrderByListBuilder<ArchivePresenceTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ArchivePresence>(
      rows,
      orderBy: orderBy?.call(ArchivePresence.t),
      orderByList: orderByList?.call(ArchivePresence.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ArchivePresence].
  Future<ArchivePresence> deleteRow(
    _is.DatabaseSession session,
    ArchivePresence row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ArchivePresence>(
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
  Future<List<ArchivePresence>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ArchivePresenceTable> where,
    _is.OrderByBuilder<ArchivePresenceTable>? orderBy,
    _is.OrderByListBuilder<ArchivePresenceTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ArchivePresence>(
      where: where(ArchivePresence.t),
      orderBy: orderBy?.call(ArchivePresence.t),
      orderByList: orderByList?.call(ArchivePresence.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchivePresenceTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ArchivePresence>(
      where: where?.call(ArchivePresence.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ArchivePresence] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ArchivePresenceTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ArchivePresence>(
      where: where(ArchivePresence.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
