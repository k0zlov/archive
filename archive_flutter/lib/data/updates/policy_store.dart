import 'policy_store_stub.dart'
    if (dart.library.io) 'policy_store_native.dart'
    as native;

abstract interface class UpdatePolicyStore {
  Future<String?> read(String server);
  Future<void> write(String server, String envelope);
}

UpdatePolicyStore createUpdatePolicyStore() => native.createStore();
