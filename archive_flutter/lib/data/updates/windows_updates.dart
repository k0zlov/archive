import 'dart:async';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../server_connection.dart';
import '../../ui/windows_update_controller.dart';
import 'update_platform.dart';
import 'update_source.dart';

WindowsUpdateController? windowsUpdates;
Timer? _timer;

Future<void> initializeWindowsUpdates(ServerConnection connection) async {
  if (!supportsWindowsUpdates) return;
  try {
    final info = await PackageInfo.fromPlatform();
    final build = int.tryParse(info.buildNumber);
    if (build == null || build < 1) {
      return; // Never guess a version and allow downgrades.
    }
    final controller = WindowsUpdateController(
      version: info.version,
      build: build,
      trustedKey: await rootBundle.loadString(
        'assets/windows_update_public_key.txt',
      ),
      source: ServerpodUpdateSource(connection.client),
      platform: createUpdatePlatform(),
    );
    windowsUpdates = controller;
    connection.addListener(
      () => controller.reset(ServerpodUpdateSource(connection.client)),
    );
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(hours: 6),
      (_) => controller.check(),
    );
    unawaited(controller.check());
  } catch (_) {
    // A metadata/plugin failure must never prevent access to the archive.
    windowsUpdates = null;
  }
}
