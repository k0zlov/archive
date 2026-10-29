import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:archive_shared/archive_schema.dart';
import 'package:xml/xml.dart';

class WorkbookCell {
  const WorkbookCell(this.text, {this.numeric = false});
  final String text;
  final bool numeric;
}

class WorkbookSheet {
  WorkbookSheet(this.name, this.rows, this.date1904);
  final String name;
  final Map<int, Map<int, WorkbookCell>> rows;
  final bool date1904;
  Map<int, WorkbookCell> get headers => rows[1] ?? {};
}

class ImportPreview {
  ImportPreview(
    this.records,
    this.errors,
    this.ignoredColumns, {
    this.previewRecords = const [],
    this.duplicateCount = 0,
    this.newCount = 0,
    this.updatedCount = 0,
    this.skippedCount = 0,
    this.totalRows = 0,
    this.errorCounts = const {},
    this.warningCounts = const {},
  });
  final List<Map<String, String>> records;
  final List<Map<String, String>> previewRecords;
  final List<String> errors;
  final List<String> ignoredColumns;
  final Map<String, int> errorCounts;
  final Map<String, int> warningCounts;
  int get warningCount =>
      warningCounts.values.fold(0, (total, count) => total + count);
  final int duplicateCount;
  final int skippedCount;
  final int newCount;
  final int updatedCount;
  final int totalRows;
}

class ImportPreparation {
  const ImportPreparation(this.sheet, this.module, this.mapping);
  final WorkbookSheet sheet;
  final ArchiveModule module;
  final Map<int, String?> mapping;
}

class ImportSourceSelection {
  const ImportSourceSelection(this.name, this.sheet, this.mapping);
  final String name;
  final WorkbookSheet sheet;
  final Map<int, String?> mapping;
}

class ImportSessionPreparation {
  const ImportSessionPreparation(
    this.module,
    this.sources, {
    this.existing = const [],
    this.replaceExisting = false,
  });
  final ArchiveModule module;
  final List<ImportSourceSelection> sources;
  final List<Map<String, String>> existing;
  final bool replaceExisting;
}

List<WorkbookSheet> readArchiveWorkbook(List<int> bytes) =>
    WorkbookService().read(bytes);
ImportPreview prepareArchiveImport(ImportPreparation request) =>
    WorkbookService().preview(request.sheet, request.module, request.mapping);
ImportPreview prepareArchiveImportSession(ImportSessionPreparation request) =>
    WorkbookService().previewSession(request);

/// Reads OOXML values without evaluating formulas or executing embedded content.
const participantRoleImportField = ArchiveField(
  'participantRole',
  'Роль учасника',
  'Учасники справи',
  aliases: ["{Учасник справи (всі).Справа}.Тип учасника.Назва"],
);
List<ArchiveField> importFields(ArchiveModule module) =>
    module == ArchiveModule.management
    ? module.fields
    : [
        module.fields.firstWhere((f) => f.key == 'caseNumber'),
        const ArchiveField(
          'participants',
          'Ім’я / назва учасника',
          'Учасники справи',
          aliases: [
            "{Учасник справи (всі).Справа}.Суб'єкт.Назва",
            'Учасники справи',
          ],
        ),
        participantRoleImportField,
        const ArchiveField(
          'proceedingNumber',
          'Номер провадження',
          'Учасники справи',
        ),
        for (final f in module.fields)
          if (![
            'caseNumber',
            'participants',
            'proceedingNumber',
          ].contains(f.key))
            f,
      ];

