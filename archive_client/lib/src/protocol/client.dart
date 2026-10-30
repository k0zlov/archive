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
import 'dart:async' as _ida;
import 'dart:typed_data' as _idt;
import 'package:archive_client/src/protocol/greetings/greeting.dart'
    as _ioqiwtc5;
import 'package:http/http.dart' as _i85jenna;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'protocol.dart' as _il2as5qe;

/// Server-side authorization is rechecked for every operation, including reads.
/// {@category Endpoint}
class EndpointArchive extends _isc.EndpointRef {
  EndpointArchive(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'archive';

  _ida.Future<String> profile() => caller.callServerEndpoint<String>(
    'archive',
    'profile',
    {},
  );

  _ida.Future<String> records(int afterId) => caller.callServerEndpoint<String>(
    'archive',
    'records',
    {'afterId': afterId},
  );

  /// Every committed card mutation writes its audit event in the same transaction.
  _ida.Future<String> recordRevision() => caller.callServerEndpoint<String>(
    'archive',
    'recordRevision',
    {},
  );

  _ida.Future<String> saveRecord(
    String module,
    String valuesJson,
    int? id,
    int? version,
  ) => caller.callServerEndpoint<String>(
    'archive',
    'saveRecord',
    {
      'module': module,
      'valuesJson': valuesJson,
      'id': id,
      'version': version,
    },
  );

  _ida.Future<String> importRecords(
    String module,
    List<String> rows,
  ) => caller.callServerEndpoint<String>(
    'archive',
    'importRecords',
    {
      'module': module,
      'rows': rows,
    },
  );

  _ida.Future<String> beginImport(
    String module, {
    required bool replaceExisting,
    required List<String> sourceNames,
  }) => caller.callServerEndpoint<String>(
    'archive',
    'beginImport',
    {
      'module': module,
      'replaceExisting': replaceExisting,
      'sourceNames': sourceNames,
    },
  );

  _ida.Future<String> appendImportRows(
    int jobId,
    int offset,
    List<String> rows,
  ) => caller.callServerEndpoint<String>(
    'archive',
    'appendImportRows',
    {
      'jobId': jobId,
      'offset': offset,
      'rows': rows,
    },
  );

  _ida.Future<String> commitImport(int jobId) =>
      caller.callServerEndpoint<String>(
        'archive',
        'commitImport',
        {'jobId': jobId},
      );

  _ida.Future<String> cancelImport(int jobId) =>
      caller.callServerEndpoint<String>(
        'archive',
        'cancelImport',
        {'jobId': jobId},
      );

  _ida.Future<String> relatedRecords(int id) =>
      caller.callServerEndpoint<String>(
        'archive',
        'relatedRecords',
        {'id': id},
      );

  _ida.Future<String> members() => caller.callServerEndpoint<String>(
    'archive',
    'members',
    {},
  );

  _ida.Future<String> setMemberAccess(
    int memberId,
    String role,
    bool managementAccess,
    bool courtAccess,
  ) => caller.callServerEndpoint<String>(
    'archive',
    'setMemberAccess',
    {
      'memberId': memberId,
      'role': role,
      'managementAccess': managementAccess,
      'courtAccess': courtAccess,
    },
  );

  _ida.Future<String> documents() => caller.callServerEndpoint<String>(
    'archive',
    'documents',
    {},
  );

  _ida.Future<String> uploadDocument(
    String title,
    String fileName,
    int year,
    String contentBase64,
  ) => caller.callServerEndpoint<String>(
    'archive',
    'uploadDocument',
    {
      'title': title,
      'fileName': fileName,
      'year': year,
      'contentBase64': contentBase64,
    },
  );

  _ida.Future<String> downloadDocument(int id) =>
      caller.callServerEndpoint<String>(
        'archive',
        'downloadDocument',
        {'id': id},
      );

  _ida.Future<String> deleteRecord(
    int id,
    int version,
  ) => caller.callServerEndpoint<String>(
    'archive',
    'deleteRecord',
    {
      'id': id,
      'version': version,
    },
  );

  _ida.Future<String> restoreRecord(int id) =>
      caller.callServerEndpoint<String>(
        'archive',
        'restoreRecord',
        {'id': id},
      );

  _ida.Future<String> deleteDocument(int id) =>
      caller.callServerEndpoint<String>(
        'archive',
        'deleteDocument',
        {'id': id},
      );

  _ida.Future<String> restoreDocument(int id) =>
      caller.callServerEndpoint<String>(
        'archive',
        'restoreDocument',
        {'id': id},
      );

  _ida.Future<String> auditEntries(
    int beforeId,
    String query,
  ) => caller.callServerEndpoint<String>(
    'archive',
    'auditEntries',
    {
      'beforeId': beforeId,
      'query': query,
    },
  );
}

/// {@category Endpoint}
class EndpointArchiveMaintenance extends _isc.EndpointRef {
  EndpointArchiveMaintenance(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'archiveMaintenance';

  _ida.Future<String> summary() => caller.callServerEndpoint<String>(
    'archiveMaintenance',
    'summary',
    {},
  );

  _ida.Future<String> clearRecords(String confirmation) =>
      caller.callServerEndpoint<String>(
        'archiveMaintenance',
        'clearRecords',
        {'confirmation': confirmation},
      );

  _ida.Future<String> clearArchive(String confirmation) =>
      caller.callServerEndpoint<String>(
        'archiveMaintenance',
        'clearArchive',
        {'confirmation': confirmation},
      );
}

/// {@category Endpoint}
class EndpointAttachment extends _isc.EndpointRef {
  EndpointAttachment(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'attachment';

  _ida.Future<String> list(int afterId) => caller.callServerEndpoint<String>(
    'attachment',
    'list',
    {'afterId': afterId},
  );

  _ida.Future<String> begin(
    int recordId,
    String fileName,
    int byteLength,
  ) => caller.callServerEndpoint<String>(
    'attachment',
    'begin',
    {
      'recordId': recordId,
      'fileName': fileName,
      'byteLength': byteLength,
    },
  );

  _ida.Future<String> append(
    int id,
    int chunkIndex,
    String content,
  ) => caller.callServerEndpoint<String>(
    'attachment',
    'append',
    {
      'id': id,
      'chunkIndex': chunkIndex,
      'content': content,
    },
  );

  _ida.Future<String> finish(int id) => caller.callServerEndpoint<String>(
    'attachment',
    'finish',
    {'id': id},
  );

  _ida.Future<String> cancel(int id) => caller.callServerEndpoint<String>(
    'attachment',
    'cancel',
    {'id': id},
  );

  _ida.Future<String> download(
    int id,
    int chunkIndex,
  ) => caller.callServerEndpoint<String>(
    'attachment',
    'download',
    {
      'id': id,
      'chunkIndex': chunkIndex,
    },
  );

  _ida.Future<String> delete(int id) => caller.callServerEndpoint<String>(
    'attachment',
    'delete',
    {'id': id},
  );

  _ida.Future<String> restore(int id) => caller.callServerEndpoint<String>(
    'attachment',
    'restore',
    {'id': id},
  );
}

/// {@category Endpoint}
class EndpointAccount extends _isc.EndpointRef {
  EndpointAccount(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'account';

  _ida.Future<_iacc.AuthSuccess> changePassword(
    String currentPassword,
    String newPassword,
  ) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'account',
    'changePassword',
    {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    },
  );

