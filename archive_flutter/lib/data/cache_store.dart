import 'cache_store_stub.dart'
    if (dart.library.io) 'cache_store_native.dart'
    if (dart.library.js_interop) 'cache_store_web.dart'
    as platform;

abstract interface class CacheStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> remove(String key);
}

CacheStore createCacheStore() => platform.createStore();
