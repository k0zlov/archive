import 'package:archive_flutter/data/archive_repository.dart';
import 'package:archive_flutter/data/workbook_service.dart';
import 'package:archive_flutter/ui/archive_controller.dart';
import 'package:archive_flutter/ui/archive_shell.dart';
import 'package:archive_flutter/ui/auth_screen.dart';
import 'package:archive_flutter/ui/import_dialog.dart';
import 'package:archive_flutter/ui/theme.dart';
import 'package:archive_flutter/ui/record_dialogs.dart';
import 'package:archive_flutter/ui/server_settings_dialog.dart';
import 'package:archive_shared/archive_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'archive_repository_test.dart' show TestClient, MemoryStore;
import 'appearance_test.dart' show contrast;

/// Inspect resolved text colors against the actual ancestor surfaces, including
/// custom card/participant/file backgrounds rather than just the global theme.
void expectReadableText(WidgetTester tester) {
  var checked = 0;
  for (final element in tester.elementList(find.byType(RichText))) {
    final rich = element.widget as RichText;
    final foreground = rich.text.style?.color;
    if (foreground == null ||
        foreground.a < .8 ||
        rich.text.toPlainText().trim().isEmpty) {
      continue;
    }
    var enabled = true;
    final backgrounds = <Color>[];
    element.visitAncestorElements((ancestor) {
      final widget = ancestor.widget;
      if (widget is ButtonStyleButton && widget.onPressed == null) {
        enabled = false;
      }
      if (widget is Opacity && widget.opacity < 1) enabled = false;
      if (widget is ColoredBox) backgrounds.add(widget.color);
      if (widget is DecoratedBox && widget.decoration is BoxDecoration) {
        final color = (widget.decoration as BoxDecoration).color;
        if (color != null) backgrounds.add(color);
      }
      if (widget is RawChip) {
        final color = widget.backgroundColor;
        if (color != null) backgrounds.add(color);
      }
      if (widget is Material && widget.type != MaterialType.transparency) {
        backgrounds.add(widget.color ?? Theme.of(ancestor).colorScheme.surface);
      }
      return true;
    });
    if (!enabled) continue;
    var background = Theme.of(element).scaffoldBackgroundColor;
    for (final color in backgrounds.reversed) {
      background = Color.alphaBlend(color, background);
    }
    expect(
      contrast(Color.alphaBlend(foreground, background), background),
      greaterThanOrEqualTo(4.5),
      reason:
          'Unreadable "${rich.text.toPlainText()}": $foreground on $background',
    );
    checked++;
  }
  expect(checked, greaterThan(0));
  expect(tester.takeException(), isNull);
}

