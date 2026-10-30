import 'dart:async';
import 'package:archive_shared/windows_release.dart';
import 'package:flutter/foundation.dart';

class ClientOfflineException implements Exception {
  const ClientOfflineException();
  @override
  String toString() =>
      'Доступна лише локальна копія. Для роботи із сервером оновіть застосунок.';
}

/// Owned by one server connection. Changes never remove auth or archive caches.
class ClientAccess extends ChangeNotifier {
  ClientAccess({
    required this.platform,
    required this.build,
    this.trustedKey = '',
  }) : checked = platform != 'windows';
  final String platform, trustedKey;
  final int build;
  bool checked, offlineChosen = false, unavailable = false;
  WindowsRelease? policy;
  int _generation = 0;
  bool _disposed = false;
  Future<void> Function(String)? remember;
  bool get requiredUpdate =>
      platform == 'windows' && build < (policy?.minimumSupportedBuild ?? 1);
  bool get onlineAllowed => checked && !requiredUpdate && !unavailable;
  Future<void> accept(String envelope, {bool persist = true}) async {
    if (_disposed) return;
    final generation = _generation;
    final next = await verifyWindowsRelease(envelope, trustedKey);
    if (generation != _generation) return;
    if (policy != null &&
        (next.build < policy!.build ||
            next.minimumSupportedBuild < policy!.minimumSupportedBuild)) {
      // Verification completed, but retain the stronger cached requirement.
      checkCompleted();
      return;
    }
    policy = next;
    checked = true;
    unavailable = false;
    notifyListeners();
    if (persist) {
      try {
        await remember?.call(envelope);
      } catch (_) {}
    }
  }

  void checkCompleted() {
    if (_disposed) return;
    checked = true;
    unavailable = false;
    notifyListeners();
  }

  void checkFailed() {
    if (_disposed) return;
    checked = true;
    unavailable = true;
    notifyListeners();
  }

  void chooseOffline() {
    offlineChosen = true;
    notifyListeners();
  }

  void showChoice() {
    offlineChosen = false;
    notifyListeners();
  }

  void ensureOnline() {
    if (!onlineAllowed) throw const ClientOfflineException();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}