class WorkbookService {
  List<WorkbookSheet> read(List<int> bytes) {
    final zip = ZipDecoder().decodeBytes(bytes);
    XmlDocument xml(String name) {
      final file = zip.findFile(name);
      if (file == null) {
        throw FormatException('Файл не є підтримуваною книгою Excel: $name.');
      }
      return XmlDocument.parse(utf8.decode(file.content));
    }

    final workbook = xml('xl/workbook.xml');
    final rels = xml('xl/_rels/workbook.xml.rels');
    final targets = {
      for (final r in rels.findAllElements('Relationship'))
        r.getAttribute('Id'): r.getAttribute('Target')!,
    };
    final date1904 = workbook
        .findAllElements('workbookPr')
        .any((e) => ['1', 'true'].contains(e.getAttribute('date1904')));
    final strings = zip.findFile('xl/sharedStrings.xml') == null
        ? <String>[]
        : xml('xl/sharedStrings.xml')
              .findAllElements('si')
              .map((e) => e.findAllElements('t').map((t) => t.innerText).join())
              .toList();
    final result = <WorkbookSheet>[];
    for (final sheet in workbook.findAllElements('sheet')) {
      final relation = sheet.attributes
          .where((a) => a.name.local == 'id')
          .firstOrNull
          ?.value;
      final target = targets[relation];
      if (target == null) continue;
      final path = target.startsWith('/')
          ? target.substring(1)
          : Uri.parse('xl/').resolve(target).path;
      final data = xml(path);
      final rows = <int, Map<int, WorkbookCell>>{};
      for (final row in data.findAllElements('row')) {
        final rowNumber = int.parse(row.getAttribute('r')!);
        final cells = <int, WorkbookCell>{};
        for (final cell in row.findElements('c')) {
          final reference = cell.getAttribute('r')!;
          var column = 0;
          for (final char in RegExp(
            r'^[A-Z]+',
          ).stringMatch(reference)!.codeUnits) {
            column = column * 26 + char - 64;
          }
          if (cell.findElements('f').isNotEmpty) {
            throw FormatException(
              'Клітинка $reference містить формулу. Збережіть її результат як значення перед імпортом.',
            );
          }
          final type = cell.getAttribute('t');
          var value = cell.getElement('v')?.innerText ?? '';
          if (type == 's') {
            value = strings[int.parse(value)];
          }
          if (type == 'inlineStr') {
            value = cell.findAllElements('t').map((e) => e.innerText).join();
          }
          if (type == 'e') {
            throw FormatException('Клітинка $reference містить помилку Excel.');
          }
          if (value.isNotEmpty) {
            cells[column - 1] = WorkbookCell(
              value,
              numeric: type == null || type == 'n',
            );
          }
        }
        if (cells.isNotEmpty) rows[rowNumber] = cells;
      }
      if (rows.isNotEmpty) {
        result.add(
          WorkbookSheet(sheet.getAttribute('name') ?? 'Аркуш', rows, date1904),
        );
      }
    }
    if (result.isEmpty) throw const FormatException('У книзі немає даних.');
    return result;
  }

  Map<int, String?> autoMapping(WorkbookSheet sheet, ArchiveModule module) {
    final used = <String>{};
    return {
      for (final entry in sheet.headers.entries)
        entry.key: (() {
          final field = importFields(module)
              .where(
                (f) => [f.key, f.label, ...f.aliases].any(
                  (label) =>
                      normalizeHeader(label) ==
                      normalizeHeader(entry.value.text),
                ),
              )
              .firstOrNull
              ?.key;
          if (field == null) return null;
          if (!used.add(field) &&
              !['participants', 'proceedingNumber'].contains(field)) {
            return null;
          }
          return field;
        })(),
    };
  }

  ImportPreview preview(
    WorkbookSheet sheet,
    ArchiveModule module,
    Map<int, String?> mapping,
  ) => previewSession(
    ImportSessionPreparation(module, [
      ImportSourceSelection(sheet.name, sheet, mapping),
    ]),
  );

