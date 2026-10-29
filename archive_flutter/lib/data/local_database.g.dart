// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $LocalAccountsTable extends LocalAccounts
    with TableInfo<$LocalAccountsTable, LocalAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountMeta = const VerificationMeta(
    'account',
  );
  @override
  late final GeneratedColumn<String> account = GeneratedColumn<String>(
    'account',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileMeta = const VerificationMeta(
    'profile',
  );
  @override
  late final GeneratedColumn<String> profile = GeneratedColumn<String>(
    'profile',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [account, profile, syncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account')) {
      context.handle(
        _accountMeta,
        account.isAcceptableOrUnknown(data['account']!, _accountMeta),
      );
    } else if (isInserting) {
      context.missing(_accountMeta);
    }
    if (data.containsKey('profile')) {
      context.handle(
        _profileMeta,
        profile.isAcceptableOrUnknown(data['profile']!, _profileMeta),
      );
    } else if (isInserting) {
      context.missing(_profileMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {account};
  @override
  LocalAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAccount(
      account: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account'],
      )!,
      profile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $LocalAccountsTable createAlias(String alias) {
    return $LocalAccountsTable(attachedDatabase, alias);
  }
}

class LocalAccount extends DataClass implements Insertable<LocalAccount> {
  final String account;
  final String profile;
  final String syncedAt;
  const LocalAccount({
    required this.account,
    required this.profile,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account'] = Variable<String>(account);
    map['profile'] = Variable<String>(profile);
    map['synced_at'] = Variable<String>(syncedAt);
    return map;
  }

  LocalAccountsCompanion toCompanion(bool nullToAbsent) {
    return LocalAccountsCompanion(
      account: Value(account),
      profile: Value(profile),
      syncedAt: Value(syncedAt),
    );
  }

  factory LocalAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAccount(
      account: serializer.fromJson<String>(json['account']),
      profile: serializer.fromJson<String>(json['profile']),
      syncedAt: serializer.fromJson<String>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'account': serializer.toJson<String>(account),
      'profile': serializer.toJson<String>(profile),
      'syncedAt': serializer.toJson<String>(syncedAt),
    };
  }

  LocalAccount copyWith({String? account, String? profile, String? syncedAt}) =>
      LocalAccount(
        account: account ?? this.account,
        profile: profile ?? this.profile,
        syncedAt: syncedAt ?? this.syncedAt,
      );
  LocalAccount copyWithCompanion(LocalAccountsCompanion data) {
    return LocalAccount(
      account: data.account.present ? data.account.value : this.account,
      profile: data.profile.present ? data.profile.value : this.profile,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAccount(')
          ..write('account: $account, ')
          ..write('profile: $profile, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(account, profile, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAccount &&
          other.account == this.account &&
          other.profile == this.profile &&
          other.syncedAt == this.syncedAt);
}

class LocalAccountsCompanion extends UpdateCompanion<LocalAccount> {
  final Value<String> account;
  final Value<String> profile;
  final Value<String> syncedAt;
  final Value<int> rowid;
  const LocalAccountsCompanion({
    this.account = const Value.absent(),
    this.profile = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAccountsCompanion.insert({
    required String account,
    required String profile,
    required String syncedAt,
    this.rowid = const Value.absent(),
  }) : account = Value(account),
       profile = Value(profile),
       syncedAt = Value(syncedAt);
  static Insertable<LocalAccount> custom({
    Expression<String>? account,
    Expression<String>? profile,
    Expression<String>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (account != null) 'account': account,
      if (profile != null) 'profile': profile,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAccountsCompanion copyWith({
    Value<String>? account,
    Value<String>? profile,
    Value<String>? syncedAt,
    Value<int>? rowid,
  }) {
    return LocalAccountsCompanion(
      account: account ?? this.account,
      profile: profile ?? this.profile,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (account.present) {
      map['account'] = Variable<String>(account.value);
    }
    if (profile.present) {
      map['profile'] = Variable<String>(profile.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAccountsCompanion(')
          ..write('account: $account, ')
          ..write('profile: $profile, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalRecordsTable extends LocalRecords
    with TableInfo<$LocalRecordsTable, LocalRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountMeta = const VerificationMeta(
    'account',
  );
  @override
  late final GeneratedColumn<String> account = GeneratedColumn<String>(
    'account',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moduleMeta = const VerificationMeta('module');
  @override
  late final GeneratedColumn<String> module = GeneratedColumn<String>(
    'module',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMillisMeta = const VerificationMeta(
    'updatedAtMillis',
  );
  @override
  late final GeneratedColumn<int> updatedAtMillis = GeneratedColumn<int>(
    'updated_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _searchTextMeta = const VerificationMeta(
    'searchText',
  );
  @override
  late final GeneratedColumn<String> searchText = GeneratedColumn<String>(
    'search_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _retentionTypeMeta = const VerificationMeta(
    'retentionType',
  );
  @override
  late final GeneratedColumn<String> retentionType = GeneratedColumn<String>(
    'retention_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    account,
    remoteId,
    module,
    payload,
    updatedAtMillis,
    searchText,
    retentionType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account')) {
      context.handle(
        _accountMeta,
        account.isAcceptableOrUnknown(data['account']!, _accountMeta),
      );
    } else if (isInserting) {
      context.missing(_accountMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('module')) {
      context.handle(
        _moduleMeta,
        module.isAcceptableOrUnknown(data['module']!, _moduleMeta),
      );
    } else if (isInserting) {
      context.missing(_moduleMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('updated_at_millis')) {
      context.handle(
        _updatedAtMillisMeta,
        updatedAtMillis.isAcceptableOrUnknown(
          data['updated_at_millis']!,
          _updatedAtMillisMeta,
        ),
      );
    }
    if (data.containsKey('search_text')) {
      context.handle(
        _searchTextMeta,
        searchText.isAcceptableOrUnknown(data['search_text']!, _searchTextMeta),
      );
    }
    if (data.containsKey('retention_type')) {
      context.handle(
        _retentionTypeMeta,
        retentionType.isAcceptableOrUnknown(
          data['retention_type']!,
          _retentionTypeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {account, remoteId};
  @override
  LocalRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalRecord(
      account: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_id'],
      )!,
      module: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      updatedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_millis'],
      )!,
      searchText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_text'],
      )!,
      retentionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}retention_type'],
      )!,
    );
  }

  @override
  $LocalRecordsTable createAlias(String alias) {
    return $LocalRecordsTable(attachedDatabase, alias);
  }
}

class LocalRecord extends DataClass implements Insertable<LocalRecord> {
  final String account;
  final int remoteId;
  final String module;
  final String payload;
  final int updatedAtMillis;
  final String searchText;
  final String retentionType;
  const LocalRecord({
    required this.account,
    required this.remoteId,
    required this.module,
    required this.payload,
    required this.updatedAtMillis,
    required this.searchText,
    required this.retentionType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account'] = Variable<String>(account);
    map['remote_id'] = Variable<int>(remoteId);
    map['module'] = Variable<String>(module);
    map['payload'] = Variable<String>(payload);
    map['updated_at_millis'] = Variable<int>(updatedAtMillis);
    map['search_text'] = Variable<String>(searchText);
    map['retention_type'] = Variable<String>(retentionType);
    return map;
  }

  LocalRecordsCompanion toCompanion(bool nullToAbsent) {
    return LocalRecordsCompanion(
      account: Value(account),
      remoteId: Value(remoteId),
      module: Value(module),
      payload: Value(payload),
      updatedAtMillis: Value(updatedAtMillis),
      searchText: Value(searchText),
      retentionType: Value(retentionType),
    );
  }

  factory LocalRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalRecord(
      account: serializer.fromJson<String>(json['account']),
      remoteId: serializer.fromJson<int>(json['remoteId']),
      module: serializer.fromJson<String>(json['module']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
      searchText: serializer.fromJson<String>(json['searchText']),
      retentionType: serializer.fromJson<String>(json['retentionType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'account': serializer.toJson<String>(account),
      'remoteId': serializer.toJson<int>(remoteId),
      'module': serializer.toJson<String>(module),
      'payload': serializer.toJson<String>(payload),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
      'searchText': serializer.toJson<String>(searchText),
      'retentionType': serializer.toJson<String>(retentionType),
    };
  }

  LocalRecord copyWith({
    String? account,
    int? remoteId,
    String? module,
    String? payload,
    int? updatedAtMillis,
    String? searchText,
    String? retentionType,
  }) => LocalRecord(
    account: account ?? this.account,
    remoteId: remoteId ?? this.remoteId,
    module: module ?? this.module,
    payload: payload ?? this.payload,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
    searchText: searchText ?? this.searchText,
    retentionType: retentionType ?? this.retentionType,
  );
  LocalRecord copyWithCompanion(LocalRecordsCompanion data) {
    return LocalRecord(
      account: data.account.present ? data.account.value : this.account,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      module: data.module.present ? data.module.value : this.module,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAtMillis: data.updatedAtMillis.present
          ? data.updatedAtMillis.value
          : this.updatedAtMillis,
      searchText: data.searchText.present
          ? data.searchText.value
          : this.searchText,
      retentionType: data.retentionType.present
          ? data.retentionType.value
          : this.retentionType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalRecord(')
          ..write('account: $account, ')
          ..write('remoteId: $remoteId, ')
          ..write('module: $module, ')
          ..write('payload: $payload, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('searchText: $searchText, ')
          ..write('retentionType: $retentionType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    account,
    remoteId,
    module,
    payload,
    updatedAtMillis,
    searchText,
    retentionType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalRecord &&
          other.account == this.account &&
          other.remoteId == this.remoteId &&
          other.module == this.module &&
          other.payload == this.payload &&
          other.updatedAtMillis == this.updatedAtMillis &&
          other.searchText == this.searchText &&
          other.retentionType == this.retentionType);
}

class LocalRecordsCompanion extends UpdateCompanion<LocalRecord> {
  final Value<String> account;
  final Value<int> remoteId;
  final Value<String> module;
  final Value<String> payload;
  final Value<int> updatedAtMillis;
  final Value<String> searchText;
  final Value<String> retentionType;
  final Value<int> rowid;
  const LocalRecordsCompanion({
    this.account = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.module = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.searchText = const Value.absent(),
    this.retentionType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalRecordsCompanion.insert({
    required String account,
    required int remoteId,
    required String module,
    required String payload,
    this.updatedAtMillis = const Value.absent(),
    this.searchText = const Value.absent(),
    this.retentionType = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : account = Value(account),
       remoteId = Value(remoteId),
       module = Value(module),
       payload = Value(payload);
  static Insertable<LocalRecord> custom({
    Expression<String>? account,
    Expression<int>? remoteId,
    Expression<String>? module,
    Expression<String>? payload,
    Expression<int>? updatedAtMillis,
    Expression<String>? searchText,
    Expression<String>? retentionType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (account != null) 'account': account,
      if (remoteId != null) 'remote_id': remoteId,
      if (module != null) 'module': module,
      if (payload != null) 'payload': payload,
      if (updatedAtMillis != null) 'updated_at_millis': updatedAtMillis,
      if (searchText != null) 'search_text': searchText,
      if (retentionType != null) 'retention_type': retentionType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalRecordsCompanion copyWith({
    Value<String>? account,
    Value<int>? remoteId,
    Value<String>? module,
    Value<String>? payload,
    Value<int>? updatedAtMillis,
    Value<String>? searchText,
    Value<String>? retentionType,
    Value<int>? rowid,
  }) {
    return LocalRecordsCompanion(
      account: account ?? this.account,
      remoteId: remoteId ?? this.remoteId,
      module: module ?? this.module,
      payload: payload ?? this.payload,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      searchText: searchText ?? this.searchText,
      retentionType: retentionType ?? this.retentionType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (account.present) {
      map['account'] = Variable<String>(account.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (module.present) {
      map['module'] = Variable<String>(module.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAtMillis.present) {
      map['updated_at_millis'] = Variable<int>(updatedAtMillis.value);
    }
    if (searchText.present) {
      map['search_text'] = Variable<String>(searchText.value);
    }
    if (retentionType.present) {
      map['retention_type'] = Variable<String>(retentionType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalRecordsCompanion(')
          ..write('account: $account, ')
          ..write('remoteId: $remoteId, ')
          ..write('module: $module, ')
          ..write('payload: $payload, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('searchText: $searchText, ')
          ..write('retentionType: $retentionType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalDocumentsTable extends LocalDocuments
    with TableInfo<$LocalDocumentsTable, LocalDocument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalDocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountMeta = const VerificationMeta(
    'account',
  );
  @override
  late final GeneratedColumn<String> account = GeneratedColumn<String>(
    'account',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentsMeta = const VerificationMeta(
    'contents',
  );
  @override
  late final GeneratedColumn<Uint8List> contents = GeneratedColumn<Uint8List>(
    'contents',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [account, remoteId, payload, contents];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalDocument> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account')) {
      context.handle(
        _accountMeta,
        account.isAcceptableOrUnknown(data['account']!, _accountMeta),
      );
    } else if (isInserting) {
      context.missing(_accountMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('contents')) {
      context.handle(
        _contentsMeta,
        contents.isAcceptableOrUnknown(data['contents']!, _contentsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {account, remoteId};
  @override
  LocalDocument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalDocument(
      account: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      contents: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}contents'],
      ),
    );
  }

  @override
  $LocalDocumentsTable createAlias(String alias) {
    return $LocalDocumentsTable(attachedDatabase, alias);
  }
}

class LocalDocument extends DataClass implements Insertable<LocalDocument> {
  final String account;
  final int remoteId;
  final String payload;
  final Uint8List? contents;
  const LocalDocument({
    required this.account,
    required this.remoteId,
    required this.payload,
    this.contents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account'] = Variable<String>(account);
    map['remote_id'] = Variable<int>(remoteId);
    map['payload'] = Variable<String>(payload);
    if (!nullToAbsent || contents != null) {
      map['contents'] = Variable<Uint8List>(contents);
    }
    return map;
  }

  LocalDocumentsCompanion toCompanion(bool nullToAbsent) {
    return LocalDocumentsCompanion(
      account: Value(account),
      remoteId: Value(remoteId),
      payload: Value(payload),
      contents: contents == null && nullToAbsent
          ? const Value.absent()
          : Value(contents),
    );
  }

  factory LocalDocument.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalDocument(
      account: serializer.fromJson<String>(json['account']),
      remoteId: serializer.fromJson<int>(json['remoteId']),
      payload: serializer.fromJson<String>(json['payload']),
      contents: serializer.fromJson<Uint8List?>(json['contents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'account': serializer.toJson<String>(account),
      'remoteId': serializer.toJson<int>(remoteId),
      'payload': serializer.toJson<String>(payload),
      'contents': serializer.toJson<Uint8List?>(contents),
    };
  }

  LocalDocument copyWith({
    String? account,
    int? remoteId,
    String? payload,
    Value<Uint8List?> contents = const Value.absent(),
  }) => LocalDocument(
    account: account ?? this.account,
    remoteId: remoteId ?? this.remoteId,
    payload: payload ?? this.payload,
    contents: contents.present ? contents.value : this.contents,
  );
  LocalDocument copyWithCompanion(LocalDocumentsCompanion data) {
    return LocalDocument(
      account: data.account.present ? data.account.value : this.account,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      payload: data.payload.present ? data.payload.value : this.payload,
      contents: data.contents.present ? data.contents.value : this.contents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalDocument(')
          ..write('account: $account, ')
          ..write('remoteId: $remoteId, ')
          ..write('payload: $payload, ')
          ..write('contents: $contents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    account,
    remoteId,
    payload,
    $driftBlobEquality.hash(contents),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalDocument &&
          other.account == this.account &&
          other.remoteId == this.remoteId &&
          other.payload == this.payload &&
          $driftBlobEquality.equals(other.contents, this.contents));
}

class LocalDocumentsCompanion extends UpdateCompanion<LocalDocument> {
  final Value<String> account;
  final Value<int> remoteId;
  final Value<String> payload;
  final Value<Uint8List?> contents;
  final Value<int> rowid;
  const LocalDocumentsCompanion({
    this.account = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.payload = const Value.absent(),
    this.contents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalDocumentsCompanion.insert({
    required String account,
    required int remoteId,
    required String payload,
    this.contents = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : account = Value(account),
       remoteId = Value(remoteId),
       payload = Value(payload);
  static Insertable<LocalDocument> custom({
    Expression<String>? account,
    Expression<int>? remoteId,
    Expression<String>? payload,
    Expression<Uint8List>? contents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (account != null) 'account': account,
      if (remoteId != null) 'remote_id': remoteId,
      if (payload != null) 'payload': payload,
      if (contents != null) 'contents': contents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalDocumentsCompanion copyWith({
    Value<String>? account,
    Value<int>? remoteId,
    Value<String>? payload,
    Value<Uint8List?>? contents,
    Value<int>? rowid,
  }) {
    return LocalDocumentsCompanion(
      account: account ?? this.account,
      remoteId: remoteId ?? this.remoteId,
      payload: payload ?? this.payload,
      contents: contents ?? this.contents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (account.present) {
      map['account'] = Variable<String>(account.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (contents.present) {
      map['contents'] = Variable<Uint8List>(contents.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalDocumentsCompanion(')
          ..write('account: $account, ')
          ..write('remoteId: $remoteId, ')
          ..write('payload: $payload, ')
          ..write('contents: $contents, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAuditEventsTable extends LocalAuditEvents
    with TableInfo<$LocalAuditEventsTable, LocalAuditEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAuditEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountMeta = const VerificationMeta(
    'account',
  );
  @override
  late final GeneratedColumn<String> account = GeneratedColumn<String>(
    'account',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [account, remoteId, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_audit_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAuditEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account')) {
      context.handle(
        _accountMeta,
        account.isAcceptableOrUnknown(data['account']!, _accountMeta),
      );
    } else if (isInserting) {
      context.missing(_accountMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {account, remoteId};
  @override
  LocalAuditEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAuditEvent(
      account: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $LocalAuditEventsTable createAlias(String alias) {
    return $LocalAuditEventsTable(attachedDatabase, alias);
  }
}

class LocalAuditEvent extends DataClass implements Insertable<LocalAuditEvent> {
  final String account;
  final int remoteId;
  final String payload;
  const LocalAuditEvent({
    required this.account,
    required this.remoteId,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account'] = Variable<String>(account);
    map['remote_id'] = Variable<int>(remoteId);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  LocalAuditEventsCompanion toCompanion(bool nullToAbsent) {
    return LocalAuditEventsCompanion(
      account: Value(account),
      remoteId: Value(remoteId),
      payload: Value(payload),
    );
  }

  factory LocalAuditEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAuditEvent(
      account: serializer.fromJson<String>(json['account']),
      remoteId: serializer.fromJson<int>(json['remoteId']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'account': serializer.toJson<String>(account),
      'remoteId': serializer.toJson<int>(remoteId),
      'payload': serializer.toJson<String>(payload),
    };
  }

  LocalAuditEvent copyWith({String? account, int? remoteId, String? payload}) =>
      LocalAuditEvent(
        account: account ?? this.account,
        remoteId: remoteId ?? this.remoteId,
        payload: payload ?? this.payload,
      );
  LocalAuditEvent copyWithCompanion(LocalAuditEventsCompanion data) {
    return LocalAuditEvent(
      account: data.account.present ? data.account.value : this.account,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAuditEvent(')
          ..write('account: $account, ')
          ..write('remoteId: $remoteId, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(account, remoteId, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAuditEvent &&
          other.account == this.account &&
          other.remoteId == this.remoteId &&
          other.payload == this.payload);
}

class LocalAuditEventsCompanion extends UpdateCompanion<LocalAuditEvent> {
  final Value<String> account;
  final Value<int> remoteId;
  final Value<String> payload;
  final Value<int> rowid;
  const LocalAuditEventsCompanion({
    this.account = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAuditEventsCompanion.insert({
    required String account,
    required int remoteId,
    required String payload,
    this.rowid = const Value.absent(),
  }) : account = Value(account),
       remoteId = Value(remoteId),
       payload = Value(payload);
  static Insertable<LocalAuditEvent> custom({
    Expression<String>? account,
    Expression<int>? remoteId,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (account != null) 'account': account,
      if (remoteId != null) 'remote_id': remoteId,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAuditEventsCompanion copyWith({
    Value<String>? account,
    Value<int>? remoteId,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return LocalAuditEventsCompanion(
      account: account ?? this.account,
      remoteId: remoteId ?? this.remoteId,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (account.present) {
      map['account'] = Variable<String>(account.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAuditEventsCompanion(')
          ..write('account: $account, ')
          ..write('remoteId: $remoteId, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMembersTable extends LocalMembers
    with TableInfo<$LocalMembersTable, LocalMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountMeta = const VerificationMeta(
    'account',
  );
  @override
  late final GeneratedColumn<String> account = GeneratedColumn<String>(
    'account',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [account, remoteId, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account')) {
      context.handle(
        _accountMeta,
        account.isAcceptableOrUnknown(data['account']!, _accountMeta),
      );
    } else if (isInserting) {
      context.missing(_accountMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {account, remoteId};
  @override
  LocalMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMember(
      account: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $LocalMembersTable createAlias(String alias) {
    return $LocalMembersTable(attachedDatabase, alias);
  }
}

class LocalMember extends DataClass implements Insertable<LocalMember> {
  final String account;
  final int remoteId;
  final String payload;
  const LocalMember({
    required this.account,
    required this.remoteId,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account'] = Variable<String>(account);
    map['remote_id'] = Variable<int>(remoteId);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  LocalMembersCompanion toCompanion(bool nullToAbsent) {
    return LocalMembersCompanion(
      account: Value(account),
      remoteId: Value(remoteId),
      payload: Value(payload),
    );
  }

  factory LocalMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMember(
      account: serializer.fromJson<String>(json['account']),
      remoteId: serializer.fromJson<int>(json['remoteId']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'account': serializer.toJson<String>(account),
      'remoteId': serializer.toJson<int>(remoteId),
      'payload': serializer.toJson<String>(payload),
    };
  }

  LocalMember copyWith({String? account, int? remoteId, String? payload}) =>
      LocalMember(
        account: account ?? this.account,
        remoteId: remoteId ?? this.remoteId,
        payload: payload ?? this.payload,
      );
  LocalMember copyWithCompanion(LocalMembersCompanion data) {
    return LocalMember(
      account: data.account.present ? data.account.value : this.account,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMember(')
          ..write('account: $account, ')
          ..write('remoteId: $remoteId, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(account, remoteId, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMember &&
          other.account == this.account &&
          other.remoteId == this.remoteId &&
          other.payload == this.payload);
}

class LocalMembersCompanion extends UpdateCompanion<LocalMember> {
  final Value<String> account;
  final Value<int> remoteId;
  final Value<String> payload;
  final Value<int> rowid;
  const LocalMembersCompanion({
    this.account = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMembersCompanion.insert({
    required String account,
    required int remoteId,
    required String payload,
    this.rowid = const Value.absent(),
  }) : account = Value(account),
       remoteId = Value(remoteId),
       payload = Value(payload);
  static Insertable<LocalMember> custom({
    Expression<String>? account,
    Expression<int>? remoteId,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (account != null) 'account': account,
      if (remoteId != null) 'remote_id': remoteId,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMembersCompanion copyWith({
    Value<String>? account,
    Value<int>? remoteId,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return LocalMembersCompanion(
      account: account ?? this.account,
      remoteId: remoteId ?? this.remoteId,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (account.present) {
      map['account'] = Variable<String>(account.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMembersCompanion(')
          ..write('account: $account, ')
          ..write('remoteId: $remoteId, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ArchiveLocalDatabase extends GeneratedDatabase {
  _$ArchiveLocalDatabase(QueryExecutor e) : super(e);
  $ArchiveLocalDatabaseManager get managers =>
      $ArchiveLocalDatabaseManager(this);
  late final $LocalAccountsTable localAccounts = $LocalAccountsTable(this);
  late final $LocalRecordsTable localRecords = $LocalRecordsTable(this);
  late final $LocalDocumentsTable localDocuments = $LocalDocumentsTable(this);
  late final $LocalAuditEventsTable localAuditEvents = $LocalAuditEventsTable(
    this,
  );
  late final $LocalMembersTable localMembers = $LocalMembersTable(this);
  late final Index localRecordsPageIdx = Index(
    'local_records_page_idx',
    'CREATE INDEX local_records_page_idx ON local_records (account, module, updated_at_millis, remote_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localAccounts,
    localRecords,
    localDocuments,
    localAuditEvents,
    localMembers,
    localRecordsPageIdx,
  ];
}

typedef $$LocalAccountsTableCreateCompanionBuilder =
    LocalAccountsCompanion Function({
      required String account,
      required String profile,
      required String syncedAt,
      Value<int> rowid,
    });
typedef $$LocalAccountsTableUpdateCompanionBuilder =
    LocalAccountsCompanion Function({
      Value<String> account,
      Value<String> profile,
      Value<String> syncedAt,
      Value<int> rowid,
    });

class $$LocalAccountsTableFilterComposer
    extends Composer<_$ArchiveLocalDatabase, $LocalAccountsTable> {
  $$LocalAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get account => $composableBuilder(
    column: $table.account,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profile => $composableBuilder(
    column: $table.profile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAccountsTableOrderingComposer
    extends Composer<_$ArchiveLocalDatabase, $LocalAccountsTable> {
  $$LocalAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get account => $composableBuilder(
    column: $table.account,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profile => $composableBuilder(
    column: $table.profile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAccountsTableAnnotationComposer
    extends Composer<_$ArchiveLocalDatabase, $LocalAccountsTable> {
  $$LocalAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get account =>
      $composableBuilder(column: $table.account, builder: (column) => column);

  GeneratedColumn<String> get profile =>
      $composableBuilder(column: $table.profile, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$LocalAccountsTableTableManager
    extends
        RootTableManager<
          _$ArchiveLocalDatabase,
          $LocalAccountsTable,
          LocalAccount,
          $$LocalAccountsTableFilterComposer,
          $$LocalAccountsTableOrderingComposer,
          $$LocalAccountsTableAnnotationComposer,
          $$LocalAccountsTableCreateCompanionBuilder,
          $$LocalAccountsTableUpdateCompanionBuilder,
          (
            LocalAccount,
            BaseReferences<
              _$ArchiveLocalDatabase,
              $LocalAccountsTable,
              LocalAccount
            >,
          ),
          LocalAccount,
          PrefetchHooks Function()
        > {
  $$LocalAccountsTableTableManager(
    _$ArchiveLocalDatabase db,
    $LocalAccountsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> account = const Value.absent(),
                Value<String> profile = const Value.absent(),
                Value<String> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAccountsCompanion(
                account: account,
                profile: profile,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String account,
                required String profile,
                required String syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalAccountsCompanion.insert(
                account: account,
                profile: profile,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$ArchiveLocalDatabase,
      $LocalAccountsTable,
      LocalAccount,
      $$LocalAccountsTableFilterComposer,
      $$LocalAccountsTableOrderingComposer,
      $$LocalAccountsTableAnnotationComposer,
      $$LocalAccountsTableCreateCompanionBuilder,
      $$LocalAccountsTableUpdateCompanionBuilder,
      (
        LocalAccount,
        BaseReferences<
          _$ArchiveLocalDatabase,
          $LocalAccountsTable,
          LocalAccount
        >,
      ),
      LocalAccount,
      PrefetchHooks Function()
    >;
typedef $$LocalRecordsTableCreateCompanionBuilder =
    LocalRecordsCompanion Function({
      required String account,
      required int remoteId,
      required String module,
      required String payload,
      Value<int> updatedAtMillis,
      Value<String> searchText,
      Value<String> retentionType,
      Value<int> rowid,
    });
typedef $$LocalRecordsTableUpdateCompanionBuilder =
    LocalRecordsCompanion Function({
      Value<String> account,
      Value<int> remoteId,
      Value<String> module,
      Value<String> payload,
      Value<int> updatedAtMillis,
      Value<String> searchText,
      Value<String> retentionType,
      Value<int> rowid,
    });

class $$LocalRecordsTableFilterComposer
    extends Composer<_$ArchiveLocalDatabase, $LocalRecordsTable> {
  $$LocalRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get account => $composableBuilder(
    column: $table.account,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get module => $composableBuilder(
    column: $table.module,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get retentionType => $composableBuilder(
    column: $table.retentionType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalRecordsTableOrderingComposer
    extends Composer<_$ArchiveLocalDatabase, $LocalRecordsTable> {
  $$LocalRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get account => $composableBuilder(
    column: $table.account,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get module => $composableBuilder(
    column: $table.module,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get retentionType => $composableBuilder(
    column: $table.retentionType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalRecordsTableAnnotationComposer
    extends Composer<_$ArchiveLocalDatabase, $LocalRecordsTable> {
  $$LocalRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get account =>
      $composableBuilder(column: $table.account, builder: (column) => column);

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get module =>
      $composableBuilder(column: $table.module, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get retentionType => $composableBuilder(
    column: $table.retentionType,
    builder: (column) => column,
  );
}

class $$LocalRecordsTableTableManager
    extends
        RootTableManager<
          _$ArchiveLocalDatabase,
          $LocalRecordsTable,
          LocalRecord,
          $$LocalRecordsTableFilterComposer,
          $$LocalRecordsTableOrderingComposer,
          $$LocalRecordsTableAnnotationComposer,
          $$LocalRecordsTableCreateCompanionBuilder,
          $$LocalRecordsTableUpdateCompanionBuilder,
          (
            LocalRecord,
            BaseReferences<
              _$ArchiveLocalDatabase,
              $LocalRecordsTable,
              LocalRecord
            >,
          ),
          LocalRecord,
          PrefetchHooks Function()
        > {
  $$LocalRecordsTableTableManager(
    _$ArchiveLocalDatabase db,
    $LocalRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> account = const Value.absent(),
                Value<int> remoteId = const Value.absent(),
                Value<String> module = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<String> retentionType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRecordsCompanion(
                account: account,
                remoteId: remoteId,
                module: module,
                payload: payload,
                updatedAtMillis: updatedAtMillis,
                searchText: searchText,
                retentionType: retentionType,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String account,
                required int remoteId,
                required String module,
                required String payload,
                Value<int> updatedAtMillis = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<String> retentionType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRecordsCompanion.insert(
                account: account,
                remoteId: remoteId,
                module: module,
                payload: payload,
                updatedAtMillis: updatedAtMillis,
                searchText: searchText,
                retentionType: retentionType,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$ArchiveLocalDatabase,
      $LocalRecordsTable,
      LocalRecord,
      $$LocalRecordsTableFilterComposer,
      $$LocalRecordsTableOrderingComposer,
      $$LocalRecordsTableAnnotationComposer,
      $$LocalRecordsTableCreateCompanionBuilder,
      $$LocalRecordsTableUpdateCompanionBuilder,
      (
        LocalRecord,
        BaseReferences<_$ArchiveLocalDatabase, $LocalRecordsTable, LocalRecord>,
      ),
      LocalRecord,
      PrefetchHooks Function()
    >;
typedef $$LocalDocumentsTableCreateCompanionBuilder =
    LocalDocumentsCompanion Function({
      required String account,
      required int remoteId,
      required String payload,
      Value<Uint8List?> contents,
      Value<int> rowid,
    });
typedef $$LocalDocumentsTableUpdateCompanionBuilder =
    LocalDocumentsCompanion Function({
      Value<String> account,
      Value<int> remoteId,
      Value<String> payload,
      Value<Uint8List?> contents,
      Value<int> rowid,
    });

class $$LocalDocumentsTableFilterComposer
    extends Composer<_$ArchiveLocalDatabase, $LocalDocumentsTable> {
  $$LocalDocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get account => $composableBuilder(
    column: $table.account,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get contents => $composableBuilder(
    column: $table.contents,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalDocumentsTableOrderingComposer
    extends Composer<_$ArchiveLocalDatabase, $LocalDocumentsTable> {
  $$LocalDocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get account => $composableBuilder(
    column: $table.account,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get contents => $composableBuilder(
    column: $table.contents,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalDocumentsTableAnnotationComposer
    extends Composer<_$ArchiveLocalDatabase, $LocalDocumentsTable> {
  $$LocalDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get account =>
      $composableBuilder(column: $table.account, builder: (column) => column);

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<Uint8List> get contents =>
      $composableBuilder(column: $table.contents, builder: (column) => column);
}

class $$LocalDocumentsTableTableManager
    extends
        RootTableManager<
          _$ArchiveLocalDatabase,
          $LocalDocumentsTable,
          LocalDocument,
          $$LocalDocumentsTableFilterComposer,
          $$LocalDocumentsTableOrderingComposer,
          $$LocalDocumentsTableAnnotationComposer,
          $$LocalDocumentsTableCreateCompanionBuilder,
          $$LocalDocumentsTableUpdateCompanionBuilder,
          (
            LocalDocument,
            BaseReferences<
              _$ArchiveLocalDatabase,
              $LocalDocumentsTable,
              LocalDocument
            >,
          ),
          LocalDocument,
          PrefetchHooks Function()
        > {
  $$LocalDocumentsTableTableManager(
    _$ArchiveLocalDatabase db,
    $LocalDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalDocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> account = const Value.absent(),
                Value<int> remoteId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<Uint8List?> contents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalDocumentsCompanion(
                account: account,
                remoteId: remoteId,
                payload: payload,
                contents: contents,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String account,
                required int remoteId,
                required String payload,
                Value<Uint8List?> contents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalDocumentsCompanion.insert(
                account: account,
                remoteId: remoteId,
                payload: payload,
                contents: contents,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$ArchiveLocalDatabase,
      $LocalDocumentsTable,
      LocalDocument,
      $$LocalDocumentsTableFilterComposer,
      $$LocalDocumentsTableOrderingComposer,
      $$LocalDocumentsTableAnnotationComposer,
      $$LocalDocumentsTableCreateCompanionBuilder,
      $$LocalDocumentsTableUpdateCompanionBuilder,
      (
        LocalDocument,
        BaseReferences<
          _$ArchiveLocalDatabase,
          $LocalDocumentsTable,
          LocalDocument
        >,
      ),
      LocalDocument,
      PrefetchHooks Function()
    >;
typedef $$LocalAuditEventsTableCreateCompanionBuilder =
    LocalAuditEventsCompanion Function({
      required String account,
      required int remoteId,
      required String payload,
      Value<int> rowid,
    });
typedef $$LocalAuditEventsTableUpdateCompanionBuilder =
    LocalAuditEventsCompanion Function({
      Value<String> account,
      Value<int> remoteId,
      Value<String> payload,
      Value<int> rowid,
    });

class $$LocalAuditEventsTableFilterComposer
    extends Composer<_$ArchiveLocalDatabase, $LocalAuditEventsTable> {
  $$LocalAuditEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get account => $composableBuilder(
    column: $table.account,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAuditEventsTableOrderingComposer
    extends Composer<_$ArchiveLocalDatabase, $LocalAuditEventsTable> {
  $$LocalAuditEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get account => $composableBuilder(
    column: $table.account,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAuditEventsTableAnnotationComposer
    extends Composer<_$ArchiveLocalDatabase, $LocalAuditEventsTable> {
  $$LocalAuditEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get account =>
      $composableBuilder(column: $table.account, builder: (column) => column);

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$LocalAuditEventsTableTableManager
    extends
        RootTableManager<
          _$ArchiveLocalDatabase,
          $LocalAuditEventsTable,
          LocalAuditEvent,
          $$LocalAuditEventsTableFilterComposer,
          $$LocalAuditEventsTableOrderingComposer,
          $$LocalAuditEventsTableAnnotationComposer,
          $$LocalAuditEventsTableCreateCompanionBuilder,
          $$LocalAuditEventsTableUpdateCompanionBuilder,
          (
            LocalAuditEvent,
            BaseReferences<
              _$ArchiveLocalDatabase,
              $LocalAuditEventsTable,
              LocalAuditEvent
            >,
          ),
          LocalAuditEvent,
          PrefetchHooks Function()
        > {
  $$LocalAuditEventsTableTableManager(
    _$ArchiveLocalDatabase db,
    $LocalAuditEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAuditEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAuditEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAuditEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> account = const Value.absent(),
                Value<int> remoteId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAuditEventsCompanion(
                account: account,
                remoteId: remoteId,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String account,
                required int remoteId,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => LocalAuditEventsCompanion.insert(
                account: account,
                remoteId: remoteId,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAuditEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$ArchiveLocalDatabase,
      $LocalAuditEventsTable,
      LocalAuditEvent,
      $$LocalAuditEventsTableFilterComposer,
      $$LocalAuditEventsTableOrderingComposer,
      $$LocalAuditEventsTableAnnotationComposer,
      $$LocalAuditEventsTableCreateCompanionBuilder,
      $$LocalAuditEventsTableUpdateCompanionBuilder,
      (
        LocalAuditEvent,
        BaseReferences<
          _$ArchiveLocalDatabase,
          $LocalAuditEventsTable,
          LocalAuditEvent
        >,
      ),
      LocalAuditEvent,
      PrefetchHooks Function()
    >;
typedef $$LocalMembersTableCreateCompanionBuilder =
    LocalMembersCompanion Function({
      required String account,
      required int remoteId,
      required String payload,
      Value<int> rowid,
    });
typedef $$LocalMembersTableUpdateCompanionBuilder =
    LocalMembersCompanion Function({
      Value<String> account,
      Value<int> remoteId,
      Value<String> payload,
      Value<int> rowid,
    });

class $$LocalMembersTableFilterComposer
    extends Composer<_$ArchiveLocalDatabase, $LocalMembersTable> {
  $$LocalMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get account => $composableBuilder(
    column: $table.account,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalMembersTableOrderingComposer
    extends Composer<_$ArchiveLocalDatabase, $LocalMembersTable> {
  $$LocalMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get account => $composableBuilder(
    column: $table.account,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalMembersTableAnnotationComposer
    extends Composer<_$ArchiveLocalDatabase, $LocalMembersTable> {
  $$LocalMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get account =>
      $composableBuilder(column: $table.account, builder: (column) => column);

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$LocalMembersTableTableManager
    extends
        RootTableManager<
          _$ArchiveLocalDatabase,
          $LocalMembersTable,
          LocalMember,
          $$LocalMembersTableFilterComposer,
          $$LocalMembersTableOrderingComposer,
          $$LocalMembersTableAnnotationComposer,
          $$LocalMembersTableCreateCompanionBuilder,
          $$LocalMembersTableUpdateCompanionBuilder,
          (
            LocalMember,
            BaseReferences<
              _$ArchiveLocalDatabase,
              $LocalMembersTable,
              LocalMember
            >,
          ),
          LocalMember,
          PrefetchHooks Function()
        > {
  $$LocalMembersTableTableManager(
    _$ArchiveLocalDatabase db,
    $LocalMembersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> account = const Value.absent(),
                Value<int> remoteId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMembersCompanion(
                account: account,
                remoteId: remoteId,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String account,
                required int remoteId,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => LocalMembersCompanion.insert(
                account: account,
                remoteId: remoteId,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$ArchiveLocalDatabase,
      $LocalMembersTable,
      LocalMember,
      $$LocalMembersTableFilterComposer,
      $$LocalMembersTableOrderingComposer,
      $$LocalMembersTableAnnotationComposer,
      $$LocalMembersTableCreateCompanionBuilder,
      $$LocalMembersTableUpdateCompanionBuilder,
      (
        LocalMember,
        BaseReferences<_$ArchiveLocalDatabase, $LocalMembersTable, LocalMember>,
      ),
      LocalMember,
      PrefetchHooks Function()
    >;

class $ArchiveLocalDatabaseManager {
  final _$ArchiveLocalDatabase _db;
  $ArchiveLocalDatabaseManager(this._db);
  $$LocalAccountsTableTableManager get localAccounts =>
      $$LocalAccountsTableTableManager(_db, _db.localAccounts);
  $$LocalRecordsTableTableManager get localRecords =>
      $$LocalRecordsTableTableManager(_db, _db.localRecords);
  $$LocalDocumentsTableTableManager get localDocuments =>
      $$LocalDocumentsTableTableManager(_db, _db.localDocuments);
  $$LocalAuditEventsTableTableManager get localAuditEvents =>
      $$LocalAuditEventsTableTableManager(_db, _db.localAuditEvents);
  $$LocalMembersTableTableManager get localMembers =>
      $$LocalMembersTableTableManager(_db, _db.localMembers);
}
