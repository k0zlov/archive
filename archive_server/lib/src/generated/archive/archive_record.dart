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

/// A versioned archive card. Values are validated with archive_shared.
abstract class ArchiveRecord
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ArchiveRecord._({
    this.id,
    required this.module,
    required this.identityKey,
    required this.reference,
    required this.proceeding,
    required this.valuesJson,
    int? version,
    required this.createdBy,
    required this.updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.deletedBy,
  }) : version = version ?? 1,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory ArchiveRecord({
    int? id,
    required String module,
    required String identityKey,
    required String reference,
    required String proceeding,
    required String valuesJson,
    int? version,
    required String createdBy,
    required String updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? deletedBy,
  }) = _ArchiveRecordImpl;

  factory ArchiveRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return ArchiveRecord(
      id: jsonSerialization['id'] as int?,
      module: jsonSerialization['module'] as String,
      identityKey: jsonSerialization['identityKey'] as String,
      reference: jsonSerialization['reference'] as String,
      proceeding: jsonSerialization['proceeding'] as String,
      valuesJson: jsonSerialization['valuesJson'] as String,
      version: jsonSerialization['version'] as int?,
      createdBy: jsonSerialization['createdBy'] as String,
      updatedBy: jsonSerialization['updatedBy'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      deletedAt: jsonSerialization['deletedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['deletedAt']),
      deletedBy: jsonSerialization['deletedBy'] as String?,
    );
  }

  static final t = ArchiveRecordTable();

  static const db = ArchiveRecordRepository._();

  @override
  int? id;

  String module;

  String identityKey;

  String reference;

  String proceeding;

  String valuesJson;

  int version;

  String createdBy;

  String updatedBy;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? deletedAt;

  String? deletedBy;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ArchiveRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ArchiveRecord copyWith({
    int? id,
    String? module,
    String? identityKey,
    String? reference,
    String? proceeding,
    String? valuesJson,
    int? version,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? deletedBy,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ArchiveRecord',
      if (id != null) 'id': id,
      'module': module,
      'identityKey': identityKey,
      'reference': reference,
      'proceeding': proceeding,
      'valuesJson': valuesJson,
      'version': version,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      if (deletedBy != null) 'deletedBy': deletedBy,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ArchiveRecordInclude include() {
    return ArchiveRecordInclude._();
  }

  static ArchiveRecordIncludeList includeList({
    _is.WhereExpressionBuilder<ArchiveRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchiveRecordTable>? orderBy,
    _is.OrderByListBuilder<ArchiveRecordTable>? orderByList,
    ArchiveRecordInclude? include,
  }) {
    return ArchiveRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ArchiveRecord.t),
      orderByList: orderByList?.call(ArchiveRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ArchiveRecordImpl extends ArchiveRecord {
  _ArchiveRecordImpl({
    int? id,
    required String module,
    required String identityKey,
    required String reference,
    required String proceeding,
    required String valuesJson,
    int? version,
    required String createdBy,
    required String updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? deletedBy,
  }) : super._(
         id: id,
         module: module,
         identityKey: identityKey,
         reference: reference,
         proceeding: proceeding,
         valuesJson: valuesJson,
         version: version,
         createdBy: createdBy,
         updatedBy: updatedBy,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         deletedBy: deletedBy,
       );

  /// Returns a shallow copy of this [ArchiveRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ArchiveRecord copyWith({
    Object? id = _Undefined,
    String? module,
    String? identityKey,
    String? reference,
    String? proceeding,
    String? valuesJson,
    int? version,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _Undefined,
    Object? deletedBy = _Undefined,
  }) {
    return ArchiveRecord(
      id: id is int? ? id : this.id,
      module: module ?? this.module,
      identityKey: identityKey ?? this.identityKey,
      reference: reference ?? this.reference,
      proceeding: proceeding ?? this.proceeding,
      valuesJson: valuesJson ?? this.valuesJson,
      version: version ?? this.version,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
      deletedBy: deletedBy is String? ? deletedBy : this.deletedBy,
    );
  }
}

class ArchiveRecordUpdateTable extends _is.UpdateTable<ArchiveRecordTable> {
  ArchiveRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> module(String value) => _is.ColumnValue(
    table.module,
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

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
    value,
  );

  _is.ColumnValue<String, String> createdBy(String value) => _is.ColumnValue(
    table.createdBy,
    value,
  );

  _is.ColumnValue<String, String> updatedBy(String value) => _is.ColumnValue(
    table.updatedBy,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> deletedAt(DateTime? value) =>
      _is.ColumnValue(
        table.deletedAt,
        value,
      );

  _is.ColumnValue<String, String> deletedBy(String? value) => _is.ColumnValue(
    table.deletedBy,
    value,
  );
}

class ArchiveRecordTable extends _is.Table<int?> {
  ArchiveRecordTable({super.tableRelation})
    : super(tableName: 'archive_record') {
    updateTable = ArchiveRecordUpdateTable(this);
    module = _is.ColumnString(
      'module',
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
    version = _is.ColumnInt(
      'version',
      this,
      hasDefault: true,
    );
    createdBy = _is.ColumnString(
      'createdBy',
      this,
    );
    updatedBy = _is.ColumnString(
      'updatedBy',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
    deletedAt = _is.ColumnDateTime(
      'deletedAt',
      this,
    );
    deletedBy = _is.ColumnString(
      'deletedBy',
      this,
    );
  }

  late final ArchiveRecordUpdateTable updateTable;

  late final _is.ColumnString module;

  late final _is.ColumnString identityKey;

  late final _is.ColumnString reference;

  late final _is.ColumnString proceeding;

  late final _is.ColumnString valuesJson;

  late final _is.ColumnInt version;

  late final _is.ColumnString createdBy;

  late final _is.ColumnString updatedBy;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  late final _is.ColumnDateTime deletedAt;

  late final _is.ColumnString deletedBy;

  @override
  List<_is.Column> get columns => [
    id,
    module,
    identityKey,
    reference,
    proceeding,
    valuesJson,
    version,
    createdBy,
    updatedBy,
    createdAt,
    updatedAt,
    deletedAt,
    deletedBy,
  ];
}

class ArchiveRecordInclude extends _is.IncludeObject {
  ArchiveRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ArchiveRecord.t;
}

class ArchiveRecordIncludeList extends _is.IncludeList {
  ArchiveRecordIncludeList._({
    _is.WhereExpressionBuilder<ArchiveRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ArchiveRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ArchiveRecord.t;
}

class ArchiveRecordRepository {
  const ArchiveRecordRepository._();

  /// Returns a list of [ArchiveRecord]s matching the given query parameters.
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
  Future<List<ArchiveRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchiveRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchiveRecordTable>? orderBy,
    _is.OrderByListBuilder<ArchiveRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ArchiveRecord>(
      where: where?.call(ArchiveRecord.t),
      orderBy: orderBy?.call(ArchiveRecord.t),
      orderByList: orderByList?.call(ArchiveRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ArchiveRecord] matching the given query parameters.
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
  Future<ArchiveRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchiveRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<ArchiveRecordTable>? orderBy,
    _is.OrderByListBuilder<ArchiveRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ArchiveRecord>(
      where: where?.call(ArchiveRecord.t),
      orderBy: orderBy?.call(ArchiveRecord.t),
      orderByList: orderByList?.call(ArchiveRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ArchiveRecord] by its [id] or null if no such row exists.
  Future<ArchiveRecord?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ArchiveRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ArchiveRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [ArchiveRecord]s will have their `id` fields set.
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
  Future<List<ArchiveRecord>> insert(
    _is.DatabaseSession session,
    List<ArchiveRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ArchiveRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ArchiveRecord] and returns the inserted row.
  ///
  /// The returned [ArchiveRecord] will have its `id` field set.
  Future<ArchiveRecord> insertRow(
    _is.DatabaseSession session,
    ArchiveRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ArchiveRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ArchiveRecord]s in the list and returns the resulting rows.
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
  /// The returned [ArchiveRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveRecord>> upsert(
    _is.DatabaseSession session,
    List<ArchiveRecord> rows, {
    required _is.ColumnSelections<ArchiveRecordTable> conflictColumns,
    _is.ColumnSelections<ArchiveRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<ArchiveRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ArchiveRecord>(
      rows,
      conflictColumns: conflictColumns(ArchiveRecord.t),
      updateColumns: updateColumns?.call(ArchiveRecord.t),
      updateWhere: updateWhere?.call(ArchiveRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ArchiveRecord] and returns the resulting row.
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
  /// The returned [ArchiveRecord] will have its `id` field set.
  Future<ArchiveRecord?> upsertRow(
    _is.DatabaseSession session,
    ArchiveRecord row, {
    required _is.ColumnSelections<ArchiveRecordTable> conflictColumns,
    _is.ColumnSelections<ArchiveRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<ArchiveRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ArchiveRecord>(
      row,
      conflictColumns: conflictColumns(ArchiveRecord.t),
      updateColumns: updateColumns?.call(ArchiveRecord.t),
      updateWhere: updateWhere?.call(ArchiveRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [ArchiveRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveRecord>> update(
    _is.DatabaseSession session,
    List<ArchiveRecord> rows, {
    _is.ColumnSelections<ArchiveRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ArchiveRecord>(
      rows,
      columns: columns?.call(ArchiveRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ArchiveRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ArchiveRecord> updateRow(
    _is.DatabaseSession session,
    ArchiveRecord row, {
    _is.ColumnSelections<ArchiveRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ArchiveRecord>(
      row,
      columns: columns?.call(ArchiveRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ArchiveRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ArchiveRecord?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ArchiveRecordUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ArchiveRecord>(
      id,
      columnValues: columnValues(ArchiveRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ArchiveRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ArchiveRecordUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ArchiveRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchiveRecordTable>? orderBy,
    _is.OrderByListBuilder<ArchiveRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ArchiveRecord>(
      columnValues: columnValues(ArchiveRecord.t.updateTable),
      where: where(ArchiveRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ArchiveRecord.t),
      orderByList: orderByList?.call(ArchiveRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ArchiveRecord]s in the list and returns the deleted rows.
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
  Future<List<ArchiveRecord>> delete(
    _is.DatabaseSession session,
    List<ArchiveRecord> rows, {
    _is.OrderByBuilder<ArchiveRecordTable>? orderBy,
    _is.OrderByListBuilder<ArchiveRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ArchiveRecord>(
      rows,
      orderBy: orderBy?.call(ArchiveRecord.t),
      orderByList: orderByList?.call(ArchiveRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ArchiveRecord].
  Future<ArchiveRecord> deleteRow(
    _is.DatabaseSession session,
    ArchiveRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ArchiveRecord>(
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
  Future<List<ArchiveRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ArchiveRecordTable> where,
    _is.OrderByBuilder<ArchiveRecordTable>? orderBy,
    _is.OrderByListBuilder<ArchiveRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ArchiveRecord>(
      where: where(ArchiveRecord.t),
      orderBy: orderBy?.call(ArchiveRecord.t),
      orderByList: orderByList?.call(ArchiveRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchiveRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ArchiveRecord>(
      where: where?.call(ArchiveRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ArchiveRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ArchiveRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ArchiveRecord>(
      where: where(ArchiveRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
