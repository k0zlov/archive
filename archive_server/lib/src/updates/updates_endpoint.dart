import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';
import 'windows_release_store.dart';

/// Keep these signatures backward-compatible: updates must work before login.
class UpdatesEndpoint extends Endpoint {
  UpdatesEndpoint({WindowsReleaseStore? store})
    : _store = store ?? WindowsReleaseStore.configured();
  final WindowsReleaseStore _store;
  Future<String?> check(Session session) => _store.check();
  Future<ByteData> download(Session session, String sha256, int offset) =>
      _store.chunk(sha256, offset);
}
