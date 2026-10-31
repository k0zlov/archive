import 'dart:async';
import 'dart:convert';

/// One subscription per signed-in app, with bounded reconnect backoff. The stream
/// carries invalidation hints only; the repository owns durable reconciliation.
class ArchiveLiveSync {
  ArchiveLiveSync({
    required this.watch,
    required this.onData,
    required this.onPresence,
    required this.onDisconnected,
    required this.onError,
    this.beforeHeartbeat,
    this.onPresenceSnapshot,
    this.onAlive,
    this.onUpdateRequired,
    this.onCompatibility,
    this.heartbeatInterval = const Duration(seconds: 25),
    this.livenessTimeout = const Duration(seconds: 70),
  });
  final Stream<String> Function(Stream<int>) watch;
  final void Function() onData, onPresence, onDisconnected;
  final Future<void> Function(Object) onError;
  final Future<void> Function()? beforeHeartbeat;
  final void Function(Map<String, dynamic>)? onPresenceSnapshot;
  final void Function()? onAlive;
  final Future<void> Function(String)? onUpdateRequired;
  final Future<void> Function(String)? onCompatibility;
  final Duration heartbeatInterval, livenessTimeout;
  StreamSubscription<String>? _subscription;
  StreamController<int>? _input;
  Timer? _heartbeat, _deadline, _reconnect;
  bool _stopped = true, _sending = false;
  int _generation = 0, _attempt = 0, _beat = 0;

  void start() {
    if (!_stopped) return;
    _stopped = false;
    _connect();
  }

  void _connect() {
    if (_stopped) return;
    final generation = ++_generation;
    final input = _input = StreamController<int>();
    void armDeadline() {
      _deadline?.cancel();
      _deadline = Timer(livenessTimeout, () => _lost(generation));
    }

    try {
      _subscription = watch(input.stream).listen(
        (event) {
          if (_stopped || generation != _generation) return;
          armDeadline();
          if (event.startsWith('compatibility:')) {
            unawaited(
              onCompatibility
                  ?.call(event.substring(14))
                  .catchError((Object _) {}),
            );
            return;
          }
          if (event.startsWith('update-required:')) {
            unawaited(
              onUpdateRequired
                  ?.call(event.substring(16))
                  .catchError((Object _) {}),
            );
            return;
          }
          if (event.startsWith('presence:')) {
            try {
              onPresenceSnapshot?.call(
                Map<String, dynamic>.from(
                  jsonDecode(event.substring(9)) as Map,
                ),
              );
            } catch (_) {
              _lost(generation);
            }
            return;
          }
          switch (event) {
            case 'ready':
              _attempt = 0;
              onData();
            case 'data':
              onData();
            case 'presence':
              onPresence();
            case 'alive':
              onAlive?.call();
          }
        },
        onError: (Object error) {
          if (_stopped || generation != _generation) return;
          unawaited(onError(error).catchError((Object _) {}));
          _lost(generation);
        },
        onDone: () => _lost(generation),
      );
      armDeadline();
      _heartbeat = Timer.periodic(heartbeatInterval, (_) async {
        if (_stopped || generation != _generation || _sending) return;
        _sending = true;
        try {
          await beforeHeartbeat?.call();
          if (!_stopped && generation == _generation) input.add(++_beat);
        } catch (e) {
          if (!_stopped && generation == _generation) {
            unawaited(onError(e).catchError((Object _) {}));
            _lost(generation);
          }
        } finally {
          _sending = false;
        }
      });
    } catch (e) {
      unawaited(onError(e).catchError((Object _) {}));
      _lost(generation);
    }
  }

  void _lost(int generation) {
    if (_stopped || generation != _generation) return;
    _generation++;
    _closeChannel();
    onDisconnected();
    final seconds = 1 << _attempt.clamp(0, 5);
    _attempt++;
    _reconnect = Timer(
      Duration(seconds: seconds > 30 ? 30 : seconds),
      _connect,
    );
  }

  void _closeChannel() {
    _heartbeat?.cancel();
    _deadline?.cancel();
    unawaited(_subscription?.cancel());
    _subscription = null;
    unawaited(_input?.close());
    _input = null;
  }

  void stop() {
    _stopped = true;
    _generation++;
    _reconnect?.cancel();
    _closeChannel();
  }
}
