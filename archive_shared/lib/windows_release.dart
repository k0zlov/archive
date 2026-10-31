import 'dart:convert';
import 'package:cryptography/cryptography.dart';

const windowsUpdateChunkSize = 256 * 1024;
const windowsUpdateProduct = 'archive.windows';

/// Build numbers increase across all published versions, including fixes.
class WindowsRelease {
  WindowsRelease({
    required this.version,
    required this.build,
    required this.sha256,
    required this.size,
    this.notes = '',
    this.minimumSupportedBuild = 1,
    this.clientProtocol = 1,
  });
  final String version, sha256, notes;
  final int build, size, minimumSupportedBuild, clientProtocol;
  factory WindowsRelease.fromJson(Map<String, dynamic> json) {
    if (json['product'] != windowsUpdateProduct ||
        json['architecture'] != 'x64' ||
        json['version'] is! String ||
        !RegExp(r'^\d+\.\d+\.\d+$').hasMatch(json['version'] as String) ||
        json['build'] is! int ||
        (json['build'] as int) < 1 ||
        (json['clientProtocol'] != null &&
            (json['clientProtocol'] is! int ||
                (json['clientProtocol'] as int) < 1)) ||
        (json['minimumSupportedBuild'] != null &&
            (json['minimumSupportedBuild'] is! int ||
                (json['minimumSupportedBuild'] as int) < 1 ||
                (json['minimumSupportedBuild'] as int) >
                    (json['build'] as int))) ||
        json['size'] is! int ||
        (json['size'] as int) < 1 ||
        json['sha256'] is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(json['sha256'] as String) ||
        json['notes'] is! String ||
        (json['notes'] as String).length > 8000) {
      throw const FormatException('Некоректні дані оновлення.');
    }
    return WindowsRelease(
      version: json['version'] as String,
      build: json['build'] as int,
      size: json['size'] as int,
      sha256: json['sha256'] as String,
      notes: json['notes'] as String,
      minimumSupportedBuild: json['minimumSupportedBuild'] as int? ?? 1,
      clientProtocol: json['clientProtocol'] as int? ?? 1,
    );
  }
  Map<String, dynamic> toJson() => {
    'product': windowsUpdateProduct,
    'architecture': 'x64',
    'version': version,
    'build': build,
    'sha256': sha256,
    'size': size,
    'notes': notes,
    'minimumSupportedBuild': minimumSupportedBuild,
    'clientProtocol': clientProtocol,
  };
}

/// Sign exact payload bytes; whitespace or JSON key ordering is unambiguous.
Future<String> signWindowsRelease(
  WindowsRelease release,
  List<int> seed,
) async {
  WindowsRelease.fromJson(release.toJson());
  final algorithm = Ed25519();
  final pair = await algorithm.newKeyPairFromSeed(seed);
  final payload = utf8.encode(jsonEncode(release.toJson()));
  final signature = await algorithm.sign(payload, keyPair: pair);
  return jsonEncode({
    'format': 1,
    'payload': base64Encode(payload),
    'signature': base64Encode(signature.bytes),
  });
}

WindowsRelease decodeWindowsRelease(String envelope) {
  if (envelope.length > 32768)
    throw const FormatException('Завеликий опис оновлення.');
  final json = jsonDecode(envelope) as Map<String, dynamic>;
  if (json['format'] != 1)
    throw const FormatException('Невідомий формат оновлення.');
  return WindowsRelease.fromJson(
    jsonDecode(utf8.decode(base64Decode(json['payload'] as String)))
        as Map<String, dynamic>,
  );
}

Future<WindowsRelease> verifyWindowsRelease(
  String envelope,
  String trustedKey,
) async {
  try {
    if (envelope.length > 32768) throw const FormatException();
    final json = jsonDecode(envelope) as Map<String, dynamic>;
    if (json['format'] != 1) throw const FormatException();
    final key = base64Decode(trustedKey.trim());
    final signature = base64Decode(json['signature'] as String);
    if (key.length != 32 || signature.length != 64)
      throw const FormatException();
    final payload = base64Decode(json['payload'] as String);
    final valid = await Ed25519().verify(
      payload,
      signature: Signature(
        signature,
        publicKey: SimplePublicKey(key, type: KeyPairType.ed25519),
      ),
    );
    if (!valid) throw const FormatException();
    return decodeWindowsRelease(envelope);
  } catch (_) {
    throw const FormatException('Не вдалося перевірити підпис оновлення.');
  }
}
