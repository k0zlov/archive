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
import 'dart:typed_data' as _idt;
import 'package:serverpod/serverpod.dart' as _is;

/// A nomenclature document stored in the server database.
abstract class ArchiveDocument
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ArchiveDocument._({
    this.id,
    required this.title,
    required this.fileName,
    required this.kind,
    required this.year,
    required this.content,
    required this.createdBy,
    DateTime? createdAt,
    this.deletedAt,
    this.deletedBy,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ArchiveDocument({
    int? id,
    required String title,
    required String fileName,
    required String kind,
    required int year,
    required _idt.ByteData content,
    required String createdBy,
    DateTime? createdAt,
    DateTime? deletedAt,
    String? deletedBy,
  }) = _ArchiveDocumentImpl;

  factory ArchiveDocument.fromJson(Map<String, dynamic> jsonSerialization) {
    return ArchiveDocument(
      id: jsonSerialization['id'] as int?,
      title: jsonSerialization['title'] as String,
      fileName: jsonSerialization['fileName'] as String,
      kind: jsonSerialization['kind'] as String,
      year: jsonSerialization['year'] as int,
      content: _is.ByteDataJsonExtension.fromJson(jsonSerialization['content']),
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

  static final t = ArchiveDocumentTable();

  static const db = ArchiveDocumentRepository._();

  @override
  int? id;

  String title;

  String fileName;

  String kind;

  int year;

  _idt.ByteData content;

  String createdBy;

  DateTime createdAt;

  DateTime? deletedAt;

  String? deletedBy;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ArchiveDocument]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ArchiveDocument copyWith({
    int? id,
    String? title,
    String? fileName,
    String? kind,
    int? year,
    _idt.ByteData? content,
    String? createdBy,
    DateTime? createdAt,
    DateTime? deletedAt,
    String? deletedBy,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ArchiveDocument',
      if (id != null) 'id': id,
      'title': title,
      'fileName': fileName,
      'kind': kind,
      'year': year,
      'content': content.toJson(),
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

  static ArchiveDocumentInclude include() {
    return ArchiveDocumentInclude._();
  }

  static ArchiveDocumentIncludeList includeList({
    _is.WhereExpressionBuilder<ArchiveDocumentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchiveDocumentTable>? orderBy,
    _is.OrderByListBuilder<ArchiveDocumentTable>? orderByList,
    ArchiveDocumentInclude? include,
  }) {
    return ArchiveDocumentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ArchiveDocument.t),
      orderByList: orderByList?.call(ArchiveDocument.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ArchiveDocumentImpl extends ArchiveDocument {
  _ArchiveDocumentImpl({
    int? id,
    required String title,
    required String fileName,
    required String kind,
    required int year,
    required _idt.ByteData content,
    required String createdBy,
    DateTime? createdAt,
    DateTime? deletedAt,
    String? deletedBy,
  }) : super._(
         id: id,
         title: title,
         fileName: fileName,
         kind: kind,
         year: year,
         content: content,
         createdBy: createdBy,
         createdAt: createdAt,
         deletedAt: deletedAt,
         deletedBy: deletedBy,
       );

  /// Returns a shallow copy of this [ArchiveDocument]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ArchiveDocument copyWith({
    Object? id = _Undefined,
    String? title,
    String? fileName,
    String? kind,
    int? year,
    _idt.ByteData? content,
    String? createdBy,
    DateTime? createdAt,
    Object? deletedAt = _Undefined,
    Object? deletedBy = _Undefined,
  }) {
    return ArchiveDocument(
      id: id is int? ? id : this.id,
      title: title ?? this.title,
      fileName: fileName ?? this.fileName,
      kind: kind ?? this.kind,
      year: year ?? this.year,
      content: content ?? this.content.clone(),
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
      deletedBy: deletedBy is String? ? deletedBy : this.deletedBy,
    );
  }
}

class ArchiveDocumentUpdateTable extends _is.UpdateTable<ArchiveDocumentTable> {
  ArchiveDocumentUpdateTable(super.table);

  _is.ColumnValue<String, String> title(String value) => _is.ColumnValue(
    table.title,
    value,
  );

  _is.ColumnValue<String, String> fileName(String value) => _is.ColumnValue(
    table.fileName,
    value,
  );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<int, int> year(int value) => _is.ColumnValue(
    table.year,
    value,
  );

  _is.ColumnValue<_idt.ByteData, _idt.ByteData> content(_idt.ByteData value) =>
      _is.ColumnValue(
        table.content,
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

class ArchiveDocumentTable extends _is.Table<int?> {
  ArchiveDocumentTable({super.tableRelation})
    : super(tableName: 'archive_document') {
    updateTable = ArchiveDocumentUpdateTable(this);
    title = _is.ColumnString(
      'title',
      this,
    );
    fileName = _is.ColumnString(
      'fileName',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    year = _is.ColumnInt(
      'year',
      this,
    );
    content = _is.ColumnByteData(
      'content',
      this,
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

  late final ArchiveDocumentUpdateTable updateTable;

  late final _is.ColumnString title;

  late final _is.ColumnString fileName;

  late final _is.ColumnString kind;

  late final _is.ColumnInt year;

  late final _is.ColumnByteData content;

  late final _is.ColumnString createdBy;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime deletedAt;

  late final _is.ColumnString deletedBy;

  @override
  List<_is.Column> get columns => [
    id,
    title,
    fileName,
    kind,
    year,
    content,
    createdBy,
    createdAt,
    deletedAt,
    deletedBy,
  ];
}

class ArchiveDocumentInclude extends _is.IncludeObject {
  ArchiveDocumentInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ArchiveDocument.t;
}

class ArchiveDocumentIncludeList extends _is.IncludeList {
  ArchiveDocumentIncludeList._({
    _is.WhereExpressionBuilder<ArchiveDocumentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ArchiveDocument.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ArchiveDocument.t;
}

class ArchiveDocumentRepository {
  const ArchiveDocumentRepository._();

  /// Returns a list of [ArchiveDocument]s matching the given query parameters.
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
  Future<List<ArchiveDocument>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchiveDocumentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchiveDocumentTable>? orderBy,
    _is.OrderByListBuilder<ArchiveDocumentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ArchiveDocument>(
      where: where?.call(ArchiveDocument.t),
      orderBy: orderBy?.call(ArchiveDocument.t),
      orderByList: orderByList?.call(ArchiveDocument.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ArchiveDocument] matching the given query parameters.
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
  Future<ArchiveDocument?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchiveDocumentTable>? where,
    int? offset,
    _is.OrderByBuilder<ArchiveDocumentTable>? orderBy,
    _is.OrderByListBuilder<ArchiveDocumentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ArchiveDocument>(
      where: where?.call(ArchiveDocument.t),
      orderBy: orderBy?.call(ArchiveDocument.t),
      orderByList: orderByList?.call(ArchiveDocument.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ArchiveDocument] by its [id] or null if no such row exists.
  Future<ArchiveDocument?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ArchiveDocument>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ArchiveDocument]s in the list and returns the inserted rows.
  ///
  /// The returned [ArchiveDocument]s will have their `id` fields set.
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
  Future<List<ArchiveDocument>> insert(
    _is.DatabaseSession session,
    List<ArchiveDocument> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ArchiveDocument>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ArchiveDocument] and returns the inserted row.
  ///
  /// The returned [ArchiveDocument] will have its `id` field set.
  Future<ArchiveDocument> insertRow(
    _is.DatabaseSession session,
    ArchiveDocument row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ArchiveDocument>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ArchiveDocument]s in the list and returns the resulting rows.
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
  /// The returned [ArchiveDocument]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveDocument>> upsert(
    _is.DatabaseSession session,
    List<ArchiveDocument> rows, {
    required _is.ColumnSelections<ArchiveDocumentTable> conflictColumns,
    _is.ColumnSelections<ArchiveDocumentTable>? updateColumns,
    _is.WhereExpressionBuilder<ArchiveDocumentTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ArchiveDocument>(
      rows,
      conflictColumns: conflictColumns(ArchiveDocument.t),
      updateColumns: updateColumns?.call(ArchiveDocument.t),
      updateWhere: updateWhere?.call(ArchiveDocument.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ArchiveDocument] and returns the resulting row.
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
  /// The returned [ArchiveDocument] will have its `id` field set.
  Future<ArchiveDocument?> upsertRow(
    _is.DatabaseSession session,
    ArchiveDocument row, {
    required _is.ColumnSelections<ArchiveDocumentTable> conflictColumns,
    _is.ColumnSelections<ArchiveDocumentTable>? updateColumns,
    _is.WhereExpressionBuilder<ArchiveDocumentTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ArchiveDocument>(
      row,
      conflictColumns: conflictColumns(ArchiveDocument.t),
      updateColumns: updateColumns?.call(ArchiveDocument.t),
      updateWhere: updateWhere?.call(ArchiveDocument.t),
      transaction: transaction,
    );
  }

  /// Updates all [ArchiveDocument]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveDocument>> update(
    _is.DatabaseSession session,
    List<ArchiveDocument> rows, {
    _is.ColumnSelections<ArchiveDocumentTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ArchiveDocument>(
      rows,
      columns: columns?.call(ArchiveDocument.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ArchiveDocument]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ArchiveDocument> updateRow(
    _is.DatabaseSession session,
    ArchiveDocument row, {
    _is.ColumnSelections<ArchiveDocumentTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ArchiveDocument>(
      row,
      columns: columns?.call(ArchiveDocument.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ArchiveDocument] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ArchiveDocument?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ArchiveDocumentUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ArchiveDocument>(
      id,
      columnValues: columnValues(ArchiveDocument.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ArchiveDocument]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveDocument>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ArchiveDocumentUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<ArchiveDocumentTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchiveDocumentTable>? orderBy,
    _is.OrderByListBuilder<ArchiveDocumentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ArchiveDocument>(
      columnValues: columnValues(ArchiveDocument.t.updateTable),
      where: where(ArchiveDocument.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ArchiveDocument.t),
      orderByList: orderByList?.call(ArchiveDocument.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ArchiveDocument]s in the list and returns the deleted rows.
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
  Future<List<ArchiveDocument>> delete(
    _is.DatabaseSession session,
    List<ArchiveDocument> rows, {
    _is.OrderByBuilder<ArchiveDocumentTable>? orderBy,
    _is.OrderByListBuilder<ArchiveDocumentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ArchiveDocument>(
      rows,
      orderBy: orderBy?.call(ArchiveDocument.t),
      orderByList: orderByList?.call(ArchiveDocument.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ArchiveDocument].
  Future<ArchiveDocument> deleteRow(
    _is.DatabaseSession session,
    ArchiveDocument row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ArchiveDocument>(
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
  Future<List<ArchiveDocument>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ArchiveDocumentTable> where,
    _is.OrderByBuilder<ArchiveDocumentTable>? orderBy,
    _is.OrderByListBuilder<ArchiveDocumentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ArchiveDocument>(
      where: where(ArchiveDocument.t),
      orderBy: orderBy?.call(ArchiveDocument.t),
      orderByList: orderByList?.call(ArchiveDocument.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchiveDocumentTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ArchiveDocument>(
      where: where?.call(ArchiveDocument.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ArchiveDocument] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ArchiveDocumentTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ArchiveDocument>(
      where: where(ArchiveDocument.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
