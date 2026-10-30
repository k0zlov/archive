import 'dart:async';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../server_connection.dart';
import '../../ui/windows_update_controller.dart';
import 'update_platform.dart';
import 'update_source.dart';
import 'archive_api_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

WindowsUpdateController? windowsUpdates;
Timer? _timer;

Future<void> initializeWindowsUpdates(ServerConnection connection) async {
  if (!supportsWindowsUpdates) return;
  try {
    final info = await PackageInfo.fromPlatform();
    final build = int.tryParse(info.buildNumber);
    if (build == null || build < 1) {
      if (connection.client is ArchiveApiClient) {
        (connection.client as ArchiveApiClient).access.checkFailed();
      }
      return;
    }
    final controller = WindowsUpdateController(
      version: info.version,
      build: build,
      access: connection.client is ArchiveApiClient
          ? (connection.client as ArchiveApiClient).access
          : null,
      trustedKey: await rootBundle.loadString(
        'assets/windows_update_public_key.txt',
      ),
      source: ServerpodUpdateSource(connection.client),
      platform: createUpdatePlatform(),
    );
    windowsUpdates = controller;
    connection.addListener(
      () => controller.reset(
        ServerpodUpdateSource(connection.client),
        nextAccess: connection.client is ArchiveApiClient
            ? (connection.client as ArchiveApiClient).access
            : null,
      ),
    );
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(hours: 6),
      (_) => controller.check(),
    );
    await controller.check();
    // Restore was local-only. Validate tokens only after compatibility passed.
    if (controller.access.onlineAllowed) {
      try {
        await connection.client.auth.initialize();
      } catch (_) {
        /* The access gate may change while validating auth. */
      }
    }
  } catch (_) {
    // A metadata/plugin failure must never prevent access to the archive.
    if (connection.client is ArchiveApiClient) {
      (connection.client as ArchiveApiClient).access.checkFailed();
    }
    windowsUpdates = null;
  }
}
