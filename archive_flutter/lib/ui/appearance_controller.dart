import 'package:flutter/material.dart';
import '../data/app_settings_store.dart';

final appearanceController = AppearanceController(appSettingsStore);

class AppearanceController extends ChangeNotifier {
  AppearanceController(this.store);
  final AppSettingsStore store;
  ThemeMode mode = ThemeMode.system;

  Future<void> initialize() async {
    final saved = await store.readThemeMode();
    mode = ThemeMode.values.firstWhere(
      (value) => value.name == saved,
      orElse: () => ThemeMode.system,
    );
    notifyListeners();
  }

  Future<void> setMode(ThemeMode value) async {
    if (mode == value) return;
    await store.writeThemeMode(value.name);
    mode = value;
    notifyListeners();
  }
}
