import 'policy_store.dart';

UpdatePolicyStore createStore() => _Store();

class _Store implements UpdatePolicyStore {
  final values = <String, String>{};
  @override
  Future<String?> read(String server) async => values[server];
  @override
  Future<void> write(String server, String envelope) async {
    values[server] = envelope;
  }
}
