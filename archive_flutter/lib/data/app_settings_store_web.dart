import 'package:web/web.dart' as web;
import 'app_settings_store.dart';

AppSettingsStore createStore() => BrowserAppSettingsStore();

class BrowserAppSettingsStore implements AppSettingsStore {
  static const _key = 'archive.settings.serverUrl';
  static const _themeKey = 'archive.settings.themeMode';
  @override
  Future<String?> readThemeMode() async =>
      web.window.localStorage.getItem(_themeKey);
  @override
  Future<void> writeThemeMode(String value) async =>
      web.window.localStorage.setItem(_themeKey, value);
  @override
  Future<String?> readServerUrl() async =>
      web.window.localStorage.getItem(_key);
  @override
  Future<void> writeServerUrl(String? value) async {
    if (value == null) {
      web.window.localStorage.removeItem(_key);
    } else {
      web.window.localStorage.setItem(_key, value);
    }
  }
}