  _ida.Future<void> deleteMember(int memberId) =>
      caller.callServerEndpoint<void>(
        'account',
        'deleteMember',
        {'memberId': memberId},
      );

  /// A one-time displayed temporary password; never written to the audit journal.
  _ida.Future<String> resetPassword(int memberId) =>
      caller.callServerEndpoint<String>(
        'account',
        'resetPassword',
        {'memberId': memberId},
      );
}

/// {@category Endpoint}
class EndpointJwtRefresh extends _iacc.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// If [refreshToken] is omitted, cookie-mode web clients fall back to the
  /// configured HttpOnly refresh cookie. When neither source is present this
  /// throws [RefreshTokenNotFoundException], the same public "no usable refresh
  /// credential" exception used for unknown refresh tokens.
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _ida.Future<_iacc.AuthSuccess> refreshAccessToken({String? refreshToken}) =>
      caller.callServerEndpoint<_iacc.AuthSuccess>(
        'jwtRefresh',
        'refreshAccessToken',
        {'refreshToken': refreshToken},
        authenticated: false,
      );
}

/// {@category Endpoint}
class EndpointLogin extends _isc.EndpointRef {
  EndpointLogin(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'login';

  _ida.Future<_iacc.AuthSuccess> login(
    String login,
    String password,
  ) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'login',
    'login',
    {
      'login': login,
      'password': password,
    },
  );