  ImportPreview previewSession(ImportSessionPreparation request) {
    final module = request.module;
    final errors = <String, int>{};
    final warnings = <String, int>{};
    final ignored = <String>[];
    final records = <Map<String, String>>[];
    final grouped = <String, Map<String, String>>{};
    final existing = {
      for (final values in request.existing)
        recordIdentity(module, values): values,
    };
    var totalRows = 0;
    var skipped = 0;
    void error(String message) =>
        errors.update(message, (n) => n + 1, ifAbsent: () => 1);
    for (final source in request.sources) {
      final sheet = source.sheet;
      final mapping = source.mapping;
      var validMapping = true;
      if (sheet.headers.isEmpty) {
        error('Перший рядок має містити назви колонок.');
        validMapping = false;
      }
      final used = mapping.values.whereType<String>().toList();
      final singleFields = used
          .where((key) => !['participants', 'proceedingNumber'].contains(key))
          .toList();
      if (singleFields.toSet().length != singleFields.length) {
        error('Кілька колонок зіставлено з одним полем.');
        validMapping = false;
      }
      final hasIdentifier = module == ArchiveModule.court
          ? used.contains('caseNumber')
          : used.contains('caseIndex');
      if (!hasIdentifier) {
        error(
          module == ArchiveModule.court
              ? 'Призначте колонку «Номер справи» у кожному файлі.'
              : 'Призначте колонку «Індекс справи» у кожному файлі.',
        );
        validMapping = false;
      }
      ignored.addAll([
        for (final h in sheet.headers.entries)
          if (mapping[h.key] == null) h.value.text,
      ]);
      final rows = sheet.rows.entries.where((e) => e.key > 1).toList();
      totalRows += rows.length;
      if (rows.isEmpty) error('Після заголовків немає записів.');
      if (!validMapping) continue;
      for (final row in rows) {
        if (module == ArchiveModule.court &&
            !row.value.entries.any(
              (e) =>
                  mapping[e.key] == 'caseNumber' &&
                  e.value.text.trim().isNotEmpty,
            )) {
          skipped++;
          continue;
        }
        try {
          final values = <String, String>{};
          for (final cell in row.value.entries) {
            final key = mapping[cell.key];
            if (key == null) continue;
            final field = importFields(module).firstWhere((f) => f.key == key);
            var value = cell.value.text;
            if (field.kind == FieldKind.date &&
                cell.value.numeric &&
                value.isNotEmpty) {
              final serial = double.tryParse(value);
              if (serial != null) {
                if (!serial.isFinite ||
                    (!sheet.date1904 && serial.floor() == 60)) {
                  throw const FormatException('Excel містить недійсну дату.');
                }
                final epoch = sheet.date1904
                    ? DateTime.utc(1904, 1, 1)
                    : DateTime.utc(1899, 12, serial < 60 ? 31 : 30);
                value = isoDate(epoch.add(Duration(days: serial.floor())));
              }
            }
            if (field.kind == FieldKind.number && cell.value.numeric) {
              final number = double.tryParse(value);
              if (number != null &&
                  number.isFinite &&
                  number == number.truncateToDouble()) {
                value = '${number.toInt()}';
              }
            }
            values[key] = ['participants', 'proceedingNumber'].contains(key)
                ? mergeUniqueLines(values[key] ?? '', value)
                : value;
          }
          if (module == ArchiveModule.court) {
            final role = values.remove('participantRole') ?? '';
            if ((values['participants'] ?? '').trim().isNotEmpty) {
              values.addAll(
                participantValues([
                  CaseParticipant(
                    values['participants']!,
                    role: role,
                    proceeding: values['proceedingNumber'] ?? '',
                  ),
                ]),
              );
            }
          }
          final record = validateRecord(
            module,
            values,
            partial: true,
            allowDateOrderWarnings: true,
          );
          final key = recordIdentity(module, record);
          records.add(record);
          grouped[key] = mergeRecordValues(
            grouped[key] ?? existing[key] ?? {},
            record,
            replaceExisting: request.replaceExisting,
          );
        } on FormatException catch (e) {
          error(e.message);
        }
      }
    }
    for (final values in grouped.values) {
      try {
        validateRecord(module, values, allowDateOrderWarnings: true);
        for (final warning in recordDateWarnings(module, values)) {
          warnings.update(warning, (count) => count + 1, ifAbsent: () => 1);
        }
      } on FormatException catch (e) {
        error(e.message);
      }
    }
    return ImportPreview(
      records,
      errors.keys.toList(),
      ignored,
      previewRecords: grouped.values.toList(),
      duplicateCount: records.length - grouped.length,
      newCount: grouped.keys.where((key) => !existing.containsKey(key)).length,
      updatedCount: grouped.keys.where(existing.containsKey).length,
      totalRows: totalRows,
      skippedCount: skipped,
      errorCounts: errors,
      warningCounts: warnings,
    );
  }

