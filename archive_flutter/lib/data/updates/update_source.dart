import 'dart:typed_data';
import 'package:archive_client/archive_client.dart';

abstract interface class UpdateSource {
  Future<String?> check();
  Future<ByteData> download(String hash, int offset);
}

/// Unauthenticated calls intentionally carry no account tokens.
class ServerpodUpdateSource implements UpdateSource {
  ServerpodUpdateSource(this.client);
  final Client client;
  @override
  Future<String?> check() => client.callServerEndpoint<String?>(
    'updates',
    'check',
    {},
    authenticated: false,
  );
  @override
  Future<ByteData> download(String hash, int offset) =>
      client.callServerEndpoint<ByteData>('updates', 'download', {
        'sha256': hash,
        'offset': offset,
      }, authenticated: false);
}