Widget themed(Brightness brightness, Widget home) => MaterialApp(
  theme: archiveTheme(brightness: brightness),
  locale: const Locale('uk'),
  supportedLocales: const [Locale('uk')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  home: home,
);

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      '$brightness archive, record, participants, files, documents, audit and admin text stays readable',
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
        repository.profile = {
          'userId': 'one',
          'role': 'admin',
          'login': 'admin',
        };
        repository.records = [
          CaseRecord.fromJson({
            'id': 1,
            'version': 1,
            'module': 'court',
            'updatedAt': '2026-10-30T10:00:00Z',
            'values': {
              'caseNumber': '001/26',
              'category': 'Цивільна справа',
              ...participantValues([
                const CaseParticipant(
                  'Олена',
                  role: 'Позивач',
                  proceeding: '2/001/26',
                ),
              ]),
            },
          }),
        ];
        repository.documents = [
          {
            'id': 1,
            'title': 'Номенклатура 2026',
            'year': 2026,
            'fileName': 'Перелік.docx',
          },
        ];
        repository.members = [
          {'id': 1, 'userId': 'one', 'login': 'admin', 'role': 'admin'},
        ];
        repository.audit = [
          {
            'id': 1,
            'action': 'record.update',
            'actor': 'admin',
            'at': '2026-10-30T10:00:00Z',
            'target': 'court:1',
            'before': {
              'values': {
                'caseNumber': '001/26',
                'category': 'Попередня категорія',
              },
            },
            'after': {
              'values': {'caseNumber': '001/26', 'category': 'Цивільна справа'},
            },
          },
        ];
        await repository.attachments.cache.syncAttachments(
          repository.cacheKey,
          [
            {
              'id': 1,
              'recordId': 1,
              'module': 'court',
              'fileName': 'Матеріали справи.pdf',
              'byteLength': 20,
              'chunkCount': 1,
            },
          ],
        );
        repository.online = false;
        repository.notice = 'Сервер недоступний. Доступна локальна копія.';
        final controller = ArchiveController(repository);
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          themed(
            brightness,
            ArchiveShell(userId: 'one', controller: controller),
          ),
        );
        await tester.pumpAndSettle();
        expectReadableText(tester);
        await tester.tap(find.text('Судові справи').first);
        await tester.pumpAndSettle();
        expectReadableText(tester);
        await tester.tap(find.text('001/26'));
        await tester.pumpAndSettle();
        expect(find.text('Олена'), findsWidgets);
        expect(find.text('Матеріали справи.pdf'), findsOneWidget);
        expectReadableText(tester);
        await tester.tap(find.byTooltip('Закрити'));
        await tester.pumpAndSettle();
        for (final page in [
          'Номенклатура',
          'Описи справ',
          'Користувачі та доступ',
          'Журнал аудиту',
        ]) {
          await tester.tap(find.text(page).first);
          await tester.pumpAndSettle();
          expectReadableText(tester);
        }
        await tester.tap(find.textContaining('Редагування справи ·'));
        await tester.pumpAndSettle();
        expect(find.text('До'), findsOneWidget);
        expectReadableText(tester);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets(
      '$brightness import validation, counters and mapped fields stay readable',
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
            1: const WorkbookCell('Дата надходження позовної заяви (справи)'),
          },
          2: {
            0: const WorkbookCell('001/26'),
            1: const WorkbookCell('31.02.2026'),
          },
        }, false);
        await tester.pumpWidget(
          themed(
            brightness,
            Scaffold(
              body: ArchiveImportDialog(
                controller: controller,
                initialFiles: [
                  ImportFileConfiguration('Справи.xlsx', [sheet]),
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
        expect(find.text('Справи.xlsx'), findsWidgets);
        expectReadableText(tester);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets(
      '$brightness editor errors, settings and theme menu stay readable',
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
          themed(
            brightness,
            Scaffold(
              body: Builder(
                builder: (context) => Column(
                  children: [
                    TextButton(
                      onPressed: () => editArchiveRecord(context, controller),
                      child: const Text('Editor'),
                    ),
                    TextButton(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => ServerSettingsDialog(
                          initialUrl: 'http://localhost:8080',
                          onSave: (_, _) async {
                            throw StateError('write failed');
                          },
                        ),
                      ),
                      child: const Text('Settings'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Editor'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Зберегти справу'));
        await tester.pumpAndSettle();
        expect(find.text('Заповніть поле «Справа №».'), findsOneWidget);
        expectReadableText(tester);
        await tester.tap(find.text('Скасувати'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('theme-mode')));
        await tester.pumpAndSettle();
        expectReadableText(tester);
        await tester.tap(find.text('Темна').last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Зберегти'));
        await tester.pumpAndSettle();
        expect(
          find.text('Не вдалося зберегти налаштування. Спробуйте ще раз.'),
          findsOneWidget,
        );
        expectReadableText(tester);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets('$brightness login and input styles stay readable', (
      tester,
    ) async {
      await tester.pumpWidget(themed(brightness, const AuthScreen()));
      await tester.pumpAndSettle();
      expectReadableText(tester);
      for (final element in tester.elementList(find.byType(EditableText))) {
        final input = element.widget as EditableText;
        final scheme = Theme.of(element).colorScheme;
        expect(
          contrast(input.style.color!, scheme.surface),
          greaterThanOrEqualTo(4.5),
        );
      }
    });
  }
}
