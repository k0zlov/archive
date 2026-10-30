/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'archive/archive_attachment.dart' as _iu3d2o8l;
import 'archive/archive_attachment_chunk.dart' as _ir59mhng;
import 'archive/archive_audit.dart' as _ioyse6ck;
import 'archive/archive_document.dart' as _ims8sj2t;
import 'archive/archive_import_job.dart' as _iahw0pji;
import 'archive/archive_import_row.dart' as _illufnju;
import 'archive/archive_member.dart' as _iimtnz49;
import 'archive/archive_record.dart' as _ifxelgw5;
import 'auth/archive_auth_exception.dart' as _iaeozbuv;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'sync/archive_presence.dart' as _ip0bunzc;
import 'sync/archive_signal.dart' as _i6zzyckt;
import 'sync/archive_sync_state.dart' as _iwwu4vqs;
export 'archive/archive_attachment.dart';
export 'archive/archive_attachment_chunk.dart';
export 'archive/archive_audit.dart';
export 'archive/archive_document.dart';
export 'archive/archive_import_job.dart';
export 'archive/archive_import_row.dart';
export 'archive/archive_member.dart';
export 'archive/archive_record.dart';
export 'auth/archive_auth_exception.dart';
export 'greetings/greeting.dart';
export 'sync/archive_presence.dart';
export 'sync/archive_signal.dart';
export 'sync/archive_sync_state.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'archive_attachment',
      dartName: 'ArchiveAttachment',
      schema: 'public',
      module: 'archive',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'recordId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'fileName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'byteLength',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'uploadedBytes',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'chunkCount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'uploading\'',
        ),
        _isp.ColumnDefinition(
          name: 'createdBy',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deletedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'deletedBy',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'archive_attachment_fk_0',
          columns: ['recordId'],
          referenceTable: 'archive_record',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'archive_attachment_record_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recordId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'status',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'deletedAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'archive_attachment_chunk',
      dartName: 'ArchiveAttachmentChunk',
      schema: 'public',
      module: 'archive',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'attachmentId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'chunkIndex',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'content',
          columnType: _isp.ColumnType.bytea,
          isNullable: false,
          dartType: 'dart:typed_data:ByteData',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'archive_attachment_chunk_fk_0',
          columns: ['attachmentId'],
          referenceTable: 'archive_attachment',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'archive_attachment_chunk_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'attachmentId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'chunkIndex',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'archive_audit',
      dartName: 'ArchiveAudit',
      schema: 'public',
      module: 'archive',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'actorId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'action',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'target',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'actorEmail',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'\'',
        ),
        _isp.ColumnDefinition(
          name: 'module',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'\'',
        ),
        _isp.ColumnDefinition(
          name: 'beforeJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'{}\'',
        ),
        _isp.ColumnDefinition(
          name: 'afterJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'{}\'',
        ),
        _isp.ColumnDefinition(
          name: 'detailsJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'{}\'',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'archive_document',
      dartName: 'ArchiveDocument',
      schema: 'public',
      module: 'archive',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'title',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'fileName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'year',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'content',
          columnType: _isp.ColumnType.bytea,
          isNullable: false,
          dartType: 'dart:typed_data:ByteData',
        ),
        _isp.ColumnDefinition(
          name: 'createdBy',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deletedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'deletedBy',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'archive_import_job',
      dartName: 'ArchiveImportJob',
      schema: 'public',
      module: 'archive',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'module',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'open\'',
        ),
        _isp.ColumnDefinition(
          name: 'receivedRows',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'skippedRows',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'lastOffset',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '-1',
        ),
        _isp.ColumnDefinition(
          name: 'lastBatchJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'\'',
        ),
        _isp.ColumnDefinition(
          name: 'replaceExisting',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'sourceNamesJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'[]\'',
        ),
        _isp.ColumnDefinition(
          name: 'resultJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'{}\'',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'archive_import_row',
      dartName: 'ArchiveImportRow',
      schema: 'public',
      module: 'archive',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'jobId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'identityKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'reference',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'proceeding',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'valuesJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'archive_import_row_fk_0',
          columns: ['jobId'],
          referenceTable: 'archive_import_job',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'archive_import_row_identity_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'jobId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'identityKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'archive_member',
      dartName: 'ArchiveMember',
      schema: 'public',
      module: 'archive',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'email',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'login',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'passwordChangeRequired',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'displayName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'role',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'pending\'',
        ),
        _isp.ColumnDefinition(
          name: 'managementAccess',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'courtAccess',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'archive_member_user_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'archive_member_login_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'login',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'archive_presence',
      dartName: 'ArchivePresence',
      schema: 'public',
      module: 'archive',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'authId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'archive_presence_user_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'archive_presence_expiry_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'expiresAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'archive_record',
      dartName: 'ArchiveRecord',
      schema: 'public',
      module: 'archive',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'module',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'identityKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'reference',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'proceeding',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'valuesJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'createdBy',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'updatedBy',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deletedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'deletedBy',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'archive_record_identity_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'identityKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'archive_record_module_active_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'module',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'deletedAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'archive_sync_state',
      dartName: 'ArchiveSyncState',
      schema: 'public',
      module: 'archive',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'resetCursor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    ..._iais.Protocol.targetTableDefinitions,
    ..._iacs.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _iu3d2o8l.ArchiveAttachment) {
      return _iu3d2o8l.ArchiveAttachment.fromJson(data) as T;
    }
    if (t == _ir59mhng.ArchiveAttachmentChunk) {
      return _ir59mhng.ArchiveAttachmentChunk.fromJson(data) as T;
    }
    if (t == _ioyse6ck.ArchiveAudit) {
      return _ioyse6ck.ArchiveAudit.fromJson(data) as T;
    }
    if (t == _ims8sj2t.ArchiveDocument) {
      return _ims8sj2t.ArchiveDocument.fromJson(data) as T;
    }
    if (t == _iahw0pji.ArchiveImportJob) {
      return _iahw0pji.ArchiveImportJob.fromJson(data) as T;
    }
    if (t == _illufnju.ArchiveImportRow) {
      return _illufnju.ArchiveImportRow.fromJson(data) as T;
    }
    if (t == _iimtnz49.ArchiveMember) {
      return _iimtnz49.ArchiveMember.fromJson(data) as T;
    }
    if (t == _ifxelgw5.ArchiveRecord) {
      return _ifxelgw5.ArchiveRecord.fromJson(data) as T;
    }
    if (t == _iaeozbuv.ArchiveAuthException) {
      return _iaeozbuv.ArchiveAuthException.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _ip0bunzc.ArchivePresence) {
      return _ip0bunzc.ArchivePresence.fromJson(data) as T;
    }
    if (t == _i6zzyckt.ArchiveSignal) {
      return _i6zzyckt.ArchiveSignal.fromJson(data) as T;
    }
    if (t == _iwwu4vqs.ArchiveSyncState) {
      return _iwwu4vqs.ArchiveSyncState.fromJson(data) as T;
    }
    if (t == _is.getType<_iu3d2o8l.ArchiveAttachment?>()) {
      return (data != null ? _iu3d2o8l.ArchiveAttachment.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ir59mhng.ArchiveAttachmentChunk?>()) {
      return (data != null
              ? _ir59mhng.ArchiveAttachmentChunk.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ioyse6ck.ArchiveAudit?>()) {
      return (data != null ? _ioyse6ck.ArchiveAudit.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ims8sj2t.ArchiveDocument?>()) {
      return (data != null ? _ims8sj2t.ArchiveDocument.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iahw0pji.ArchiveImportJob?>()) {
      return (data != null ? _iahw0pji.ArchiveImportJob.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_illufnju.ArchiveImportRow?>()) {
      return (data != null ? _illufnju.ArchiveImportRow.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iimtnz49.ArchiveMember?>()) {
      return (data != null ? _iimtnz49.ArchiveMember.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ifxelgw5.ArchiveRecord?>()) {
      return (data != null ? _ifxelgw5.ArchiveRecord.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iaeozbuv.ArchiveAuthException?>()) {
      return (data != null
              ? _iaeozbuv.ArchiveAuthException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ip0bunzc.ArchivePresence?>()) {
      return (data != null ? _ip0bunzc.ArchivePresence.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i6zzyckt.ArchiveSignal?>()) {
      return (data != null ? _i6zzyckt.ArchiveSignal.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iwwu4vqs.ArchiveSyncState?>()) {
      return (data != null ? _iwwu4vqs.ArchiveSyncState.fromJson(data) : null)
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _iu3d2o8l.ArchiveAttachment => 'ArchiveAttachment',
      _ir59mhng.ArchiveAttachmentChunk => 'ArchiveAttachmentChunk',
      _ioyse6ck.ArchiveAudit => 'ArchiveAudit',
      _ims8sj2t.ArchiveDocument => 'ArchiveDocument',
      _iahw0pji.ArchiveImportJob => 'ArchiveImportJob',
      _illufnju.ArchiveImportRow => 'ArchiveImportRow',
      _iimtnz49.ArchiveMember => 'ArchiveMember',
      _ifxelgw5.ArchiveRecord => 'ArchiveRecord',
      _iaeozbuv.ArchiveAuthException => 'ArchiveAuthException',
      _izw8z7ou.Greeting => 'Greeting',
      _ip0bunzc.ArchivePresence => 'ArchivePresence',
      _i6zzyckt.ArchiveSignal => 'ArchiveSignal',
      _iwwu4vqs.ArchiveSyncState => 'ArchiveSyncState',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('archive.', '');
    }

    switch (data) {
      case _iu3d2o8l.ArchiveAttachment():
        return 'ArchiveAttachment';
      case _ir59mhng.ArchiveAttachmentChunk():
        return 'ArchiveAttachmentChunk';
      case _ioyse6ck.ArchiveAudit():
        return 'ArchiveAudit';
      case _ims8sj2t.ArchiveDocument():
        return 'ArchiveDocument';
      case _iahw0pji.ArchiveImportJob():
        return 'ArchiveImportJob';
      case _illufnju.ArchiveImportRow():
        return 'ArchiveImportRow';
      case _iimtnz49.ArchiveMember():
        return 'ArchiveMember';
      case _ifxelgw5.ArchiveRecord():
        return 'ArchiveRecord';
      case _iaeozbuv.ArchiveAuthException():
        return 'ArchiveAuthException';
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _ip0bunzc.ArchivePresence():
        return 'ArchivePresence';
      case _i6zzyckt.ArchiveSignal():
        return 'ArchiveSignal';
      case _iwwu4vqs.ArchiveSyncState():
        return 'ArchiveSyncState';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'ArchiveAttachment') {
      return deserialize<_iu3d2o8l.ArchiveAttachment>(data['data']);
    }
    if (dataClassName == 'ArchiveAttachmentChunk') {
      return deserialize<_ir59mhng.ArchiveAttachmentChunk>(data['data']);
    }
    if (dataClassName == 'ArchiveAudit') {
      return deserialize<_ioyse6ck.ArchiveAudit>(data['data']);
    }
    if (dataClassName == 'ArchiveDocument') {
      return deserialize<_ims8sj2t.ArchiveDocument>(data['data']);
    }
    if (dataClassName == 'ArchiveImportJob') {
      return deserialize<_iahw0pji.ArchiveImportJob>(data['data']);
    }
    if (dataClassName == 'ArchiveImportRow') {
      return deserialize<_illufnju.ArchiveImportRow>(data['data']);
    }
    if (dataClassName == 'ArchiveMember') {
      return deserialize<_iimtnz49.ArchiveMember>(data['data']);
    }
    if (dataClassName == 'ArchiveRecord') {
      return deserialize<_ifxelgw5.ArchiveRecord>(data['data']);
    }
    if (dataClassName == 'ArchiveAuthException') {
      return deserialize<_iaeozbuv.ArchiveAuthException>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'ArchivePresence') {
      return deserialize<_ip0bunzc.ArchivePresence>(data['data']);
    }
    if (dataClassName == 'ArchiveSignal') {
      return deserialize<_i6zzyckt.ArchiveSignal>(data['data']);
    }
    if (dataClassName == 'ArchiveSyncState') {
      return deserialize<_iwwu4vqs.ArchiveSyncState>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iais.Protocol().registerHostProtocol('archive', this);
    _iacs.Protocol().registerHostProtocol('archive', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _iu3d2o8l.ArchiveAttachment:
        return _iu3d2o8l.ArchiveAttachment.t;
      case _ir59mhng.ArchiveAttachmentChunk:
        return _ir59mhng.ArchiveAttachmentChunk.t;
      case _ioyse6ck.ArchiveAudit:
        return _ioyse6ck.ArchiveAudit.t;
      case _ims8sj2t.ArchiveDocument:
        return _ims8sj2t.ArchiveDocument.t;
      case _iahw0pji.ArchiveImportJob:
        return _iahw0pji.ArchiveImportJob.t;
      case _illufnju.ArchiveImportRow:
        return _illufnju.ArchiveImportRow.t;
      case _iimtnz49.ArchiveMember:
        return _iimtnz49.ArchiveMember.t;
      case _ifxelgw5.ArchiveRecord:
        return _ifxelgw5.ArchiveRecord.t;
      case _ip0bunzc.ArchivePresence:
        return _ip0bunzc.ArchivePresence.t;
      case _iwwu4vqs.ArchiveSyncState:
        return _iwwu4vqs.ArchiveSyncState.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'archive';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
