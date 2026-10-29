import 'package:archive_flutter/data/archive_repository.dart';
import 'package:archive_flutter/ui/archive_controller.dart';
import 'package:archive_flutter/ui/record_dialogs.dart';
import 'package:archive_flutter/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'archive_repository_test.dart' show TestClient, MemoryStore;

void main() {
  testWidgets(
    'editor keeps a clamped independent scroll position and aligns the number on the left',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = ArchiveRepository(
        client: TestClient(),
        store: MemoryStore(),
        server: 'test',
        userId: 'one',
      );
      await repo.refresh();
      final controller = ArchiveController(repo);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: archiveTheme(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => editArchiveRecord(
                  context,
                  controller,
                  record: repo.records.single,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final number = find.byKey(const ValueKey('record-field-caseNumber'));
      final received = find.byKey(const ValueKey('record-field-receivedDate'));
      expect(
        tester.getTopLeft(number).dx,
        closeTo(tester.getTopLeft(received).dx, .5),
      );
      expect(find.textContaining('Номер справи обов’язковий:'), findsNothing);
      final scrollFinder = find.byKey(const ValueKey('record-editor-scroll'));
      final scroll = tester.widget<SingleChildScrollView>(scrollFinder);
      expect(scroll.primary, false);
      expect(scroll.physics, isA<ClampingScrollPhysics>());
      await tester.fling(scrollFinder, const Offset(0, -700), 2000);
      await tester.pumpAndSettle();
      await tester.fling(scrollFinder, const Offset(0, 3000), 5000);
      await tester.pumpAndSettle();
      expect(scroll.controller!.offset, closeTo(0, .01));
      final before = tester.getTopLeft(number);
      final task = repo.activity.begin('Оновлення локальної бази Drift');
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.getTopLeft(number), before);
      expect(scroll.controller!.offset, 0);
      repo.activity.end(task);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Скасувати'));
      await tester.pumpAndSettle();
    },
  );
}
