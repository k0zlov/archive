import 'dart:async';
import 'package:archive_shared/windows_release.dart';
import 'package:flutter/foundation.dart';
import '../data/updates/update_platform.dart';
import '../data/updates/update_source.dart';
import '../data/updates/client_access.dart';

class WindowsUpdateController extends ChangeNotifier {
  WindowsUpdateController({
    required this.version,
    required this.build,
    required this.trustedKey,
    required this.source,
    required this.platform,
    ClientAccess? access,
  }) : access =
           access ??
           ClientAccess(
             platform: 'windows',
             build: build,
             trustedKey: trustedKey,
           ) {
    this.access.addListener(_accessChanged);
  }
  ClientAccess access;
  final String version, trustedKey;
  final int build;
  UpdateSource source;
  final UpdatePlatform platform;
  WindowsRelease? release;
  PreparedUpdate? prepared;
  String? error;
  bool checking = false, downloading = false, installing = false;
  bool checked = false;
  int percent = 0, _epoch = 0;
  bool _disposed = false;
  Future<void> Function()? _prepare;
  void Function()? _resume;
  bool get busy => checking || downloading || installing;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _accessChanged() {
    final next = access.policy;
    if (!checking &&
        next != null &&
        next.build > build &&
        next.sha256 != release?.sha256) {
      if (downloading) cancelDownload();
      final old = prepared;
      prepared = null;
      if (old != null) {
        unawaited(platform.discard(old).catchError((Object _) {}));
      }
      release = next;
    }
    _notify();
  }

  VoidCallback registerPreparation(
    Future<void> Function() prepare,
    void Function() resume,
  ) {
    _prepare = prepare;
    _resume = resume;
    return () {
      if (identical(_prepare, prepare)) {
        _prepare = null;
        _resume = null;
      }
    };
  }

  void reset(UpdateSource next, {ClientAccess? nextAccess}) {
    access.removeListener(_accessChanged);
    access =
        nextAccess ??
        ClientAccess(platform: 'windows', build: build, trustedKey: trustedKey);
    access.addListener(_accessChanged);
    _epoch++;
    source = next;
    final old = prepared;
    prepared = null;
    if (old != null) unawaited(platform.discard(old).catchError((Object _) {}));
    release = null;
    error = null;
    checked = false;
    checking = downloading = installing = false;
    _notify();
    unawaited(check());
  }

  Future<void> check() async {
    if (busy || _disposed) return;
    final epoch = ++_epoch, current = source;
    checking = true;
    error = null;
    _notify();
    try {
      final raw = await current.check().timeout(const Duration(seconds: 8));
      if (epoch != _epoch || _disposed) return;
      if (raw != null) {
        await access.accept(raw);
      } else {
        access.checkCompleted();
      }
      final next = access.policy;
      if (epoch != _epoch || _disposed) return;
      checked = true;
      final available = next != null && next.build > build ? next : null;
      if (available?.sha256 != release?.sha256) {
        final old = prepared;
        prepared = null;
        if (old != null) await platform.discard(old);
      }
      if (epoch != _epoch || _disposed) return;
      release = available;
    } catch (e) {
      if (epoch == _epoch && !_disposed) {
        access.checkFailed();
        error = e is FormatException
            ? e.message
            : 'Не вдалося перевірити оновлення. Спробуйте пізніше.';
      }
    } finally {
      if (epoch == _epoch && !_disposed) {
        checking = false;
        _notify();
      }
    }
  }

  void cancelDownload() {
    if (!downloading) return;
    _epoch++;
    downloading = false;
    percent = 0;
    _notify();
  }

  Future<void> download() async {
    final target = release;
    if (busy || target == null || _disposed || build < 1) return;
    final epoch = ++_epoch, current = source;
    downloading = true;
    percent = 0;
    error = null;
    _notify();
    try {
      final ready = await platform.download(
        target,
        (offset) => current.download(target.sha256, offset),
        cancelled: () => epoch != _epoch || _disposed,
        progress: (value) {
          if (epoch == _epoch && !_disposed) {
            percent = value;
            _notify();
          }
        },
      );
      if (epoch != _epoch || _disposed) {
        await platform.discard(ready);
        return;
      }
      prepared = ready;
    } catch (e) {
      if (epoch == _epoch && !_disposed && e is! UpdateCancelled) {
        error = e is UpdateFailure
            ? e.message
            : 'Не вдалося завантажити оновлення. Спробуйте ще раз.';
      }
    } finally {
      if (epoch == _epoch && !_disposed) {
        downloading = false;
        _notify();
      }
    }
  }

  Future<void> install() async {
    final file = prepared, target = release;
    if (busy || file == null || target == null || _disposed) return;
    final epoch = _epoch, resume = _resume;
    installing = true;
    error = null;
    _notify();
    try {
      await _prepare?.call();
      if (epoch != _epoch || _disposed) {
        resume?.call();
        return;
      }
      await platform.install(file, target);
    } catch (e) {
      resume?.call();
      if (epoch == _epoch && !_disposed) {
        error = e is UpdateFailure
            ? e.message
            : 'Не вдалося запустити встановлення. Спробуйте ще раз.';
      }
    } finally {
      if (epoch == _epoch && !_disposed) {
        installing = false;
        _notify();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _epoch++;
    final old = prepared;
    if (old != null) unawaited(platform.discard(old).catchError((Object _) {}));
    access.removeListener(_accessChanged);
    super.dispose();
  }
}