  Uint8List export(
    ArchiveModule module,
    Iterable<Map<String, String>> records, {
    String title = 'Справи',
  }) {
    final fields = [
      for (final f in module.fields) f,
      if (module == ArchiveModule.court) participantRoleImportField,
    ];
    String esc(String s) => const HtmlEscape(HtmlEscapeMode.element).convert(s);
    String column(int n) {
      var s = '';
      for (n++; n > 0; n = (n - 1) ~/ 26) {
        s = String.fromCharCode(65 + (n - 1) % 26) + s;
      }
      return s;
    }

    String row(int number, List<String> values) =>
        '<row r="$number">${values.indexed.map((v) => '<c r="${column(v.$1)}$number" t="inlineStr"${number == 1 ? ' s="1"' : ''}><is><t xml:space="preserve">${esc(v.$2)}</t></is></c>').join()}</row>';
    final data = <Map<String, String>>[
      for (final record in records)
        ...(() {
          if (module != ArchiveModule.court ||
              !record.containsKey('participantDetails')) {
            return [record];
          }
          final people = caseParticipants(record);
          if (people.isEmpty) return [record];
          return [
            for (final p in people)
              {
                ...record,
                'participants': p.name,
                'participantRole': p.role,
                'proceedingNumber': p.proceeding,
              },
          ];
        })(),
    ];
    final sheet =
        '<?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetViews><sheetView workbookViewId="0"><pane ySplit="1" topLeftCell="A2" state="frozen"/></sheetView></sheetViews><cols><col min="1" max="${fields.length}" width="28" customWidth="1"/></cols><sheetData>${row(1, fields.map((f) => f.label).toList())}${data.indexed.map((v) => row(v.$1 + 2, fields.map((f) => v.$2[f.key] ?? '').toList())).join()}</sheetData><autoFilter ref="A1:${column(fields.length - 1)}${data.length + 1}"/></worksheet>';
    final zip = Archive();
    void add(String path, String content) {
      final bytes = utf8.encode(content);
      zip.addFile(ArchiveFile(path, bytes.length, bytes));
    }

    add(
      '[Content_Types].xml',
      '<?xml version="1.0"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/><Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/><Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/></Types>',
    );
    add(
      '_rels/.rels',
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>',
    );
    add(
      'xl/workbook.xml',
      '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets><sheet name="${esc(title)}" sheetId="1" r:id="rId1"/></sheets></workbook>',
    );
    add(
      'xl/_rels/workbook.xml.rels',
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/><Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/></Relationships>',
    );
    add(
      'xl/styles.xml',
      '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><fonts count="2"><font><sz val="11"/><name val="Calibri"/></font><font><b/><color rgb="FFFFFFFF"/><sz val="11"/><name val="Calibri"/></font></fonts><fills count="3"><fill><patternFill patternType="none"/></fill><fill><patternFill patternType="gray125"/></fill><fill><patternFill patternType="solid"><fgColor rgb="FF173B34"/></patternFill></fill></fills><borders count="1"><border/></borders><cellStyleXfs count="1"><xf/></cellStyleXfs><cellXfs count="2"><xf fontId="0" fillId="0" borderId="0" xfId="0"/><xf fontId="1" fillId="2" borderId="0" xfId="0" applyAlignment="1"><alignment wrapText="1"/></xf></cellXfs><cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles></styleSheet>',
    );
    add('xl/worksheets/sheet1.xml', sheet);
    return Uint8List.fromList(ZipEncoder().encode(zip));
  }
}
