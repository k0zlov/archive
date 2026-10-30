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
import 'dart:typed_data' as _idt;
import 'package:archive_server/src/generated/protocol.dart' as _i4rs4n3o;
import 'package:serverpod/serverpod.dart' as _is;
import '../archive/archive_attachment.dart' as _il56b4jc;

/// Bounded file parts allow large uploads without a single large RPC payload.
abstract class ArchiveAttachmentChunk
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ArchiveAttachmentChunk._({
    this.id,
    required this.attachmentId,
    this.attachment,
    required this.chunkIndex,
    required this.content,
  });

  factory ArchiveAttachmentChunk({
    int? id,
    required int attachmentId,
    _il56b4jc.ArchiveAttachment? attachment,
    required int chunkIndex,
    required _idt.ByteData content,
  }) = _ArchiveAttachmentChunkImpl;

  factory ArchiveAttachmentChunk.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ArchiveAttachmentChunk(
      id: jsonSerialization['id'] as int?,
      attachmentId: jsonSerialization['attachmentId'] as int,
      attachment: jsonSerialization['attachment'] == null
          ? null
          : _i4rs4n3o.Protocol().deserialize<_il56b4jc.ArchiveAttachment>(
              jsonSerialization['attachment'],
            ),
      chunkIndex: jsonSerialization['chunkIndex'] as int,
      content: _is.ByteDataJsonExtension.fromJson(jsonSerialization['content']),
    );
  }

  static final t = ArchiveAttachmentChunkTable();

  static const db = ArchiveAttachmentChunkRepository._();

  @override
  int? id;

  int attachmentId;

  _il56b4jc.ArchiveAttachment? attachment;

  int chunkIndex;

  _idt.ByteData content;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ArchiveAttachmentChunk]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ArchiveAttachmentChunk copyWith({
    int? id,
    int? attachmentId,
    _il56b4jc.ArchiveAttachment? attachment,
    int? chunkIndex,
    _idt.ByteData? content,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ArchiveAttachmentChunk',
      if (id != null) 'id': id,
      'attachmentId': attachmentId,
      if (attachment != null) 'attachment': attachment?.toJson(),
      'chunkIndex': chunkIndex,
      'content': content.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ArchiveAttachmentChunkInclude include({
    _il56b4jc.ArchiveAttachmentInclude? attachment,
  }) {
    return ArchiveAttachmentChunkInclude._(attachment: attachment);
  }

  static ArchiveAttachmentChunkIncludeList includeList({
    _is.WhereExpressionBuilder<ArchiveAttachmentChunkTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchiveAttachmentChunkTable>? orderBy,
    _is.OrderByListBuilder<ArchiveAttachmentChunkTable>? orderByList,
    ArchiveAttachmentChunkInclude? include,
  }) {
    return ArchiveAttachmentChunkIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ArchiveAttachmentChunk.t),
      orderByList: orderByList?.call(ArchiveAttachmentChunk.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ArchiveAttachmentChunkImpl extends ArchiveAttachmentChunk {
  _ArchiveAttachmentChunkImpl({
    int? id,
    required int attachmentId,
    _il56b4jc.ArchiveAttachment? attachment,
    required int chunkIndex,
    required _idt.ByteData content,
  }) : super._(
         id: id,
         attachmentId: attachmentId,
         attachment: attachment,
         chunkIndex: chunkIndex,
         content: content,
       );

  /// Returns a shallow copy of this [ArchiveAttachmentChunk]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ArchiveAttachmentChunk copyWith({
    Object? id = _Undefined,
    int? attachmentId,
    Object? attachment = _Undefined,
    int? chunkIndex,
    _idt.ByteData? content,
  }) {
    return ArchiveAttachmentChunk(
      id: id is int? ? id : this.id,
      attachmentId: attachmentId ?? this.attachmentId,
      attachment: attachment is _il56b4jc.ArchiveAttachment?
          ? attachment
          : this.attachment?.copyWith(),
      chunkIndex: chunkIndex ?? this.chunkIndex,
      content: content ?? this.content.clone(),
    );
  }
}

class ArchiveAttachmentChunkUpdateTable
    extends _is.UpdateTable<ArchiveAttachmentChunkTable> {
  ArchiveAttachmentChunkUpdateTable(super.table);

  _is.ColumnValue<int, int> attachmentId(int value) => _is.ColumnValue(
    table.attachmentId,
    value,
  );

  _is.ColumnValue<int, int> chunkIndex(int value) => _is.ColumnValue(
    table.chunkIndex,
    value,
  );

  _is.ColumnValue<_idt.ByteData, _idt.ByteData> content(_idt.ByteData value) =>
      _is.ColumnValue(
        table.content,
        value,
      );
}

class ArchiveAttachmentChunkTable extends _is.Table<int?> {
  ArchiveAttachmentChunkTable({super.tableRelation})
    : super(tableName: 'archive_attachment_chunk') {
    updateTable = ArchiveAttachmentChunkUpdateTable(this);
    attachmentId = _is.ColumnInt(
      'attachmentId',
      this,
    );
    chunkIndex = _is.ColumnInt(
      'chunkIndex',
      this,
    );
    content = _is.ColumnByteData(
      'content',
      this,
    );
  }

  late final ArchiveAttachmentChunkUpdateTable updateTable;

  late final _is.ColumnInt attachmentId;

  _il56b4jc.ArchiveAttachmentTable? _attachment;

  late final _is.ColumnInt chunkIndex;

  late final _is.ColumnByteData content;

  _il56b4jc.ArchiveAttachmentTable get attachment {
    if (_attachment != null) return _attachment!;
    _attachment = _is.createRelationTable(
      relationFieldName: 'attachment',
      field: ArchiveAttachmentChunk.t.attachmentId,
      foreignField: _il56b4jc.ArchiveAttachment.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _il56b4jc.ArchiveAttachmentTable(tableRelation: foreignTableRelation),
    );
    return _attachment!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    attachmentId,
    chunkIndex,
    content,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'attachment') {
      return attachment;
    }
    return null;
  }
}

