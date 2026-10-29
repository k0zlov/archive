import 'package:archive_flutter/data/archive_activity.dart';
import 'package:archive_flutter/ui/archive_status_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'foreground operations take priority over background synchronization',
    () {
      final activity = ArchiveActivity();
      addTearDown(activity.dispose);
      final save = activity.begin('Збереження справи', priority: 10);
      final sync = activity.begin('Оновлення даних', priority: 1);
      expect(activity.current!.label, 'Збереження справи');
      activity.end(save);
      expect(activity.current!.label, 'Оновлення даних');
      activity.end(sync);
      expect(activity.current, isNull);
    },
  );
  testWidgets(
    'header status stays compact and never displays traffic or a progress bar',
    (tester) async {
      final activity = ArchiveActivity();
      addTearDown(activity.dispose);
      var builds = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (_) {
                builds++;
                return ArchiveStatusText(
                  activity: activity,
                  online: true,
                  updatedAt: DateTime(2026, 10, 29, 14, 25),
                );
              },
            ),
          ),
        ),
      );
      expect(find.text('Оновлено о 14:25'), findsOneWidget);
      final size = tester.getSize(find.byKey(const ValueKey('archive-status')));
      final task = activity.begin('Збереження справи на сервері', priority: 10);
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('Збереження справи…'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.textContaining('КіБ'), findsNothing);
      expect(find.textContaining('Мережа:'), findsNothing);
      expect(
        tester.getSize(find.byKey(const ValueKey('archive-status'))).height,
        size.height,
      );
      activity.end(task);
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('Оновлено о 14:25'), findsOneWidget);
      expect(builds, 1);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'a panel starting work during build safely updates the sibling header',
    (tester) async {
      final activity = ArchiveActivity();
      final open = ValueNotifier(false);
      addTearDown(activity.dispose);
      addTearDown(open.dispose);
      var started = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ArchiveStatusText(activity: activity, online: true),
                ValueListenableBuilder<bool>(
                  valueListenable: open,
                  builder: (_, visible, child) {
                    if (visible && !started) {
                      started = true;
                      activity.begin('Завантаження користувачів');
                    }
                    return const Text('Panel');
                  },
                ),
              ],
            ),
          ),
        ),
      );
      open.value = true;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('Завантаження…'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
