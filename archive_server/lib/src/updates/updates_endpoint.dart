import 'dart:typed_data';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'windows_release_store.dart';
import 'windows_client_policy.dart';

/// Keep these signatures backward-compatible: updates must work before login.
class UpdatesEndpoint extends Endpoint {
  UpdatesEndpoint({WindowsReleaseStore? store})
    : _store = store ?? WindowsReleaseStore.configured(),
      _policy = store == null
          ? windowsClientPolicy
          : WindowsClientPolicy(
              store: store,
              publicKey: () =>
                  File('config/windows_update_public_key.txt').readAsString(),
            );
  final WindowsReleaseStore _store;
  final WindowsClientPolicy _policy;
  Future<String?> check(Session session) => _policy.check();
  Future<ByteData> download(Session session, String sha256, int offset) =>
      _store.chunk(sha256, offset);
}
