import 'package:archive_flutter/data/archive_repository.dart';
import 'package:archive_shared/archive_shared.dart';
import 'package:archive_flutter/ui/archive_controller.dart';
import 'package:archive_flutter/ui/archive_shell.dart';
import 'package:archive_flutter/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'archive_repository_test.dart' show TestClient, MemoryStore;

void main() {
  Future<ArchiveController> mount(
    WidgetTester tester,
    Size size, {
    bool offline = false,
    bool empty = false,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = ArchiveRepository(
      client: TestClient(),
      store: MemoryStore(),
      server: 'test',
      userId: 'one',
    );
    await repo.refresh();
    if (empty) repo.records = [];
    repo.online = !offline;
    final controller = ArchiveController(repo);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: archiveTheme(),
        locale: const Locale('uk'),
        supportedLocales: const [Locale('uk')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: ArchiveShell(userId: 'one', controller: controller),
      ),
    );
    await tester.pumpAndSettle();
    return controller;
  }

  testWidgets('overview empty state fits without overflowing', (tester) async {
    await mount(tester, const Size(1280, 800), empty: true);
    await tester.scrollUntilVisible(
      find.text('Справ поки немає'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'offline records stay visible and both mutation buttons are disabled',
    (tester) async {
      await mount(tester, const Size(1280, 800), offline: true);
      await tester.tap(find.text('Судові справи').first);
      await tester.pumpAndSettle();
      expect(find.text('001/26'), findsOneWidget);
      final add = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Додати справу'),
      );
      final import = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Імпорт Excel'),
      );
      expect(add.onPressed, isNull);
      expect(import.onPressed, isNull);
      await tester.tap(find.text('001/26'));
      await tester.pumpAndSettle();
      expect(find.text('Редагувати'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'narrow windows can navigate with the drawer and open the editor',
    (tester) async {
      await mount(tester, const Size(390, 844));
      await tester.tap(find.byTooltip('Відкрити меню'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(Drawer),
          matching: find.text('Судові справи'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Додати справу'));
      await tester.pumpAndSettle();
      expect(find.text('Нова справа'), findsOneWidget);
      await tester.tap(find.text('Зберегти справу'));
      await tester.pumpAndSettle();
      expect(find.text('Заповніть поле «Справа №».'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Скасувати'));
      await tester.pumpAndSettle();
    },
  );
  testWidgets(
    'record list pages stay bounded and search finds cards on other pages',
    (tester) async {
      final c = await mount(tester, const Size(1280, 1000));
      c.repository.records = [
        for (var id = 1; id <= 123; id++)
          CaseRecord.fromJson({
            'id': id,
            'version': 1,
            'module': 'court',
            'updatedAt': '2026-10-29T10:00:00Z',
            'values': {
              'caseNumber': 'PAGE/$id',
              'participants': id == 1 ? 'Унікальна ціль' : 'Особа $id',
            },
          }),
      ];
      c.setModule(ArchiveModule.court);
      await tester.tap(find.text('Судові справи').first);
      await tester.pumpAndSettle();
      expect(c.recordsOnPage, hasLength(50));
      expect(find.text('1 / 3'), findsOneWidget);
      await tester.tap(find.byTooltip('Наступна сторінка'));
      await tester.pumpAndSettle();
      expect(c.pageIndex, 1);
      expect(c.recordsOnPage.first.id, 73);
      await tester.tap(find.byTooltip('Наступна сторінка'));
      await tester.pumpAndSettle();
      expect(c.recordsOnPage, hasLength(23));
      await tester.enterText(find.byType(TextField), 'Унікальна ціль');
      await tester.pumpAndSettle();
      expect(c.pageIndex, 0);
      expect(c.recordsOnPage.single.id, 1);
      expect(find.text('1 / 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
