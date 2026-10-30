import 'app_settings_store_stub.dart'
    if (dart.library.io) 'app_settings_store_native.dart'
    if (dart.library.js_interop) 'app_settings_store_web.dart'
    as platform;

abstract interface class AppSettingsStore {
  Future<String?> readServerUrl();
  Future<void> writeServerUrl(String? value);
  Future<String?> readThemeMode();
  Future<void> writeThemeMode(String value);
}

AppSettingsStore createAppSettingsStore() => platform.createStore();

final appSettingsStore = createAppSettingsStore();
