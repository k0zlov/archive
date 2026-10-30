import 'package:archive_flutter/data/archive_repository.dart';
import 'package:archive_flutter/ui/archive_controller.dart';
import 'package:archive_flutter/ui/record_dialogs.dart';
import 'package:archive_flutter/ui/record_layout.dart';
import 'package:archive_flutter/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'archive_repository_test.dart';

void main() {
  Future<ArchiveController> open(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
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
    final record = CaseRecord.fromJson({
      'id': 1,
      'module': 'court',
      'version': 1,
      'updatedAt': '2026-10-29T10:00:00Z',
      'values': {
        'caseNumber': '243/6187/13-ц',
        'receivedDate': '2014-01-03',
        'category': 'Спори про виселення',
        'judge': 'Гусинський',
        'hearingDate': '2014-02-13',
        'hearingResult': 'Заяву задоволено частково',
        'effectiveDate': '2014-03-25',
        'notes': List.filled(50, 'Примітки до справи.').join(' '),
      },
    });
    repo.records = [record];
    await repo.attachments.cache.syncAttachments(repo.cacheKey, [
      for (var id = 1; id <= 30; id++)
        {
          'id': id,
          'recordId': 1,
          'module': 'court',
          'fileName': 'Документ $id.pdf',
          'byteLength': 10,
          'chunkCount': 1,
        },
    ]);
    final controller = ArchiveController(repo);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: archiveTheme(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showArchiveRecord(context, controller, record),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    return controller;
  }

  testWidgets(
    'desktop case keeps the original information layout and a subtle independently scrolling file pane',
    (tester) async {
      await open(tester, const Size(1280, 900));
      final information = find.byKey(const ValueKey('record-view-scroll'));
      final attachments = find.byKey(const ValueKey('record-attachments'));
      expect(
        tester.getTopLeft(attachments).dx,
        greaterThanOrEqualTo(tester.getTopRight(information).dx),
      );
      expect(
        tester.getSize(find.byType(RecordDialogBody)).width,
        lessThanOrEqualTo(1130),
      );
      final number = find.text('НОМЕРИ СПРАВИ');
      final info = find.text('ІНФОРМАЦІЯ ПРО СПРАВУ');
      expect(
        tester.getTopLeft(info).dy,
        greaterThan(tester.getBottomLeft(number).dy),
      );
      expect(
        tester.widget<Container>(attachments).color,
        const Color(0xFFEBEBE7),
      );
      expect(
        tester.widget<Text>(find.text('243/6187/13-ц').first).style?.fontSize,
        isNot(13),
      );
      final scroll = tester
          .widget<SingleChildScrollView>(information)
          .controller!;
      final before = scroll.offset;
      await tester.drag(
        find.byKey(const ValueKey('record-attachments-scroll')),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();
      expect(scroll.offset, before);
      expect(find.byType(TabBar), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Закрити'));
      await tester.pumpAndSettle();
    },
  );
  testWidgets('small desktop window stacks the file panel without overflows', (
    tester,
  ) async {
    await open(tester, const Size(700, 650));
    final information = find.byKey(const ValueKey('record-view-scroll'));
    final attachments = find.byKey(const ValueKey('record-attachments'));
    expect(
      tester.getTopLeft(attachments).dy,
      greaterThanOrEqualTo(tester.getBottomLeft(information).dy),
    );
    expect(find.text('Файли · 30'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Закрити'));
    await tester.pumpAndSettle();
  });
}
