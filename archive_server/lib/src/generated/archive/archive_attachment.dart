/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:archive_server/src/generated/protocol.dart' as _i4rs4n3o;
import 'package:serverpod/serverpod.dart' as _is;
import '../archive/archive_record.dart' as _iaa4ko9q;

/// Immutable file content becomes visible only after the upload is complete.
abstract class ArchiveAttachment
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ArchiveAttachment._({
    this.id,
    required this.recordId,
    this.record,
    required this.fileName,
    required this.byteLength,
    int? uploadedBytes,
    int? chunkCount,
    String? status,
    required this.createdBy,
    DateTime? createdAt,
    this.deletedAt,
    this.deletedBy,
  }) : uploadedBytes = uploadedBytes ?? 0,
       chunkCount = chunkCount ?? 0,
       status = status ?? 'uploading',
       createdAt = createdAt ?? DateTime.now();

  factory ArchiveAttachment({
    int? id,
    required int recordId,
    _iaa4ko9q.ArchiveRecord? record,
    required String fileName,
    required int byteLength,
    int? uploadedBytes,
    int? chunkCount,
    String? status,
    required String createdBy,
    DateTime? createdAt,
    DateTime? deletedAt,
    String? deletedBy,
  }) = _ArchiveAttachmentImpl;

  factory ArchiveAttachment.fromJson(Map<String, dynamic> jsonSerialization) {
    return ArchiveAttachment(
      id: jsonSerialization['id'] as int?,
      recordId: jsonSerialization['recordId'] as int,
      record: jsonSerialization['record'] == null
          ? null
          : _i4rs4n3o.Protocol().deserialize<_iaa4ko9q.ArchiveRecord>(
              jsonSerialization['record'],
            ),
      fileName: jsonSerialization['fileName'] as String,
      byteLength: jsonSerialization['byteLength'] as int,
      uploadedBytes: jsonSerialization['uploadedBytes'] as int?,
      chunkCount: jsonSerialization['chunkCount'] as int?,
      status: jsonSerialization['status'] as String?,
      createdBy: jsonSerialization['createdBy'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      deletedAt: jsonSerialization['deletedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['deletedAt']),
      deletedBy: jsonSerialization['deletedBy'] as String?,
    );
  }

  static final t = ArchiveAttachmentTable();

  static const db = ArchiveAttachmentRepository._();

  @override
  int? id;

  int recordId;

  _iaa4ko9q.ArchiveRecord? record;

  String fileName;

  int byteLength;

  int uploadedBytes;

  int chunkCount;

  String status;

  String createdBy;

  DateTime createdAt;

  DateTime? deletedAt;

  String? deletedBy;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ArchiveAttachment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ArchiveAttachment copyWith({
    int? id,
    int? recordId,
    _iaa4ko9q.ArchiveRecord? record,
    String? fileName,
    int? byteLength,
    int? uploadedBytes,
    int? chunkCount,
    String? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? deletedAt,
    String? deletedBy,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ArchiveAttachment',
      if (id != null) 'id': id,
      'recordId': recordId,
      if (record != null) 'record': record?.toJson(),
      'fileName': fileName,
      'byteLength': byteLength,
      'uploadedBytes': uploadedBytes,
      'chunkCount': chunkCount,
      'status': status,
      'createdBy': createdBy,
      'createdAt': createdAt.toJson(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      if (deletedBy != null) 'deletedBy': deletedBy,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ArchiveAttachmentInclude include({
    _iaa4ko9q.ArchiveRecordInclude? record,
  }) {
    return ArchiveAttachmentInclude._(record: record);
  }

  static ArchiveAttachmentIncludeList includeList({
    _is.WhereExpressionBuilder<ArchiveAttachmentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchiveAttachmentTable>? orderBy,
    _is.OrderByListBuilder<ArchiveAttachmentTable>? orderByList,
    ArchiveAttachmentInclude? include,
  }) {
    return ArchiveAttachmentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ArchiveAttachment.t),
      orderByList: orderByList?.call(ArchiveAttachment.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ArchiveAttachmentImpl extends ArchiveAttachment {
  _ArchiveAttachmentImpl({
    int? id,
    required int recordId,
    _iaa4ko9q.ArchiveRecord? record,
    required String fileName,
    required int byteLength,
    int? uploadedBytes,
    int? chunkCount,
    String? status,
    required String createdBy,
    DateTime? createdAt,
    DateTime? deletedAt,
    String? deletedBy,
  }) : super._(
         id: id,
         recordId: recordId,
         record: record,
         fileName: fileName,
         byteLength: byteLength,
         uploadedBytes: uploadedBytes,
         chunkCount: chunkCount,
         status: status,
         createdBy: createdBy,
         createdAt: createdAt,
         deletedAt: deletedAt,
         deletedBy: deletedBy,
       );

  /// Returns a shallow copy of this [ArchiveAttachment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ArchiveAttachment copyWith({
    Object? id = _Undefined,
    int? recordId,
    Object? record = _Undefined,
    String? fileName,
    int? byteLength,
    int? uploadedBytes,
    int? chunkCount,
    String? status,
    String? createdBy,
    DateTime? createdAt,
    Object? deletedAt = _Undefined,
    Object? deletedBy = _Undefined,
  }) {
    return ArchiveAttachment(
      id: id is int? ? id : this.id,
      recordId: recordId ?? this.recordId,
      record: record is _iaa4ko9q.ArchiveRecord?
          ? record
          : this.record?.copyWith(),
      fileName: fileName ?? this.fileName,
      byteLength: byteLength ?? this.byteLength,
      uploadedBytes: uploadedBytes ?? this.uploadedBytes,
      chunkCount: chunkCount ?? this.chunkCount,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
      deletedBy: deletedBy is String? ? deletedBy : this.deletedBy,
    );
  }
}

class ArchiveAttachmentUpdateTable
    extends _is.UpdateTable<ArchiveAttachmentTable> {
  ArchiveAttachmentUpdateTable(super.table);

  _is.ColumnValue<int, int> recordId(int value) => _is.ColumnValue(
    table.recordId,
    value,
  );

  _is.ColumnValue<String, String> fileName(String value) => _is.ColumnValue(
    table.fileName,
    value,
  );

  _is.ColumnValue<int, int> byteLength(int value) => _is.ColumnValue(
    table.byteLength,
    value,
  );

  _is.ColumnValue<int, int> uploadedBytes(int value) => _is.ColumnValue(
    table.uploadedBytes,
    value,
  );

  _is.ColumnValue<int, int> chunkCount(int value) => _is.ColumnValue(
    table.chunkCount,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> createdBy(String value) => _is.ColumnValue(
    table.createdBy,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
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

class ArchiveAttachmentTable extends _is.Table<int?> {
  ArchiveAttachmentTable({super.tableRelation})
    : super(tableName: 'archive_attachment') {
    updateTable = ArchiveAttachmentUpdateTable(this);
    recordId = _is.ColumnInt(
      'recordId',
      this,
    );
    fileName = _is.ColumnString(
      'fileName',
      this,
    );
    byteLength = _is.ColumnInt(
      'byteLength',
      this,
    );
    uploadedBytes = _is.ColumnInt(
      'uploadedBytes',
      this,
      hasDefault: true,
    );
    chunkCount = _is.ColumnInt(
      'chunkCount',
      this,
      hasDefault: true,
    );
    status = _is.ColumnString(
      'status',
      this,
      hasDefault: true,
    );
    createdBy = _is.ColumnString(
      'createdBy',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
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

  late final ArchiveAttachmentUpdateTable updateTable;

  late final _is.ColumnInt recordId;

  _iaa4ko9q.ArchiveRecordTable? _record;

  late final _is.ColumnString fileName;

  late final _is.ColumnInt byteLength;

  late final _is.ColumnInt uploadedBytes;

  late final _is.ColumnInt chunkCount;

  late final _is.ColumnString status;

  late final _is.ColumnString createdBy;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime deletedAt;

  late final _is.ColumnString deletedBy;

  _iaa4ko9q.ArchiveRecordTable get record {
    if (_record != null) return _record!;
    _record = _is.createRelationTable(
      relationFieldName: 'record',
      field: ArchiveAttachment.t.recordId,
      foreignField: _iaa4ko9q.ArchiveRecord.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iaa4ko9q.ArchiveRecordTable(tableRelation: foreignTableRelation),
    );
    return _record!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    recordId,
    fileName,
    byteLength,
    uploadedBytes,
    chunkCount,
    status,
    createdBy,
    createdAt,
    deletedAt,
    deletedBy,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'record') {
      return record;
    }
    return null;
  }
}

class ArchiveAttachmentInclude extends _is.IncludeObject {
  ArchiveAttachmentInclude._({_iaa4ko9q.ArchiveRecordInclude? record}) {
    _record = record;
  }

  _iaa4ko9q.ArchiveRecordInclude? _record;

  @override
  Map<String, _is.Include?> get includes => {'record': _record};

  @override
  _is.Table<int?> get table => ArchiveAttachment.t;
}

class ArchiveAttachmentIncludeList extends _is.IncludeList {
  ArchiveAttachmentIncludeList._({
    _is.WhereExpressionBuilder<ArchiveAttachmentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ArchiveAttachment.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ArchiveAttachment.t;
}

class ArchiveAttachmentRepository {
  const ArchiveAttachmentRepository._();

  final attachRow = const ArchiveAttachmentAttachRowRepository._();

  /// Returns a list of [ArchiveAttachment]s matching the given query parameters.
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
  Future<List<ArchiveAttachment>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchiveAttachmentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchiveAttachmentTable>? orderBy,
    _is.OrderByListBuilder<ArchiveAttachmentTable>? orderByList,
    _is.Transaction? transaction,
    ArchiveAttachmentInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ArchiveAttachment>(
      where: where?.call(ArchiveAttachment.t),
      orderBy: orderBy?.call(ArchiveAttachment.t),
      orderByList: orderByList?.call(ArchiveAttachment.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ArchiveAttachment] matching the given query parameters.
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
  Future<ArchiveAttachment?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchiveAttachmentTable>? where,
    int? offset,
    _is.OrderByBuilder<ArchiveAttachmentTable>? orderBy,
    _is.OrderByListBuilder<ArchiveAttachmentTable>? orderByList,
    _is.Transaction? transaction,
    ArchiveAttachmentInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ArchiveAttachment>(
      where: where?.call(ArchiveAttachment.t),
      orderBy: orderBy?.call(ArchiveAttachment.t),
      orderByList: orderByList?.call(ArchiveAttachment.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ArchiveAttachment] by its [id] or null if no such row exists.
  Future<ArchiveAttachment?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    ArchiveAttachmentInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ArchiveAttachment>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ArchiveAttachment]s in the list and returns the inserted rows.
  ///
  /// The returned [ArchiveAttachment]s will have their `id` fields set.
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
  Future<List<ArchiveAttachment>> insert(
    _is.DatabaseSession session,
    List<ArchiveAttachment> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ArchiveAttachment>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ArchiveAttachment] and returns the inserted row.
  ///
  /// The returned [ArchiveAttachment] will have its `id` field set.
  Future<ArchiveAttachment> insertRow(
    _is.DatabaseSession session,
    ArchiveAttachment row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ArchiveAttachment>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ArchiveAttachment]s in the list and returns the resulting rows.
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
  /// The returned [ArchiveAttachment]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveAttachment>> upsert(
    _is.DatabaseSession session,
    List<ArchiveAttachment> rows, {
    required _is.ColumnSelections<ArchiveAttachmentTable> conflictColumns,
    _is.ColumnSelections<ArchiveAttachmentTable>? updateColumns,
    _is.WhereExpressionBuilder<ArchiveAttachmentTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ArchiveAttachment>(
      rows,
      conflictColumns: conflictColumns(ArchiveAttachment.t),
      updateColumns: updateColumns?.call(ArchiveAttachment.t),
      updateWhere: updateWhere?.call(ArchiveAttachment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ArchiveAttachment] and returns the resulting row.
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
  /// The returned [ArchiveAttachment] will have its `id` field set.
  Future<ArchiveAttachment?> upsertRow(
    _is.DatabaseSession session,
    ArchiveAttachment row, {
    required _is.ColumnSelections<ArchiveAttachmentTable> conflictColumns,
    _is.ColumnSelections<ArchiveAttachmentTable>? updateColumns,
    _is.WhereExpressionBuilder<ArchiveAttachmentTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ArchiveAttachment>(
      row,
      conflictColumns: conflictColumns(ArchiveAttachment.t),
      updateColumns: updateColumns?.call(ArchiveAttachment.t),
      updateWhere: updateWhere?.call(ArchiveAttachment.t),
      transaction: transaction,
    );
  }

  /// Updates all [ArchiveAttachment]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveAttachment>> update(
    _is.DatabaseSession session,
    List<ArchiveAttachment> rows, {
    _is.ColumnSelections<ArchiveAttachmentTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ArchiveAttachment>(
      rows,
      columns: columns?.call(ArchiveAttachment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ArchiveAttachment]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ArchiveAttachment> updateRow(
    _is.DatabaseSession session,
    ArchiveAttachment row, {
    _is.ColumnSelections<ArchiveAttachmentTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ArchiveAttachment>(
      row,
      columns: columns?.call(ArchiveAttachment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ArchiveAttachment] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ArchiveAttachment?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ArchiveAttachmentUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ArchiveAttachment>(
      id,
      columnValues: columnValues(ArchiveAttachment.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ArchiveAttachment]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveAttachment>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ArchiveAttachmentUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<ArchiveAttachmentTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchiveAttachmentTable>? orderBy,
    _is.OrderByListBuilder<ArchiveAttachmentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ArchiveAttachment>(
      columnValues: columnValues(ArchiveAttachment.t.updateTable),
      where: where(ArchiveAttachment.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ArchiveAttachment.t),
      orderByList: orderByList?.call(ArchiveAttachment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ArchiveAttachment]s in the list and returns the deleted rows.
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
  Future<List<ArchiveAttachment>> delete(
    _is.DatabaseSession session,
    List<ArchiveAttachment> rows, {
    _is.OrderByBuilder<ArchiveAttachmentTable>? orderBy,
    _is.OrderByListBuilder<ArchiveAttachmentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ArchiveAttachment>(
      rows,
      orderBy: orderBy?.call(ArchiveAttachment.t),
      orderByList: orderByList?.call(ArchiveAttachment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ArchiveAttachment].
  Future<ArchiveAttachment> deleteRow(
    _is.DatabaseSession session,
    ArchiveAttachment row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ArchiveAttachment>(
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
  Future<List<ArchiveAttachment>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ArchiveAttachmentTable> where,
    _is.OrderByBuilder<ArchiveAttachmentTable>? orderBy,
    _is.OrderByListBuilder<ArchiveAttachmentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ArchiveAttachment>(
      where: where(ArchiveAttachment.t),
      orderBy: orderBy?.call(ArchiveAttachment.t),
      orderByList: orderByList?.call(ArchiveAttachment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchiveAttachmentTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ArchiveAttachment>(
      where: where?.call(ArchiveAttachment.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ArchiveAttachment] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ArchiveAttachmentTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ArchiveAttachment>(
      where: where(ArchiveAttachment.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class ArchiveAttachmentAttachRowRepository {
  const ArchiveAttachmentAttachRowRepository._();

  /// Creates a relation between the given [ArchiveAttachment] and [ArchiveRecord]
  /// by setting the [ArchiveAttachment]'s foreign key `recordId` to refer to the [ArchiveRecord].
  Future<void> record(
    _is.DatabaseSession session,
    ArchiveAttachment archiveAttachment,
    _iaa4ko9q.ArchiveRecord record, {
    _is.Transaction? transaction,
  }) async {
    if (archiveAttachment.id == null) {
      throw ArgumentError.notNull('archiveAttachment.id');
    }
    if (record.id == null) {
      throw ArgumentError.notNull('record.id');
    }

    var $archiveAttachment = archiveAttachment.copyWith(recordId: record.id);
    await session.db.updateRow<ArchiveAttachment>(
      $archiveAttachment,
      columns: [ArchiveAttachment.t.recordId],
      transaction: transaction,
    );
  }
}
