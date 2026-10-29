import 'dart:typed_data';
import 'package:archive_shared/archive_shared.dart';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:archive_flutter/data/archive_repository.dart';
import 'package:archive_flutter/data/workbook_service.dart';
import 'package:archive_flutter/ui/archive_controller.dart';
import 'package:archive_flutter/ui/import_dialog.dart';
import 'package:archive_flutter/ui/theme.dart';
import 'archive_repository_test.dart' show TestClient, MemoryStore;

void main() {
  testWidgets(
    'reverse mappings and multi-file validation update automatically with skip counters',
    (tester) async {
      tester.view.physicalSize = const Size(1500, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = ArchiveRepository(
        client: TestClient(),
        store: MemoryStore(),
        server: 'test',
        userId: 'one',
      );
      await repository.refresh();
      final controller = ArchiveController(repository);
      addTearDown(controller.dispose);
      final sheet = WorkbookSheet('Справи', {
        1: {
          0: const WorkbookCell('Справа №'),
          1: const WorkbookCell("{Учасник справи (всі).Справа}.Суб'єкт.Назва"),
          2: const WorkbookCell(
            "{Учасник справи (всі).Справа}.Тип учасника.Назва",
          ),
        },
        2: {
          0: const WorkbookCell('100'),
          1: const WorkbookCell('Олена'),
          2: const WorkbookCell('позивач'),
        },
        3: {1: const WorkbookCell('Без номера')},
      }, false);
      await tester.pumpWidget(
        MaterialApp(
          theme: archiveTheme(),
          home: Scaffold(
            body: ArchiveImportDialog(
              controller: controller,
              initialFiles: [
                ImportFileConfiguration('first.xlsx', [sheet]),
                ImportFileConfiguration('second.xlsx', [sheet]),
              ],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 600)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Поле картки'), findsNothing);
      expect(find.text('Перевірити та переглянути дані'), findsNothing);
      expect(find.byType(TabBar), findsNothing);
      expect(find.text('Номери справи'), findsOneWidget);
      expect(find.text('Інформація про справу'), findsOneWidget);
      expect(find.text('Учасники справи'), findsOneWidget);
      final participants = find.widgetWithText(
        ExpansionTile,
        'Учасники справи',
      );
      for (final label in [
        'Ім’я / назва учасника',
        'Роль учасника',
        'Номер провадження',
      ]) {
        expect(
          find.descendant(of: participants, matching: find.text(label)),
          findsOneWidget,
        );
      }
      expect(
        find.text('Файлів: 2'),
        findsOneWidget,
        reason: tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.data)
            .join(' | '),
      );
      expect(find.text('Без номера: 2'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Імпортувати'),
            )
            .onPressed,
        isNotNull,
      );
      final caseDropdown = find.byType(DropdownButtonFormField<int>).at(1);
      await tester.tap(caseDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Не обрано').last);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 600)),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Імпортувати'),
            )
            .onPressed,
        isNull,
      );
      expect(
        find.textContaining('Призначте колонку «Номер справи»'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'dropping multiple Excel files uses automatic mapping and date warnings do not block import',
    (tester) async {
      tester.view.physicalSize = const Size(1500, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = ArchiveRepository(
        client: TestClient(),
        store: MemoryStore(),
        server: 'test',
        userId: 'one',
      );
      await repository.refresh();
      final controller = ArchiveController(repository);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: archiveTheme(),
          home: Scaffold(body: ArchiveImportDialog(controller: controller)),
        ),
      );
      final service = WorkbookService();
      final target = tester.widget<DropTarget>(find.byType(DropTarget));
      target.onDragEntered!(
        DropEventDetails(
          localPosition: Offset.zero,
          globalPosition: Offset.zero,
        ),
      );
      await tester.pump();
      expect(find.text('Відпустіть файли Excel тут'), findsOneWidget);
      await tester.runAsync(() async {
        target.onDragDone!(
          DropDoneDetails(
            files: [
              DropItemFile.fromData(
                service.export(ArchiveModule.court, [
                  {
                    'caseNumber': 'DROP/001',
                    'receivedDate': '2026-10-10',
                    'hearingDate': '2026-01-01',
                  },
                ]),
                name: 'first.xlsx',
                path: 'first.xlsx',
              ),
              DropItemFile.fromData(
                service.export(ArchiveModule.court, [
                  {'caseNumber': 'DROP/001', 'category': 'Категорія'},
                ]),
                name: 'second.XLSX',
                path: 'second.XLSX',
              ),
              DropItemFile.fromData(
                Uint8List.fromList([1, 2, 3]),
                name: 'other.txt',
                path: 'other.txt',
              ),
            ],
            localPosition: Offset.zero,
            globalPosition: Offset.zero,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 800));
      });
      await tester.pump(const Duration(milliseconds: 300));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 600)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Відпустіть файли Excel тут'), findsNothing);
      expect(
        find.text('Файлів: 2'),
        findsOneWidget,
        reason: tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.data)
            .join(' | '),
      );
      expect(find.text('Нових справ: 1'), findsOneWidget);
      expect(find.text('Зауважень до дат: 1'), findsOneWidget);
      expect(find.text('Помилок: 0'), findsOneWidget);
      expect(
        find.textContaining('Пропущено файлів іншого формату: 1'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Імпортувати'),
            )
            .onPressed,
        isNotNull,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
