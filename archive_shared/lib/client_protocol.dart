/// Change only when the archive API contract changes incompatibly.
/// A server may advertise several protocols only while it implements them all.
const archiveClientProtocol = 1;
const archiveServerProtocols = <int>[1];

/// Stable bootstrap paths. Preserve v1 independently of the archive RPC API.
const archiveUpdateCheckPath = 'client-updates/v1/check';
const archiveUpdateDownloadPath = 'client-updates/v1/download';

class UpdateCompatibility {
  UpdateCompatibility({
    required this.protocols,
    this.manifest,
    this.policyManifests = const [],
  });
  final List<int> protocols;
  final String? manifest;
  final List<String> policyManifests;
  factory UpdateCompatibility.fromJson(Map<String, dynamic> json) {
    final protocols = json['protocols'];
    if (json['format'] != 1 ||
        protocols is! List ||
        protocols.isEmpty ||
        protocols.any((p) => p is! int || p < 1) ||
        (json['manifest'] != null && json['manifest'] is! String) ||
        (json['policies'] != null &&
            (json['policies'] is! List ||
                (json['policies'] as List).any((p) => p is! String)))) {
      throw const FormatException('Некоректна відповідь про сумісність.');
    }
    return UpdateCompatibility(
      protocols: protocols.cast<int>(),
      manifest: json['manifest'] as String?,
      policyManifests: (json['policies'] as List? ?? []).cast<String>(),
    );
  }
  Map<String, dynamic> toJson() => {
    'format': 1,
    'protocols': protocols,
    'manifest': manifest,
    'policies': policyManifests,
  };
}
