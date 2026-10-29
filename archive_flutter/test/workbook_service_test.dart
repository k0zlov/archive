import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:archive_shared/archive_shared.dart';
import 'package:archive_flutter/data/workbook_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = WorkbookService();
  test('export preserves Ukrainian headers, identifiers and literal text', () {
    final bytes = service.export(ArchiveModule.court, [
      {
        'caseNumber': '001/26',
        'participants': 'Іван Петренко\nМарія & Олена',
        'notes': '=SUM(A1:A2)',
      },
    ]);
    final sheet = service.read(bytes).single;
    final p = service.preview(
      sheet,
      ArchiveModule.court,
      service.autoMapping(sheet, ArchiveModule.court),
    );
    expect(p.errors, isEmpty);
    expect(p.records.single['caseNumber'], '001/26');
    expect(p.records.single['participants'], 'Іван Петренко\nМарія & Олена');
    expect(p.records.single['notes'], '=SUM(A1:A2)');
  });
  test(
    'rows without case numbers are counted and skipped without blocking',
    () {
      final sheet = WorkbookSheet('Справи', {
        1: {0: const WorkbookCell('Справа №')},
        9: {0: const WorkbookCell('')},
        10: {0: const WorkbookCell('001')},
      }, false);
      final p = service.preview(sheet, ArchiveModule.court, {0: 'caseNumber'});
      expect(p.errors, isEmpty);
      expect(p.skippedCount, 1);
      expect(p.records, hasLength(1));
    },
  );
  test('duplicate scalar mappings fail while matching records are grouped', () {
    final sheet = WorkbookSheet('Справи', {
      1: {
        0: const WorkbookCell('Справа №'),
        1: const WorkbookCell('Інша колонка'),
      },
      2: {0: const WorkbookCell('1')},
      3: {0: const WorkbookCell('1')},
    }, false);
    expect(
      service.preview(sheet, ArchiveModule.court, {
        0: 'caseNumber',
        1: 'caseNumber',
      }).errors,
      isNotEmpty,
    );
    final result = service.preview(sheet, ArchiveModule.court, {
      0: 'caseNumber',
    });
    expect(result.errors, isEmpty);
    expect(result.duplicateCount, 1);
    expect(result.previewRecords, hasLength(1));
  });
  test(
    'Excel serial dates support both calendars and reject fictitious leap day',
    () {
      WorkbookSheet sheet(String serial, {bool date1904 = false}) =>
          WorkbookSheet('Справи', {
            1: {
              0: const WorkbookCell('Справа №'),
              1: const WorkbookCell('Дата надходження'),
            },
            2: {
              0: const WorkbookCell('01/26'),
              1: WorkbookCell(serial, numeric: true),
            },
          }, date1904);
      final mapping = {0: 'caseNumber', 1: 'receivedDate'};
      expect(
        service
            .preview(sheet('61'), ArchiveModule.court, mapping)
            .records
            .single['receivedDate'],
        '1900-03-01',
      );
      expect(
        service
            .preview(sheet('0', date1904: true), ArchiveModule.court, mapping)
            .records
            .single['receivedDate'],
        '1904-01-01',
      );
      expect(
        service.preview(sheet('60'), ArchiveModule.court, mapping).errors,
        isNotEmpty,
      );
    },
  );
  test(
    'formula cells are rejected instead of importing stale cached results',
    () {
      final bytes = service.export(ArchiveModule.court, [
        {'caseNumber': '1'},
      ]);
      final zip = ZipDecoder().decodeBytes(bytes);
      final changed = Archive();
      for (final f in zip) {
        var data = f.content;
        if (f.name == 'xl/worksheets/sheet1.xml') {
          data = utf8.encode(
            utf8
                .decode(data)
                .replaceFirst(
                  '<c r="A2" t="inlineStr"><is><t xml:space="preserve">1</t></is></c>',
                  '<c r="A2"><f>1+1</f><v>2</v></c>',
                ),
          );
        }
        changed.addFile(ArchiveFile(f.name, data.length, data));
      }
      expect(
        () => service.read(ZipEncoder().encode(changed)),
        throwsFormatException,
      );
    },
  );
  test(
    'several workbooks combine participant names, roles and proceedings with skipped blank identifiers',
    () {
      WorkbookSheet sheet(List<List<String>> rows) => WorkbookSheet('Справи', {
        1: {
          0: const WorkbookCell('Справа №'),
          1: const WorkbookCell("{Учасник справи (всі).Справа}.Суб'єкт.Назва"),
          2: const WorkbookCell(
            "{Учасник справи (всі).Справа}.Тип учасника.Назва",
          ),
          3: const WorkbookCell('Номер провадження'),
        },
        for (final row in rows.indexed)
          row.$1 + 2: {
            for (final cell in row.$2.indexed) cell.$1: WorkbookCell(cell.$2),
          },
      }, false);
      final first = sheet([
        ['', '', '', ''],
        [
          '243/6187/13-ц',
          'Аніщенко Роман Сергійович',
          'позивач',
          '2/243/499/2014',
        ],
        [
          '243/6187/13-ц',
          'Комаревська Світлана Іванівна',
          'відповідач',
          '2/243/499/2014',
        ],
      ]);
      final second = sheet([
        [
          '243/6187/13-ц',
          'Слов’янський МВ УМВС',
          'третя особа',
          '2/243/501/2014',
        ],
        [
          '243/6187/13-ц',
          'Аніщенко Роман Сергійович',
          'позивач',
          '2/243/499/2014',
        ],
      ]);
      final p = service.previewSession(
        ImportSessionPreparation(ArchiveModule.court, [
          for (final source in [first, second])
            ImportSourceSelection(
              'file.xlsx',
              source,
              service.autoMapping(source, ArchiveModule.court),
            ),
        ]),
      );
      expect(p.errors, isEmpty);
      expect(p.skippedCount, 1);
      expect(p.duplicateCount, 3);
      expect(p.previewRecords, hasLength(1));
      final people = caseParticipants(p.previewRecords.single);
      expect(people, hasLength(3));
      expect(people.first.role, 'позивач');
      expect(people.last.proceeding, '2/243/501/2014');
      final roundTripSheet = service
          .read(service.export(ArchiveModule.court, p.previewRecords))
          .single;
      final roundTrip = service.preview(
        roundTripSheet,
        ArchiveModule.court,
        service.autoMapping(roundTripSheet, ArchiveModule.court),
      );
      expect(
        caseParticipants(
          roundTrip.previewRecords.single,
        ).map((p) => p.toJson()).toList(),
        people.map((p) => p.toJson()).toList(),
      );
    },
  );
}
