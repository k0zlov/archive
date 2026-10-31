import 'dart:convert';
import 'package:archive_shared/windows_release.dart';
import 'package:archive_shared/client_protocol.dart';
import 'package:flutter/foundation.dart';

class ClientOfflineException implements Exception {
  const ClientOfflineException();
  @override
  String toString() =>
      'Доступна лише локальна копія. Перевірте сумісність і оновлення застосунку.';
}

/// Owned by one server connection. Never removes auth or archive caches.
class ClientAccess extends ChangeNotifier {
  ClientAccess({
    required this.platform,
    required this.build,
    this.trustedKey = '',
    this.protocol = archiveClientProtocol,
  }) : checked = platform != 'windows';
  final String platform, trustedKey;
  final int build, protocol;
  bool checked, offlineChosen = false, unavailable = false;
  List<int>? serverProtocols;
  final _policies = <int, WindowsRelease>{};
  final _envelopes = <int, String>{};
  WindowsRelease? _selected;
  int _generation = 0;
  bool _disposed = false;
  Future<void> Function(String)? remember;
  bool canOffer(WindowsRelease release) =>
      (serverProtocols ?? [1]).contains(release.clientProtocol);
  WindowsRelease? get policy {
    if (_selected != null && canOffer(_selected!)) return _selected;
    WindowsRelease? latest;
    for (final release in _policies.values) {
      if (canOffer(release) &&
          (latest == null || release.build > latest.build)) {
        latest = release;
      }
    }
    return latest;
  }

  bool get protocolBlocked => !(serverProtocols ?? [1]).contains(protocol);
  bool get serverUpgradeRequired =>
      protocolBlocked &&
      (serverProtocols ?? [1]).every((p) => p < protocol) &&
      (policy == null || policy!.build <= build);
  bool get requiredUpdate {
    final selectedMinimum = policy?.minimumSupportedBuild ?? 1;
    final ownMinimum = _policies[protocol]?.minimumSupportedBuild ?? 1;
    return platform == 'windows' &&
        build < (ownMinimum > selectedMinimum ? ownMinimum : selectedMinimum);
  }

  bool get blocked => requiredUpdate || protocolBlocked;
  bool get onlineAllowed => checked && !blocked && !unavailable;

  Future<void> restorePolicy(String stored) async {
    final json = jsonDecode(stored) as Map;
    if (json['format'] != 2) return accept(stored, persist: false);
    for (final raw in (json['policies'] as List).cast<String>()) {
      await accept(raw, persist: false);
    }
  }

  Future<void> acceptCompatibility(UpdateCompatibility info) async {
    if (_disposed) return;
    final generation = _generation;
    final verified = <({WindowsRelease release, String raw})>[];
    for (final raw in [
      ...info.policyManifests,
      if (info.manifest != null) info.manifest!,
    ]) {
      final release = await verifyWindowsRelease(raw, trustedKey);
      if (!info.protocols.contains(release.clientProtocol)) {
        throw const FormatException('Сервер запропонував несумісне оновлення.');
      }
      verified.add((release: release, raw: raw));
    }
    if (_disposed || generation != _generation) return;
    serverProtocols = List.unmodifiable(info.protocols);
    for (final candidate in verified) {
      _adopt(candidate.release, candidate.raw);
    }
    if (info.manifest == null) _selected = null;
    checkCompleted();
    await _persistPolicies();
  }

  void _adopt(WindowsRelease next, String envelope) {
    final previous = _policies[next.clientProtocol];
    if (previous != null &&
        (next.build < previous.build ||
            next.minimumSupportedBuild < previous.minimumSupportedBuild ||
            (next.build == previous.build && next.sha256 != previous.sha256))) {
      _selected = previous;
      return;
    }
    _policies[next.clientProtocol] = next;
    _envelopes[next.clientProtocol] = envelope;
    _selected = next;
  }

  Future<void> _persistPolicies() async {
    try {
      await remember?.call(
        jsonEncode({'format': 2, 'policies': _envelopes.values.toList()}),
      );
    } catch (_) {}
  }

  Future<void> accept(String envelope, {bool persist = true}) async {
    if (_disposed) return;
    final generation = _generation;
    final next = await verifyWindowsRelease(envelope, trustedKey);
    if (generation != _generation) return;
    _adopt(next, envelope);
    checkCompleted();
    if (persist) await _persistPolicies();
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
