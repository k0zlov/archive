import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'app_settings_store.dart';

AppSettingsStore createStore() => FileAppSettingsStore();

class FileAppSettingsStore implements AppSettingsStore {
  FileAppSettingsStore({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationSupportDirectory;
  final Future<Directory> Function() _directory;

  Future<File> _file() async =>
      File('${(await _directory()).path}/archive_settings.json');

  // A shared queue also keeps independent store instances from losing fields.
  static Future<void> _writes = Future.value();

  Future<Map<String, dynamic>> _read() async {
    final file = await _file();
    if (!await file.exists()) return {};
    return Map<String, dynamic>.from(
      jsonDecode(await file.readAsString()) as Map,
    );
  }

  Future<String?> _value(String key) async {
    await _writes.catchError((Object _) {});
    return (await _read())[key] as String?;
  }

  Future<void> _update(String key, String? value) {
    final next = _writes.catchError((Object _) {}).then((_) async {
      final settings = await _read();
      settings[key] = value;
      final file = await _file();
      await file.parent.create(recursive: true);
      final temporary = File('${file.path}.tmp');
      try {
        await temporary.writeAsString(jsonEncode(settings), flush: true);
        await temporary.rename(file.path);
      } finally {
        if (await temporary.exists()) await temporary.delete();
      }
    });
    _writes = next;
    return next;
  }

  @override
  Future<String?> readServerUrl() => _value('serverUrl');
  @override
  Future<void> writeServerUrl(String? value) => _update('serverUrl', value);
  @override
  Future<String?> readThemeMode() => _value('themeMode');
  @override
  Future<void> writeThemeMode(String value) => _update('themeMode', value);
}
