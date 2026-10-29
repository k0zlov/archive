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

/// Per-account authorization, evaluated on every archive request.
abstract class ArchiveMember
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ArchiveMember._({
    this.id,
    required this.userId,
    required this.email,
    this.login,
    bool? passwordChangeRequired,
    required this.displayName,
    String? role,
    bool? managementAccess,
    bool? courtAccess,
    DateTime? createdAt,
  }) : passwordChangeRequired = passwordChangeRequired ?? false,
       role = role ?? 'pending',
       managementAccess = managementAccess ?? false,
       courtAccess = courtAccess ?? false,
       createdAt = createdAt ?? DateTime.now();

  factory ArchiveMember({
    int? id,
    required String userId,
    required String email,
    String? login,
    bool? passwordChangeRequired,
    required String displayName,
    String? role,
    bool? managementAccess,
    bool? courtAccess,
    DateTime? createdAt,
  }) = _ArchiveMemberImpl;

  factory ArchiveMember.fromJson(Map<String, dynamic> jsonSerialization) {
    return ArchiveMember(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      email: jsonSerialization['email'] as String,
      login: jsonSerialization['login'] as String?,
      passwordChangeRequired:
          jsonSerialization['passwordChangeRequired'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['passwordChangeRequired'],
            ),
      displayName: jsonSerialization['displayName'] as String,
      role: jsonSerialization['role'] as String?,
      managementAccess: jsonSerialization['managementAccess'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['managementAccess'],
            ),
      courtAccess: jsonSerialization['courtAccess'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['courtAccess']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = ArchiveMemberTable();

  static const db = ArchiveMemberRepository._();

  @override
  int? id;

  String userId;

  String email;

  String? login;

  bool passwordChangeRequired;

  String displayName;

  String role;

  bool managementAccess;

  bool courtAccess;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ArchiveMember]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ArchiveMember copyWith({
    int? id,
    String? userId,
    String? email,
    String? login,
    bool? passwordChangeRequired,
    String? displayName,
    String? role,
    bool? managementAccess,
    bool? courtAccess,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ArchiveMember',
      if (id != null) 'id': id,
      'userId': userId,
      'email': email,
      if (login != null) 'login': login,
      'passwordChangeRequired': passwordChangeRequired,
      'displayName': displayName,
      'role': role,
      'managementAccess': managementAccess,
      'courtAccess': courtAccess,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ArchiveMemberInclude include() {
    return ArchiveMemberInclude._();
  }

  static ArchiveMemberIncludeList includeList({
    _is.WhereExpressionBuilder<ArchiveMemberTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchiveMemberTable>? orderBy,
    _is.OrderByListBuilder<ArchiveMemberTable>? orderByList,
    ArchiveMemberInclude? include,
  }) {
    return ArchiveMemberIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ArchiveMember.t),
      orderByList: orderByList?.call(ArchiveMember.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ArchiveMemberImpl extends ArchiveMember {
  _ArchiveMemberImpl({
    int? id,
    required String userId,
    required String email,
    String? login,
    bool? passwordChangeRequired,
    required String displayName,
    String? role,
    bool? managementAccess,
    bool? courtAccess,
    DateTime? createdAt,
  }) : super._(
         id: id,
         userId: userId,
         email: email,
         login: login,
         passwordChangeRequired: passwordChangeRequired,
         displayName: displayName,
         role: role,
         managementAccess: managementAccess,
         courtAccess: courtAccess,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ArchiveMember]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ArchiveMember copyWith({
    Object? id = _Undefined,
    String? userId,
    String? email,
    Object? login = _Undefined,
    bool? passwordChangeRequired,
    String? displayName,
    String? role,
    bool? managementAccess,
    bool? courtAccess,
    DateTime? createdAt,
  }) {
    return ArchiveMember(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      login: login is String? ? login : this.login,
      passwordChangeRequired:
          passwordChangeRequired ?? this.passwordChangeRequired,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      managementAccess: managementAccess ?? this.managementAccess,
      courtAccess: courtAccess ?? this.courtAccess,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ArchiveMemberUpdateTable extends _is.UpdateTable<ArchiveMemberTable> {
  ArchiveMemberUpdateTable(super.table);

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> email(String value) => _is.ColumnValue(
    table.email,
    value,
  );

  _is.ColumnValue<String, String> login(String? value) => _is.ColumnValue(
    table.login,
    value,
  );

  _is.ColumnValue<bool, bool> passwordChangeRequired(bool value) =>
      _is.ColumnValue(
        table.passwordChangeRequired,
        value,
      );

  _is.ColumnValue<String, String> displayName(String value) => _is.ColumnValue(
    table.displayName,
    value,
  );

  _is.ColumnValue<String, String> role(String value) => _is.ColumnValue(
    table.role,
    value,
  );

  _is.ColumnValue<bool, bool> managementAccess(bool value) => _is.ColumnValue(
    table.managementAccess,
    value,
  );

  _is.ColumnValue<bool, bool> courtAccess(bool value) => _is.ColumnValue(
    table.courtAccess,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class ArchiveMemberTable extends _is.Table<int?> {
  ArchiveMemberTable({super.tableRelation})
    : super(tableName: 'archive_member') {
    updateTable = ArchiveMemberUpdateTable(this);
    userId = _is.ColumnString(
      'userId',
      this,
    );
    email = _is.ColumnString(
      'email',
      this,
    );
    login = _is.ColumnString(
      'login',
      this,
    );
    passwordChangeRequired = _is.ColumnBool(
      'passwordChangeRequired',
      this,
      hasDefault: true,
    );
    displayName = _is.ColumnString(
      'displayName',
      this,
    );
    role = _is.ColumnString(
      'role',
      this,
      hasDefault: true,
    );
    managementAccess = _is.ColumnBool(
      'managementAccess',
      this,
      hasDefault: true,
    );
    courtAccess = _is.ColumnBool(
      'courtAccess',
      this,
      hasDefault: true,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final ArchiveMemberUpdateTable updateTable;

  late final _is.ColumnString userId;

  late final _is.ColumnString email;

  late final _is.ColumnString login;

  late final _is.ColumnBool passwordChangeRequired;

  late final _is.ColumnString displayName;

  late final _is.ColumnString role;

  late final _is.ColumnBool managementAccess;

  late final _is.ColumnBool courtAccess;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    email,
    login,
    passwordChangeRequired,
    displayName,
    role,
    managementAccess,
    courtAccess,
    createdAt,
  ];
}

class ArchiveMemberInclude extends _is.IncludeObject {
  ArchiveMemberInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ArchiveMember.t;
}

class ArchiveMemberIncludeList extends _is.IncludeList {
  ArchiveMemberIncludeList._({
    _is.WhereExpressionBuilder<ArchiveMemberTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ArchiveMember.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ArchiveMember.t;
}

class ArchiveMemberRepository {
  const ArchiveMemberRepository._();

  /// Returns a list of [ArchiveMember]s matching the given query parameters.
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
  Future<List<ArchiveMember>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchiveMemberTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchiveMemberTable>? orderBy,
    _is.OrderByListBuilder<ArchiveMemberTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ArchiveMember>(
      where: where?.call(ArchiveMember.t),
      orderBy: orderBy?.call(ArchiveMember.t),
      orderByList: orderByList?.call(ArchiveMember.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ArchiveMember] matching the given query parameters.
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
  Future<ArchiveMember?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchiveMemberTable>? where,
    int? offset,
    _is.OrderByBuilder<ArchiveMemberTable>? orderBy,
    _is.OrderByListBuilder<ArchiveMemberTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ArchiveMember>(
      where: where?.call(ArchiveMember.t),
      orderBy: orderBy?.call(ArchiveMember.t),
      orderByList: orderByList?.call(ArchiveMember.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ArchiveMember] by its [id] or null if no such row exists.
  Future<ArchiveMember?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ArchiveMember>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ArchiveMember]s in the list and returns the inserted rows.
  ///
  /// The returned [ArchiveMember]s will have their `id` fields set.
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
  Future<List<ArchiveMember>> insert(
    _is.DatabaseSession session,
    List<ArchiveMember> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ArchiveMember>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ArchiveMember] and returns the inserted row.
  ///
  /// The returned [ArchiveMember] will have its `id` field set.
  Future<ArchiveMember> insertRow(
    _is.DatabaseSession session,
    ArchiveMember row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ArchiveMember>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ArchiveMember]s in the list and returns the resulting rows.
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
  /// The returned [ArchiveMember]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveMember>> upsert(
    _is.DatabaseSession session,
    List<ArchiveMember> rows, {
    required _is.ColumnSelections<ArchiveMemberTable> conflictColumns,
    _is.ColumnSelections<ArchiveMemberTable>? updateColumns,
    _is.WhereExpressionBuilder<ArchiveMemberTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ArchiveMember>(
      rows,
      conflictColumns: conflictColumns(ArchiveMember.t),
      updateColumns: updateColumns?.call(ArchiveMember.t),
      updateWhere: updateWhere?.call(ArchiveMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ArchiveMember] and returns the resulting row.
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
  /// The returned [ArchiveMember] will have its `id` field set.
  Future<ArchiveMember?> upsertRow(
    _is.DatabaseSession session,
    ArchiveMember row, {
    required _is.ColumnSelections<ArchiveMemberTable> conflictColumns,
    _is.ColumnSelections<ArchiveMemberTable>? updateColumns,
    _is.WhereExpressionBuilder<ArchiveMemberTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ArchiveMember>(
      row,
      conflictColumns: conflictColumns(ArchiveMember.t),
      updateColumns: updateColumns?.call(ArchiveMember.t),
      updateWhere: updateWhere?.call(ArchiveMember.t),
      transaction: transaction,
    );
  }

  /// Updates all [ArchiveMember]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveMember>> update(
    _is.DatabaseSession session,
    List<ArchiveMember> rows, {
    _is.ColumnSelections<ArchiveMemberTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ArchiveMember>(
      rows,
      columns: columns?.call(ArchiveMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ArchiveMember]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ArchiveMember> updateRow(
    _is.DatabaseSession session,
    ArchiveMember row, {
    _is.ColumnSelections<ArchiveMemberTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ArchiveMember>(
      row,
      columns: columns?.call(ArchiveMember.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ArchiveMember] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ArchiveMember?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ArchiveMemberUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ArchiveMember>(
      id,
      columnValues: columnValues(ArchiveMember.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ArchiveMember]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ArchiveMember>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ArchiveMemberUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ArchiveMemberTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ArchiveMemberTable>? orderBy,
    _is.OrderByListBuilder<ArchiveMemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ArchiveMember>(
      columnValues: columnValues(ArchiveMember.t.updateTable),
      where: where(ArchiveMember.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ArchiveMember.t),
      orderByList: orderByList?.call(ArchiveMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ArchiveMember]s in the list and returns the deleted rows.
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
  Future<List<ArchiveMember>> delete(
    _is.DatabaseSession session,
    List<ArchiveMember> rows, {
    _is.OrderByBuilder<ArchiveMemberTable>? orderBy,
    _is.OrderByListBuilder<ArchiveMemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ArchiveMember>(
      rows,
      orderBy: orderBy?.call(ArchiveMember.t),
      orderByList: orderByList?.call(ArchiveMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ArchiveMember].
  Future<ArchiveMember> deleteRow(
    _is.DatabaseSession session,
    ArchiveMember row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ArchiveMember>(
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
  Future<List<ArchiveMember>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ArchiveMemberTable> where,
    _is.OrderByBuilder<ArchiveMemberTable>? orderBy,
    _is.OrderByListBuilder<ArchiveMemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ArchiveMember>(
      where: where(ArchiveMember.t),
      orderBy: orderBy?.call(ArchiveMember.t),
      orderByList: orderByList?.call(ArchiveMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ArchiveMemberTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ArchiveMember>(
      where: where?.call(ArchiveMember.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ArchiveMember] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ArchiveMemberTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ArchiveMember>(
      where: where(ArchiveMember.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
