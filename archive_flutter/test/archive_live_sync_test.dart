import 'dart:async';
import 'package:archive_flutter/data/archive_live_sync.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'websocket hints trigger work, idle heartbeats do not poll, reconnect and stop release channels',
    (tester) async {
      final outputs = <StreamController<String>>[];
      var data = 0, presence = 0, disconnected = 0, beats = 0;
      Map<String, dynamic>? snapshot;
      String? requiredUpdate;
      late final ArchiveLiveSync live;
      live = ArchiveLiveSync(
        watch: (input) {
          input.listen((_) => beats++);
          final output = StreamController<String>();
          outputs.add(output);
          return output.stream;
        },
        onPresenceSnapshot: (value) => snapshot = value,
        onUpdateRequired: (raw) async {
          requiredUpdate = raw;
          live.stop();
        },
        onData: () => data++,
        onPresence: () => presence++,
        onDisconnected: () => disconnected++,
        onError: (_) async {},
      );
      live.start();
      outputs.last.add('ready');
      await tester.pump();
      expect(data, 1);
      await tester.pump(const Duration(seconds: 25));
      outputs.last.add('alive');
      await tester.pump();
      expect(beats, 1);
      expect(data, 1);
      outputs.last.add('data');
      outputs.last.add('presence');
      await tester.pump();
      expect(data, 2);
      expect(presence, 1);
      outputs.last.add('presence:{"user":{"online":true,"activeSessions":2}}');
      await tester.pump();
      expect(snapshot?['user']['activeSessions'], 2);
      expect(presence, 1);
      unawaited(outputs.last.close());
      await tester.pump();
      expect(disconnected, 1);
      await tester.pump(const Duration(seconds: 1));
      expect(outputs, hasLength(2));
      outputs.last.add('ready');
      await tester.pump();
      expect(data, 3);
      outputs.last.add('update-required:signed-envelope');
      await tester.pump();
      expect(requiredUpdate, 'signed-envelope');
      await tester.pump(const Duration(minutes: 10));
      expect(outputs, hasLength(2));
      expect(beats, 1);
    },
  );

  testWidgets('a silent broken connection times out and rejects late events', (
    tester,
  ) async {
    final outputs = <StreamController<String>>[];
    var data = 0, disconnected = 0;
    final live = ArchiveLiveSync(
      watch: (_) {
        final controller = StreamController<String>();
        outputs.add(controller);
        return controller.stream;
      },
      onData: () => data++,
      onPresence: () {},
      onDisconnected: () => disconnected++,
      onError: (_) async {},
    );
    live.start();
    await tester.pump(const Duration(seconds: 71));
    expect(disconnected, 1);
    outputs.first.add('data');
    await tester.pump();
    expect(data, 0);
    live.stop();
    await tester.pump();
  });
}
