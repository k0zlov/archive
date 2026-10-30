import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'policy_store.dart';

UpdatePolicyStore createStore() => _Store();

class _Store implements UpdatePolicyStore {
  Future<void> _writing = Future.value();
  Future<File> _file(String server) async => File(
    '${(await getApplicationSupportDirectory()).path}/update-policies/${sha256.convert(utf8.encode(server))}.json',
  );
  @override
  Future<String?> read(String server) async {
    final file = await _file(server);
    return await file.exists() ? file.readAsString() : null;
  }

  @override
  Future<void> write(String server, String envelope) {
    return _writing = _writing.catchError((Object _) {}).then((_) async {
      final file = await _file(server);
      await file.parent.create(recursive: true);
      final pending = File('${file.path}.tmp');
      await pending.writeAsString(envelope, flush: true);
      await pending.rename(file.path);
    });
  }
}
