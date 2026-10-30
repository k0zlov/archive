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
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import '../archive/archive_endpoint.dart' as _ih245e2b;
import '../archive/archive_maintenance_endpoint.dart' as _i0qwimdn;
import '../archive/attachment_endpoint.dart' as _i6n3eiba;
import '../auth/account_endpoint.dart' as _ii6ycf6v;
import '../auth/jwt_refresh_endpoint.dart' as _inwq3ztq;
import '../auth/login_endpoint.dart' as _ibxz4c1d;
import '../greetings/greeting_endpoint.dart' as _il624ik7;
import '../sync/archive_sync_endpoint.dart' as _is00g55u;
import '../updates/updates_endpoint.dart' as _i6lltdln;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'archive': _ih245e2b.ArchiveEndpoint()
        ..initialize(
          server,
          'archive',
          null,
        ),
      'archiveMaintenance': _i0qwimdn.ArchiveMaintenanceEndpoint()
        ..initialize(
          server,
          'archiveMaintenance',
          null,
        ),
      'attachment': _i6n3eiba.AttachmentEndpoint()
        ..initialize(
          server,
          'attachment',
          null,
        ),
      'account': _ii6ycf6v.AccountEndpoint()
        ..initialize(
          server,
          'account',
          null,
        ),
      'jwtRefresh': _inwq3ztq.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'login': _ibxz4c1d.LoginEndpoint()
        ..initialize(
          server,
          'login',
          null,
        ),
      'greeting': _il624ik7.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
      'archiveSync': _is00g55u.ArchiveSyncEndpoint()
        ..initialize(
          server,
          'archiveSync',
          null,
        ),
      'updates': _i6lltdln.UpdatesEndpoint()
        ..initialize(
          server,
          'updates',
          null,
        ),
    };
    connectors['archive'] = _is.EndpointConnector(
      name: 'archive',
      endpoint: endpoints['archive']!,
      methodConnectors: {
        'profile': _is.MethodConnector(
          name: 'profile',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['archive'] as _ih245e2b.ArchiveEndpoint)
                  .profile(session),
        ),
        'records': _is.MethodConnector(
          name: 'records',
          params: {
            'afterId': _is.ParameterDescription(
              name: 'afterId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['archive'] as _ih245e2b.ArchiveEndpoint).records(
                    session,
                    params['afterId'],
                  ),
        ),
        'recordRevision': _is.MethodConnector(
          name: 'recordRevision',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['archive'] as _ih245e2b.ArchiveEndpoint)
                  .recordRevision(session),
        ),
        'saveRecord': _is.MethodConnector(
          name: 'saveRecord',
          params: {
            'module': _is.ParameterDescription(
              name: 'module',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'valuesJson': _is.ParameterDescription(
              name: 'valuesJson',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'version': _is.ParameterDescription(
              name: 'version',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['archive'] as _ih245e2b.ArchiveEndpoint)
                  .saveRecord(
                    session,
                    params['module'],
                    params['valuesJson'],
                    params['id'],
                    params['version'],
                  ),
        ),
        'importRecords': _is.MethodConnector(
          name: 'importRecords',
          params: {
            'module': _is.ParameterDescription(
              name: 'module',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'rows': _is.ParameterDescription(
              name: 'rows',
              type: _is.getType<List<String>>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['archive'] as _ih245e2b.ArchiveEndpoint)
                  .importRecords(
                    session,
                    params['module'],
                    params['rows'],
                  ),
        ),
        'beginImport': _is.MethodConnector(
          name: 'beginImport',
          params: {
            'module': _is.ParameterDescription(
              name: 'module',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'replaceExisting': _is.ParameterDescription(
              name: 'replaceExisting',
              type: _is.getType<bool>(),
              nullable: false,
            ),
            'sourceNames': _is.ParameterDescription(
              name: 'sourceNames',
              type: _is.getType<List<String>>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['archive'] as _ih245e2b.ArchiveEndpoint)
                  .beginImport(
                    session,
                    params['module'],
                    replaceExisting: params['replaceExisting'],
                    sourceNames: params['sourceNames'],
                  ),
        ),
        'appendImportRows': _is.MethodConnector(
          name: 'appendImportRows',
          params: {
            'jobId': _is.ParameterDescription(
              name: 'jobId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'rows': _is.ParameterDescription(
              name: 'rows',
              type: _is.getType<List<String>>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['archive'] as _ih245e2b.ArchiveEndpoint)
                  .appendImportRows(
                    session,
                    params['jobId'],
                    params['offset'],
                    params['rows'],
                  ),
        ),
        'commitImport': _is.MethodConnector(
          name: 'commitImport',
          params: {
            'jobId': _is.ParameterDescription(
              name: 'jobId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['archive'] as _ih245e2b.ArchiveEndpoint)
                  .commitImport(
                    session,
                    params['jobId'],
                  ),
        ),
        'cancelImport': _is.MethodConnector(
          name: 'cancelImport',
          params: {
            'jobId': _is.ParameterDescription(
              name: 'jobId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['archive'] as _ih245e2b.ArchiveEndpoint)
                  .cancelImport(
                    session,
                    params['jobId'],
                  ),
        ),
        'relatedRecords': _is.MethodConnector(
          name: 'relatedRecords',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['archive'] as _ih245e2b.ArchiveEndpoint)
                  .relatedRecords(
                    session,
                    params['id'],
                  ),
        ),
        'members': _is.MethodConnector(
          name: 'members',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['archive'] as _ih245e2b.ArchiveEndpoint)
                  .members(session),
        ),
        'setMemberAccess': _is.MethodConnector(
          name: 'setMemberAccess',
          params: {
            'memberId': _is.ParameterDescription(
              name: 'memberId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'role': _is.ParameterDescription(
              name: 'role',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'managementAccess': _is.ParameterDescription(
              name: 'managementAccess',
              type: _is.getType<bool>(),
              nullable: false,
            ),
            'courtAccess': _is.ParameterDescription(
              name: 'courtAccess',
              type: _is.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['archive'] as _ih245e2b.ArchiveEndpoint)
                  .setMemberAccess(
                    session,
                    params['memberId'],
                    params['role'],
                    params['managementAccess'],
                    params['courtAccess'],
                  ),
        ),
        'documents': _is.MethodConnector(
          name: 'documents',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['archive'] as _ih245e2b.ArchiveEndpoint)
                  .documents(session),
        ),
        'uploadDocument': _is.MethodConnector(
          name: 'uploadDocument',
          params: {
            'title': _is.ParameterDescription(
              name: 'title',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'fileName': _is.ParameterDescription(
              name: 'fileName',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'year': _is.ParameterDescription(
              name: 'year',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'contentBase64': _is.ParameterDescription(
              name: 'contentBase64',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['archive'] as _ih245e2b.ArchiveEndpoint)
                  .uploadDocument(
                    session,
                    params['title'],
                    params['fileName'],
                    params['year'],
                    params['contentBase64'],
                  ),
        ),
        'downloadDocument': _is.MethodConnector(
          name: 'downloadDocument',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['archive'] as _ih245e2b.ArchiveEndpoint)
                  .downloadDocument(
                    session,
                    params['id'],
                  ),
        ),
        'deleteRecord': _is.MethodConnector(
          name: 'deleteRecord',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'version': _is.ParameterDescription(
              name: 'version',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['archive'] as _ih245e2b.ArchiveEndpoint)
                  .deleteRecord(
                    session,
                    params['id'],
                    params['version'],
                  ),
        ),
        'restoreRecord': _is.MethodConnector(
          name: 'restoreRecord',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['archive'] as _ih245e2b.ArchiveEndpoint)
                  .restoreRecord(
                    session,
                    params['id'],
                  ),
        ),
        'deleteDocument': _is.MethodConnector(
          name: 'deleteDocument',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['archive'] as _ih245e2b.ArchiveEndpoint)
                  .deleteDocument(
                    session,
                    params['id'],
                  ),
        ),
        'restoreDocument': _is.MethodConnector(
          name: 'restoreDocument',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['archive'] as _ih245e2b.ArchiveEndpoint)
                  .restoreDocument(
                    session,
                    params['id'],
                  ),
        ),
        'auditEntries': _is.MethodConnector(
          name: 'auditEntries',
          params: {
            'beforeId': _is.ParameterDescription(
              name: 'beforeId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'query': _is.ParameterDescription(
              name: 'query',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['archive'] as _ih245e2b.ArchiveEndpoint)
                  .auditEntries(
                    session,
                    params['beforeId'],
                    params['query'],
                  ),
        ),
      },
    );
    connectors['archiveMaintenance'] = _is.EndpointConnector(
      name: 'archiveMaintenance',
      endpoint: endpoints['archiveMaintenance']!,
      methodConnectors: {
        'summary': _is.MethodConnector(
          name: 'summary',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['archiveMaintenance']
                          as _i0qwimdn.ArchiveMaintenanceEndpoint)
                      .summary(session),
        ),
        'clearRecords': _is.MethodConnector(
          name: 'clearRecords',
          params: {
            'confirmation': _is.ParameterDescription(
              name: 'confirmation',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['archiveMaintenance']
                          as _i0qwimdn.ArchiveMaintenanceEndpoint)
                      .clearRecords(
                        session,
                        params['confirmation'],
                      ),
        ),
        'clearArchive': _is.MethodConnector(
          name: 'clearArchive',
          params: {
            'confirmation': _is.ParameterDescription(
              name: 'confirmation',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['archiveMaintenance']
                          as _i0qwimdn.ArchiveMaintenanceEndpoint)
                      .clearArchive(
                        session,
                        params['confirmation'],
                      ),
        ),
      },
    );
    connectors['attachment'] = _is.EndpointConnector(
      name: 'attachment',
      endpoint: endpoints['attachment']!,
      methodConnectors: {
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'afterId': _is.ParameterDescription(
              name: 'afterId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['attachment'] as _i6n3eiba.AttachmentEndpoint)
                      .list(
                        session,
                        params['afterId'],
                      ),
        ),
        'begin': _is.MethodConnector(
          name: 'begin',
          params: {
            'recordId': _is.ParameterDescription(
              name: 'recordId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'fileName': _is.ParameterDescription(
              name: 'fileName',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'byteLength': _is.ParameterDescription(
              name: 'byteLength',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['attachment'] as _i6n3eiba.AttachmentEndpoint)
                      .begin(
                        session,
                        params['recordId'],
                        params['fileName'],
                        params['byteLength'],
                      ),
        ),
        'append': _is.MethodConnector(
          name: 'append',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'chunkIndex': _is.ParameterDescription(
              name: 'chunkIndex',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'content': _is.ParameterDescription(
              name: 'content',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['attachment'] as _i6n3eiba.AttachmentEndpoint)
                      .append(
                        session,
                        params['id'],
                        params['chunkIndex'],
                        params['content'],
                      ),
        ),
        'finish': _is.MethodConnector(
          name: 'finish',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['attachment'] as _i6n3eiba.AttachmentEndpoint)
                      .finish(
                        session,
                        params['id'],
                      ),
        ),
        'cancel': _is.MethodConnector(
          name: 'cancel',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['attachment'] as _i6n3eiba.AttachmentEndpoint)
                      .cancel(
                        session,
                        params['id'],
                      ),
        ),
        'download': _is.MethodConnector(
          name: 'download',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'chunkIndex': _is.ParameterDescription(
              name: 'chunkIndex',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['attachment'] as _i6n3eiba.AttachmentEndpoint)
                      .download(
                        session,
                        params['id'],
                        params['chunkIndex'],
                      ),
        ),
        'delete': _is.MethodConnector(
          name: 'delete',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['attachment'] as _i6n3eiba.AttachmentEndpoint)
                      .delete(
                        session,
                        params['id'],
                      ),
        ),
        'restore': _is.MethodConnector(
          name: 'restore',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['attachment'] as _i6n3eiba.AttachmentEndpoint)
                      .restore(
                        session,
                        params['id'],
                      ),
        ),
      },
    );
    connectors['account'] = _is.EndpointConnector(
      name: 'account',
      endpoint: endpoints['account']!,
      methodConnectors: {
        'changePassword': _is.MethodConnector(
          name: 'changePassword',
          params: {
            'currentPassword': _is.ParameterDescription(
              name: 'currentPassword',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'newPassword': _is.ParameterDescription(
              name: 'newPassword',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['account'] as _ii6ycf6v.AccountEndpoint)
                  .changePassword(
                    session,
                    params['currentPassword'],
                    params['newPassword'],
                  ),
        ),
        'deleteMember': _is.MethodConnector(
          name: 'deleteMember',
          params: {
            'memberId': _is.ParameterDescription(
              name: 'memberId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['account'] as _ii6ycf6v.AccountEndpoint)
                  .deleteMember(
                    session,
                    params['memberId'],
                  ),
        ),
        'resetPassword': _is.MethodConnector(
          name: 'resetPassword',
          params: {
            'memberId': _is.ParameterDescription(
              name: 'memberId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['account'] as _ii6ycf6v.AccountEndpoint)
                  .resetPassword(
                    session,
                    params['memberId'],
                  ),
        ),
      },
    );
    connectors['jwtRefresh'] = _is.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _is.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _is.ParameterDescription(
              name: 'refreshToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['jwtRefresh'] as _inwq3ztq.JwtRefreshEndpoint)
                      .refreshAccessToken(
                        session,
                        refreshToken: params['refreshToken'],
                      ),
        ),
      },
    );
    connectors['login'] = _is.EndpointConnector(
      name: 'login',
      endpoint: endpoints['login']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'login': _is.ParameterDescription(
              name: 'login',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['login'] as _ibxz4c1d.LoginEndpoint).login(
                session,
                params['login'],
                params['password'],
              ),
        ),
        'register': _is.MethodConnector(
          name: 'register',
          params: {
            'login': _is.ParameterDescription(
              name: 'login',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['login'] as _ibxz4c1d.LoginEndpoint).register(
                    session,
                    params['login'],
                    params['password'],
                  ),
        ),
      },
    );
    connectors['greeting'] = _is.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _is.MethodConnector(
          name: 'hello',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['greeting'] as _il624ik7.GreetingEndpoint).hello(
                    session,
                    params['name'],
                  ),
        ),
      },
    );
    connectors['archiveSync'] = _is.EndpointConnector(
      name: 'archiveSync',
      endpoint: endpoints['archiveSync']!,
      methodConnectors: {
        'changes': _is.MethodConnector(
          name: 'changes',
          params: {
            'afterId': _is.ParameterDescription(
              name: 'afterId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'throughId': _is.ParameterDescription(
              name: 'throughId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['archiveSync'] as _is00g55u.ArchiveSyncEndpoint)
                      .changes(
                        session,
                        params['afterId'],
                        params['throughId'],
                      ),
        ),
        'watch': _is.MethodStreamConnector(
          name: 'watch',
          params: {
            'clientPlatform': _is.ParameterDescription(
              name: 'clientPlatform',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'clientBuild': _is.ParameterDescription(
              name: 'clientBuild',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          streamParams: {
            'heartbeat': _is.StreamParameterDescription<int>(
              name: 'heartbeat',
              nullable: false,
            ),
          },
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['archiveSync'] as _is00g55u.ArchiveSyncEndpoint)
                  .watch(
                    session,
                    streamParams['heartbeat']!.cast<int>(),
                    clientPlatform: params['clientPlatform'],
                    clientBuild: params['clientBuild'],
                  ),
        ),
      },
    );
    connectors['updates'] = _is.EndpointConnector(
      name: 'updates',
      endpoint: endpoints['updates']!,
      methodConnectors: {
        'check': _is.MethodConnector(
          name: 'check',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['updates'] as _i6lltdln.UpdatesEndpoint)
                  .check(session),
        ),
        'download': _is.MethodConnector(
          name: 'download',
          params: {
            'sha256': _is.ParameterDescription(
              name: 'sha256',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['updates'] as _i6lltdln.UpdatesEndpoint).download(
                    session,
                    params['sha256'],
                    params['offset'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
  }
}