  _ida.Future<_iacc.AuthSuccess> register(
    String login,
    String password,
  ) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'login',
    'register',
    {
      'login': login,
      'password': password,
    },
  );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _isc.EndpointRef {
  EndpointGreeting(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _ida.Future<_ioqiwtc5.Greeting> hello(String name) =>
      caller.callServerEndpoint<_ioqiwtc5.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

/// {@category Endpoint}
class EndpointArchiveSync extends _isc.EndpointRef {
  EndpointArchiveSync(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'archiveSync';

  /// afterId=-1 reads a starting watermark BEFORE the initial snapshot.
  /// throughId pins each catch-up run, so concurrent imports cannot starve it.
  _ida.Future<String> changes(
    int afterId,
    int throughId,
  ) => caller.callServerEndpoint<String>(
    'archiveSync',
    'changes',
    {
      'afterId': afterId,
      'throughId': throughId,
    },
  );

  /// Bidirectional websocket: small liveness frames, no repeated archive reads.
  /// The lease also expires after an unclean disconnect/server crash.
  _ida.Stream<String> watch(_ida.Stream<int> heartbeat) =>
      caller.callStreamingServerEndpoint<_ida.Stream<String>, String>(
        'archiveSync',
        'watch',
        {},
        {'heartbeat': heartbeat},
      );
}

/// Keep these signatures backward-compatible: updates must work before login.
/// {@category Endpoint}
class EndpointUpdates extends _isc.EndpointRef {
  EndpointUpdates(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'updates';

  _ida.Future<String?> check() => caller.callServerEndpoint<String?>(
    'updates',
    'check',
    {},
  );

  _ida.Future<_idt.ByteData> download(
    String sha256,
    int offset,
  ) => caller.callServerEndpoint<_idt.ByteData>(
    'updates',
    'download',
    {
      'sha256': sha256,
      'offset': offset,
    },
  );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _iaic.Caller(client);
    serverpod_auth_core = _iacc.Caller(client);
  }

  late final _iaic.Caller serverpod_auth_idp;

  late final _iacc.Caller serverpod_auth_core;
}

class Client extends _isc.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _isc.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_isc.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i85jenna.Client? httpClientOverride,
  }) : super(
         host,
         _il2as5qe.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    archive = EndpointArchive(this);
    archiveMaintenance = EndpointArchiveMaintenance(this);
    attachment = EndpointAttachment(this);
    account = EndpointAccount(this);
    jwtRefresh = EndpointJwtRefresh(this);
    login = EndpointLogin(this);
    greeting = EndpointGreeting(this);
    archiveSync = EndpointArchiveSync(this);
    updates = EndpointUpdates(this);
    modules = Modules(this);
  }

  late final EndpointArchive archive;

  late final EndpointArchiveMaintenance archiveMaintenance;

  late final EndpointAttachment attachment;

  late final EndpointAccount account;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointLogin login;

  late final EndpointGreeting greeting;

  late final EndpointArchiveSync archiveSync;

  late final EndpointUpdates updates;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'archive': archive,
    'archiveMaintenance': archiveMaintenance,
    'attachment': attachment,
    'account': account,
    'jwtRefresh': jwtRefresh,
    'login': login,
    'greeting': greeting,
    'archiveSync': archiveSync,
    'updates': updates,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