class ArchiveAttachmentChunkInclude extends _is.IncludeObject {
  ArchiveAttachmentChunkInclude._({
    _il56b4jc.ArchiveAttachmentInclude? attachment,
  }) {
    _attachment = attachment;
  }

  _il56b4jc.ArchiveAttachmentInclude? _attachment;

  @override
  Map<String, _is.Include?> get includes => {'attachment': _attachment};

  @override
  _is.Table<int?> get table => ArchiveAttachmentChunk.t;
}

class ArchiveAttachmentChunkIncludeList extends _is.IncludeList {
  ArchiveAttachmentChunkIncludeList._({
    _is.WhereExpressionBuilder<ArchiveAttachmentChunkTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ArchiveAttachmentChunk.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ArchiveAttachmentChunk.t;
}

class ArchiveAttachmentChunkRepository {
  const ArchiveAttachmentChunkRepository._();

  final attachRow = const ArchiveAttachmentChunkAttachRowRepository._();

  /// Returns a list of [ArchiveAttachmentChunk]s matching the given query parameters.
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
  Future<List<ArchiveAttachmentChunk>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchiveAttachmentChunkTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchiveAttachmentChunkTable>? orderBy,
    _is.OrderByListBuilder<ArchiveAttachmentChunkTable>? orderByList,
    _is.Transaction? transaction,
    ArchiveAttachmentChunkInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ArchiveAttachmentChunk>(
      where: where?.call(ArchiveAttachmentChunk.t),
      orderBy: orderBy?.call(ArchiveAttachmentChunk.t),
      orderByList: orderByList?.call(ArchiveAttachmentChunk.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ArchiveAttachmentChunk] matching the given query parameters.
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
  Future<ArchiveAttachmentChunk?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchiveAttachmentChunkTable>? where,
    int? offset,
    _is.OrderByBuilder<ArchiveAttachmentChunkTable>? orderBy,
    _is.OrderByListBuilder<ArchiveAttachmentChunkTable>? orderByList,
    _is.Transaction? transaction,
    ArchiveAttachmentChunkInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ArchiveAttachmentChunk>(
      where: where?.call(ArchiveAttachmentChunk.t),
      orderBy: orderBy?.call(ArchiveAttachmentChunk.t),
      orderByList: orderByList?.call(ArchiveAttachmentChunk.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ArchiveAttachmentChunk] by its [id] or null if no such row exists.
  Future<ArchiveAttachmentChunk?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    ArchiveAttachmentChunkInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ArchiveAttachmentChunk>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ArchiveAttachmentChunk]s in the list and returns the inserted rows.
  ///
  /// The returned [ArchiveAttachmentChunk]s will have their `id` fields set.
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
  Future<List<ArchiveAttachmentChunk>> insert(
    _is.DatabaseSession session,
    List<ArchiveAttachmentChunk> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ArchiveAttachmentChunk>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ArchiveAttachmentChunk] and returns the inserted row.
  ///
  /// The returned [ArchiveAttachmentChunk] will have its `id` field set.
  Future<ArchiveAttachmentChunk> insertRow(
    _is.DatabaseSession session,
    ArchiveAttachmentChunk row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ArchiveAttachmentChunk>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ArchiveAttachmentChunk]s in the list and returns the resulting rows.
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
  /// The returned [ArchiveAttachmentChunk]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveAttachmentChunk>> upsert(
    _is.DatabaseSession session,
    List<ArchiveAttachmentChunk> rows, {
    required _is.ColumnSelections<ArchiveAttachmentChunkTable> conflictColumns,
    _is.ColumnSelections<ArchiveAttachmentChunkTable>? updateColumns,
    _is.WhereExpressionBuilder<ArchiveAttachmentChunkTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ArchiveAttachmentChunk>(
      rows,
      conflictColumns: conflictColumns(ArchiveAttachmentChunk.t),
      updateColumns: updateColumns?.call(ArchiveAttachmentChunk.t),
      updateWhere: updateWhere?.call(ArchiveAttachmentChunk.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ArchiveAttachmentChunk] and returns the resulting row.
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
  /// The returned [ArchiveAttachmentChunk] will have its `id` field set.
  Future<ArchiveAttachmentChunk?> upsertRow(
    _is.DatabaseSession session,
    ArchiveAttachmentChunk row, {
    required _is.ColumnSelections<ArchiveAttachmentChunkTable> conflictColumns,
    _is.ColumnSelections<ArchiveAttachmentChunkTable>? updateColumns,
    _is.WhereExpressionBuilder<ArchiveAttachmentChunkTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ArchiveAttachmentChunk>(
      row,
      conflictColumns: conflictColumns(ArchiveAttachmentChunk.t),
      updateColumns: updateColumns?.call(ArchiveAttachmentChunk.t),
      updateWhere: updateWhere?.call(ArchiveAttachmentChunk.t),
      transaction: transaction,
    );
  }

  /// Updates all [ArchiveAttachmentChunk]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveAttachmentChunk>> update(
    _is.DatabaseSession session,
    List<ArchiveAttachmentChunk> rows, {
    _is.ColumnSelections<ArchiveAttachmentChunkTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ArchiveAttachmentChunk>(
      rows,
      columns: columns?.call(ArchiveAttachmentChunk.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ArchiveAttachmentChunk]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ArchiveAttachmentChunk> updateRow(
    _is.DatabaseSession session,
    ArchiveAttachmentChunk row, {
    _is.ColumnSelections<ArchiveAttachmentChunkTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ArchiveAttachmentChunk>(
      row,
      columns: columns?.call(ArchiveAttachmentChunk.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ArchiveAttachmentChunk] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ArchiveAttachmentChunk?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ArchiveAttachmentChunkUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ArchiveAttachmentChunk>(
      id,
      columnValues: columnValues(ArchiveAttachmentChunk.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ArchiveAttachmentChunk]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveAttachmentChunk>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ArchiveAttachmentChunkUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<ArchiveAttachmentChunkTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchiveAttachmentChunkTable>? orderBy,
    _is.OrderByListBuilder<ArchiveAttachmentChunkTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ArchiveAttachmentChunk>(
      columnValues: columnValues(ArchiveAttachmentChunk.t.updateTable),
      where: where(ArchiveAttachmentChunk.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ArchiveAttachmentChunk.t),
      orderByList: orderByList?.call(ArchiveAttachmentChunk.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ArchiveAttachmentChunk]s in the list and returns the deleted rows.
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
  Future<List<ArchiveAttachmentChunk>> delete(
    _is.DatabaseSession session,
    List<ArchiveAttachmentChunk> rows, {
    _is.OrderByBuilder<ArchiveAttachmentChunkTable>? orderBy,
    _is.OrderByListBuilder<ArchiveAttachmentChunkTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ArchiveAttachmentChunk>(
      rows,
      orderBy: orderBy?.call(ArchiveAttachmentChunk.t),
      orderByList: orderByList?.call(ArchiveAttachmentChunk.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ArchiveAttachmentChunk].
  Future<ArchiveAttachmentChunk> deleteRow(
    _is.DatabaseSession session,
    ArchiveAttachmentChunk row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ArchiveAttachmentChunk>(
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
  Future<List<ArchiveAttachmentChunk>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ArchiveAttachmentChunkTable> where,
    _is.OrderByBuilder<ArchiveAttachmentChunkTable>? orderBy,
    _is.OrderByListBuilder<ArchiveAttachmentChunkTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ArchiveAttachmentChunk>(
      where: where(ArchiveAttachmentChunk.t),
      orderBy: orderBy?.call(ArchiveAttachmentChunk.t),
      orderByList: orderByList?.call(ArchiveAttachmentChunk.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchiveAttachmentChunkTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ArchiveAttachmentChunk>(
      where: where?.call(ArchiveAttachmentChunk.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ArchiveAttachmentChunk] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ArchiveAttachmentChunkTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ArchiveAttachmentChunk>(
      where: where(ArchiveAttachmentChunk.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class ArchiveAttachmentChunkAttachRowRepository {
  const ArchiveAttachmentChunkAttachRowRepository._();

  /// Creates a relation between the given [ArchiveAttachmentChunk] and [ArchiveAttachment]
  /// by setting the [ArchiveAttachmentChunk]'s foreign key `attachmentId` to refer to the [ArchiveAttachment].
  Future<void> attachment(
    _is.DatabaseSession session,
    ArchiveAttachmentChunk archiveAttachmentChunk,
    _il56b4jc.ArchiveAttachment attachment, {
    _is.Transaction? transaction,
  }) async {
    if (archiveAttachmentChunk.id == null) {
      throw ArgumentError.notNull('archiveAttachmentChunk.id');
    }
    if (attachment.id == null) {
      throw ArgumentError.notNull('attachment.id');
    }

    var $archiveAttachmentChunk = archiveAttachmentChunk.copyWith(
      attachmentId: attachment.id,
    );
    await session.db.updateRow<ArchiveAttachmentChunk>(
      $archiveAttachmentChunk,
      columns: [ArchiveAttachmentChunk.t.attachmentId],
      transaction: transaction,
    );
  }
}
