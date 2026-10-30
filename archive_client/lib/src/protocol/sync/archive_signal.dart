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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class ArchiveSignal
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ArchiveSignal._({required this.kind});

  factory ArchiveSignal({required String kind}) = _ArchiveSignalImpl;

  factory ArchiveSignal.fromJson(Map<String, dynamic> jsonSerialization) {
    return ArchiveSignal(kind: jsonSerialization['kind'] as String);
  }

  String kind;

  /// Returns a shallow copy of this [ArchiveSignal]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ArchiveSignal copyWith({String? kind});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ArchiveSignal',
      'kind': kind,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ArchiveSignal',
      'kind': kind,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _ArchiveSignalImpl extends ArchiveSignal {
  _ArchiveSignalImpl({required String kind}) : super._(kind: kind);

  /// Returns a shallow copy of this [ArchiveSignal]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ArchiveSignal copyWith({String? kind}) {
    return ArchiveSignal(kind: kind ?? this.kind);
  }
}
