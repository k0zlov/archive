import 'package:web/web.dart' as web;
import 'cache_store.dart';

CacheStore createStore() => _WebStore();

class _WebStore implements CacheStore {
  @override
  Future<String?> read(String key) async =>
      web.window.localStorage.getItem('archive.$key');
  @override
  Future<void> write(String key, String value) async =>
      web.window.localStorage.setItem('archive.$key', value);
  @override
  Future<void> remove(String key) async =>
      web.window.localStorage.removeItem('archive.$key');
}
