import 'package:archive_flutter/ui/nomenclature_dialog.dart';
import 'package:archive_flutter/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'nomenclature inputs survive route closing animation and reopen cleanly',
    (tester) async {
      NomenclatureDetails? result;
      await tester.pumpWidget(
        MaterialApp(
          theme: archiveTheme(),
          home: Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () async {
                  result = await showNomenclatureDialog(context);
                },
                child: const Text('Додати'),
              ),
            ),
          ),
        ),
      );
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('Додати'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('nomenclature-title')),
          'Номенклатура 2026',
        );
        await tester.enterText(
          find.byKey(const ValueKey('nomenclature-year')),
          '2026',
        );
        await tester.tap(find.text('Обрати документ Word'));
        await tester.pump();
        expect(tester.takeException(), isNull);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(result?.title, 'Номенклатура 2026');
        expect(result?.year, 2026);
      }
    },
  );
  testWidgets(
    'invalid nomenclature stays in the dialog and cancellation is safe',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: archiveTheme(),
          home: Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () => showNomenclatureDialog(context),
                child: const Text('Додати'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Додати'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('nomenclature-year')),
        'x',
      );
      await tester.tap(find.text('Обрати документ Word'));
      await tester.pumpAndSettle();
      expect(find.text('Введіть назву номенклатури.'), findsOneWidget);
      expect(find.text('Введіть рік від 1900 до 2200.'), findsOneWidget);
      await tester.tap(find.text('Скасувати'));
      await tester.pumpAndSettle();
      expect(find.byType(NomenclatureDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
