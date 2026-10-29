library;

import 'dart:convert';

enum FieldKind { text, multiline, date, number, choice }

class ArchiveField {
  const ArchiveField(
    this.key,
    this.label,
    this.section, {
    this.kind = FieldKind.text,
    this.required = false,
    this.options = const [],
    this.aliases = const [],
  });
  final String key;
  final String label;
  final String section;
  final FieldKind kind;
  final bool required;
  final List<String> options;
  final List<String> aliases;
}

enum ArchiveModule {
  management('Управлінська документація'),
  court('Судові справи');

  const ArchiveModule(this.label);
  final String label;

  List<ArchiveField> get fields => [
    if (this == management) ...managementFields else ...courtFields,
    ...storageFields,
    const ArchiveField(
      'notes',
      'Примітки',
      'Інші дані',
      kind: FieldKind.multiline,
    ),
  ];
  String get referenceKey => this == management ? 'caseIndex' : 'caseNumber';
}

const managementFields = [
  ArchiveField(
    'caseIndex',
    'Індекс справи',
    'Інформація про справу',
    required: true,
  ),
  ArchiveField(
    'title',
    'Заголовок справи (тому, частини)',
    'Інформація про справу',
    required: true,
    kind: FieldKind.multiline,
    aliases: ['Заголовок справи', 'Назва справи'],
  ),
  ArchiveField(
    'volumeCount',
    'Кількість справ (томів, частин)',
    'Інформація про справу',
    kind: FieldKind.number,
  ),
  ArchiveField(
    'retentionArticles',
    'Строк зберігання справи (тому, частини) і номери статей за переліком',
    'Інформація про справу',
    kind: FieldKind.multiline,
  ),
  ArchiveField(
    'startDate',
    'Початкова дата справи',
    'Інформація про справу',
    kind: FieldKind.date,
  ),
  ArchiveField(
    'endDate',
    'Кінцева дата справи',
    'Інформація про справу',
    kind: FieldKind.date,
  ),
  ArchiveField(
    'nomenclatureYear',
    'Номенклатура (рік)',
    'Інформація про справу',
    kind: FieldKind.number,
  ),
];

const courtFields = [
  ArchiveField(
    'caseNumber',
    'Справа №',
    'Номери справи',
    required: true,
    aliases: ['Номер справи', 'Справа N', 'Справа №;'],
  ),
  ArchiveField('proceedingNumber', 'Номер провадження', 'Номери справи'),
  ArchiveField(
    'receivedDate',
    'Дата надходження',
    'Інформація про справу',
    kind: FieldKind.date,
  ),
  ArchiveField('category', 'Категорія справи', 'Інформація про справу'),
  ArchiveField('judge', 'Головуючий суддя', 'Інформація про справу'),
  ArchiveField(
    'participants',
    'Учасники справи',
    'Учасники справи',
    kind: FieldKind.multiline,
    aliases: [
      '{Учасник справи (всі).Справа}.Суб’єкт.Назва',
      "{Учасник справи (всі).Справа}.Суб'кт.Назва",
      "{Учасник справи (всі).Справа}.Суб'єкт.Назва",
    ],
  ),
  ArchiveField(
    'hearingDate',
    'Дата розгляду',
    'Перша інстанція',
    kind: FieldKind.date,
  ),
  ArchiveField(
    'hearingResult',
    'Результат розгляду',
    'Перша інстанція',
    kind: FieldKind.multiline,
  ),
  ArchiveField(
    'decisionSummary',
    'Зміст резолютивної частини рішення',
    'Перша інстанція',
    kind: FieldKind.multiline,
  ),
  ArchiveField(
    'effectiveDate',
    'Дата набрання законної сили судовим рішенням',
    'Перша інстанція',
    kind: FieldKind.date,
  ),
  ArchiveField(
    'appealFiledDate',
    'Дата подачі апеляційної скарги',
    'Апеляційна інстанція',
    kind: FieldKind.date,
  ),
  ArchiveField(
    'appealDate',
    'Дата розгляду апеляційної скарги',
    'Апеляційна інстанція',
    kind: FieldKind.date,
  ),
  ArchiveField(
    'appealResult',
    'Результат розгляду апеляційної скарги',
    'Апеляційна інстанція',
    kind: FieldKind.multiline,
  ),
  ArchiveField(
    'appealSummary',
    'Зміст резолютивної частини рішення апеляційної інстанції',
    'Апеляційна інстанція',
    kind: FieldKind.multiline,
  ),
  ArchiveField(
    'cassationFiledDate',
    'Дата подачі касаційної скарги',
    'Касаційна інстанція',
    kind: FieldKind.date,
  ),
  ArchiveField(
    'cassationDate',
    'Дата розгляду касаційної скарги',
    'Касаційна інстанція',
    kind: FieldKind.date,
  ),
  ArchiveField(
    'cassationResult',
    'Результат розгляду касаційної скарги',
    'Касаційна інстанція',
    kind: FieldKind.multiline,
  ),
  ArchiveField(
    'cassationSummary',
    'Зміст резолютивної частини рішення касаційної інстанції',
    'Касаційна інстанція',
    kind: FieldKind.multiline,
  ),
  ArchiveField(
    'enforcementSentDate',
    'Дата направлення судового рішення до виконання',
    'Виконання рішення',
    kind: FieldKind.date,
  ),
  ArchiveField(
    'enforcementAcceptedDate',
    'Дата прийняття судового рішення до виконання',
    'Виконання рішення',
    kind: FieldKind.date,
    aliases: ['Дата прийняття судового рішення виконання'],
  ),
  ArchiveField(
    'enforcementBody',
    'Орган виконання судового рішення',
    'Виконання рішення',
  ),
  ArchiveField(
    'enforcementDate',
    'Дата виконання судового рішення',
    'Виконання рішення',
    kind: FieldKind.date,
  ),
  ArchiveField(
    'enforcementResult',
    'Результат виконання судового рішення',
    'Виконання рішення',
    kind: FieldKind.multiline,
  ),
];

const storageFields = [
  ArchiveField(
    'archivedDate',
    'Дата передачі справи до архіву',
    'Архівне зберігання',
    kind: FieldKind.date,
  ),
  ArchiveField(
    'caseForm',
    'Форма справи, яку передано до архіву',
    'Архівне зберігання',
    kind: FieldKind.choice,
    options: ['Електронна', 'Паперова', 'Змішана'],
  ),
  ArchiveField(
    'storageForm',
    'Справа зберігається в',
    'Архівне зберігання',
    kind: FieldKind.choice,
    options: [
      'Електронній формі',
      'Паперовій формі',
      'Змішаній формі',
      'Підшивці судових рішень',
    ],
  ),
  ArchiveField(
    'retentionYears',
    'Архівний строк зберігання (років)',
    'Архівне зберігання',
    kind: FieldKind.number,
  ),
  ArchiveField(
    'retentionType',
    'Вид зберігання',
    'Архівне зберігання',
    kind: FieldKind.choice,
    options: ['Тимчасове', 'Тривале', 'Постійне'],
  ),
  ArchiveField(
    'destructionEligibleDate',
    'Справа підлягає знищенню з',
    'Архівне зберігання',
    kind: FieldKind.date,
  ),
  ArchiveField(
    'destroyedDate',
    'Дата знищення справи',
    'Архівне зберігання',
    kind: FieldKind.date,
  ),
  ArchiveField(
    'inventoryRequired',
    'Справа підлягає внесенню до опису',
    'Архівне зберігання',
    kind: FieldKind.choice,
    options: ['Так', 'Ні'],
  ),
  ArchiveField('inventoryNumber', 'Номер опису', 'Архівне зберігання'),
  ArchiveField(
    'inventoryDate',
    'Дата опису',
    'Архівне зберігання',
    kind: FieldKind.date,
  ),
  ArchiveField(
    'withdrawnDate',
    'Справу вилучено з архіву (дата)',
    'Архівне зберігання',
    kind: FieldKind.date,
  ),
  ArchiveField(
    'withdrawalBasis',
    'Справу вилучено з архіву на підставі',
    'Архівне зберігання',
    kind: FieldKind.multiline,
  ),
  ArchiveField(
    'returnedDate',
    'Справу повернуто до архіву',
    'Архівне зберігання',
    kind: FieldKind.date,
  ),
  ArchiveField('city', 'Місто', 'Місце зберігання справи'),
  ArchiveField('address', 'Адреса', 'Місце зберігання справи'),
  ArchiveField('room', 'Кабінет', 'Місце зберігання справи'),
  ArchiveField('rack', 'Стелаж', 'Місце зберігання справи'),
  ArchiveField(
    'shelf',
    'Полиця',
    'Місце зберігання справи',
    aliases: ['Полка'],
  ),
  ArchiveField(
    'storageLocation',
    'Місце зберігання справи',
    'Місце зберігання справи',
  ),
];

/// Only harmless typography is normalized; distinct column meanings stay distinct.
String normalizeHeader(String value) => value
    .toLowerCase()
    .replaceAll(RegExp('[’ʼ`\u2018]'), "'")
    .replaceAll(RegExp(r'[\s\u00a0]+'), ' ')
    .trim()
    .replaceAll(RegExp(r'[;:.]+$'), '');

DateTime? parseArchiveDate(String value) {
  final v = value.trim();
  final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(v);
  final ua = RegExp(r'^(\d{1,2})[./](\d{1,2})[./](\d{4})$').firstMatch(v);
  if (iso == null && ua == null) return null;
  final y = int.parse(iso?.group(1) ?? ua!.group(3)!);
  final m = int.parse(iso?.group(2) ?? ua!.group(2)!);
  final d = int.parse(iso?.group(3) ?? ua!.group(1)!);
  final date = DateTime.utc(y, m, d);
  return date.year == y && date.month == m && date.day == d ? date : null;
}

String isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
String displayDate(String value) {
  final d = parseArchiveDate(value);
  return d == null
      ? value
      : '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

Map<String, String> validateRecord(
  ArchiveModule module,
  Map<String, String> raw, {
  bool partial = false,
  bool allowDateOrderWarnings = false,
}) {
  final known = module.fields.map((f) => f.key).toSet();
  if (module == ArchiveModule.court) known.add('participantDetails');
  final unknown = raw.keys.where((k) => !known.contains(k)).toList()..sort();
  if (unknown.isNotEmpty) {
    throw FormatException(
      'Непідтримувані поля для модуля «${module.label}»: ${unknown.join(', ')}. Оновіть застосунок і сервер.',
    );
  }
  final result = <String, String>{};
  for (final f in module.fields) {
    var value = (raw[f.key] ?? '').trim();
    if (f.required &&
        value.isEmpty &&
        (!partial || f.key == module.referenceKey))
      throw FormatException('Заповніть поле «${f.label}».');
    if (value.isEmpty) continue;
    if (value.length > 20000 &&
        !['participants', 'proceedingNumber'].contains(f.key))
      throw FormatException('Поле «${f.label}» перевищує 20 000 символів.');
    if (f.kind == FieldKind.date) {
      final date = parseArchiveDate(value);
      if (date == null)
        throw FormatException('«${f.label}»: введіть дійсну дату ДД.ММ.РРРР.');
      value = isoDate(date);
    }
    if (f.kind == FieldKind.number) {
      final number = int.tryParse(value);
      if (number == null || number < 0 || number > 9999)
        throw FormatException(
          '«${f.label}»: очікується ціле число від 0 до 9999.',
        );
      value = '$number';
    }
    if (f.kind == FieldKind.choice) {
      final options = f.options.where(
        (o) => normalizeHeader(o) == normalizeHeader(value),
      );
      if (options.isEmpty)
        throw FormatException('«${f.label}»: оберіть ${f.options.join(', ')}.');
      value = options.first;
    }
    result[f.key] = value;
  }
  if (module == ArchiveModule.court) {
    if ((result['caseNumber'] ?? '').isEmpty)
      throw const FormatException('Заповніть номер справи.');
    if (raw['participantDetails']?.isNotEmpty == true) {
      final participants = caseParticipants(raw);
      final proceedings = result['proceedingNumber'] ?? '';
      result.addAll(participantValues(participants));
      final combined = mergeUniqueLines(
        proceedings,
        result['proceedingNumber'] ?? '',
      );
      if (combined.isNotEmpty)
        result['proceedingNumber'] = combined;
      else
        result.remove('proceedingNumber');
    }
  }
  final dateWarnings = recordDateWarnings(module, result);
  if (!allowDateOrderWarnings && dateWarnings.isNotEmpty) {
    throw FormatException(dateWarnings.first);
  }
  return Map.unmodifiable(result);
}

/// A court card can combine several proceedings and repeat hearings. Import
/// retains the source dates; chronology is a review warning, not a data rewrite.
List<String> recordDateWarnings(
  ArchiveModule module,
  Map<String, String> values,
) {
  final labels = {for (final f in module.fields) f.key: f.label};
  final warnings = <String>[];
  for (final pair in [
    ('startDate', 'endDate'),
    ('receivedDate', 'hearingDate'),
    ('withdrawnDate', 'returnedDate'),
  ]) {
    final start = values[pair.$1];
    final end = values[pair.$2];
    if (start != null &&
        end != null &&
        parseArchiveDate(start) != null &&
        parseArchiveDate(end) != null &&
        parseArchiveDate(start)!.isAfter(parseArchiveDate(end)!)) {
      warnings.add('«${labels[pair.$2]}» раніше «${labels[pair.$1]}».');
    }
  }
  return warnings;
}

String normalizeIdentifier(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');

class CaseParticipant {
  const CaseParticipant(this.name, {this.role = '', this.proceeding = ''});
  final String name;
  final String role;
  final String proceeding;
  String get identity =>
      [name, role, proceeding].map(normalizeHeader).join('\u001f');
  String get display => [
    if (role.isNotEmpty) role,
    name,
    if (proceeding.isNotEmpty) 'Провадження № $proceeding',
  ].join(' · ');
  Map<String, String> toJson() => {
    'name': name.trim(),
    'role': role.trim(),
    'proceeding': proceeding.trim(),
  };
}

List<CaseParticipant> caseParticipants(Map<String, String> values) {
  if (values['participantDetails']?.isNotEmpty == true) {
    try {
      final parsed = jsonDecode(values['participantDetails']!) as List;
      return parsed
          .map((v) {
            final entry = Map<String, dynamic>.from(v as Map);
            if (entry.keys.any(
                  (k) => !['name', 'role', 'proceeding'].contains(k),
                ) ||
                entry.values.any((v) => v is! String))
              throw const FormatException('Некоректні дані учасника.');
            return CaseParticipant(
              (entry['name'] as String? ?? '').trim(),
              role: (entry['role'] as String? ?? '').trim(),
              proceeding: (entry['proceeding'] as String? ?? '').trim(),
            );
          })
          .where((p) => p.name.isNotEmpty)
          .toList();
    } catch (_) {
      throw const FormatException('Некоректні дані учасників справи.');
    }
  }
  return (values['participants'] ?? '')
      .split(RegExp(r'[;\n\r]+'))
      .map((v) => v.trim())
      .where((v) => v.isNotEmpty)
      .map((v) => CaseParticipant(v))
      .toList();
}

Map<String, String> participantValues(Iterable<CaseParticipant> participants) {
  final unique = <String, CaseParticipant>{};
  for (final p in participants) {
    if (p.name.trim().isNotEmpty) unique.putIfAbsent(p.identity, () => p);
  }
  final detailedNames = unique.values
      .where((p) => p.role.isNotEmpty || p.proceeding.isNotEmpty)
      .map((p) => normalizeHeader(p.name))
      .toSet();
  final result = unique.values
      .where(
        (p) =>
            p.role.isNotEmpty ||
            p.proceeding.isNotEmpty ||
            !detailedNames.contains(normalizeHeader(p.name)),
      )
      .toList();
  return {
    'proceedingNumber': mergeUniqueLines(
      '',
      result.map((p) => p.proceeding).where((p) => p.isNotEmpty).join('\n'),
    ),
    'participants': result.map((p) => p.display).join('\n'),
    'participantDetails': jsonEncode(result.map((p) => p.toJson()).toList()),
  };
}

String recordReference(ArchiveModule module, Map<String, String> values) =>
    values[module.referenceKey]?.trim().isNotEmpty == true
    ? values[module.referenceKey]!
    : values['proceedingNumber'] ?? '';

String recordIdentity(ArchiveModule module, Map<String, String> values) {
  if (module == ArchiveModule.court) {
    final number = normalizeIdentifier(values['caseNumber'] ?? '');
    return 'court:case:$number';
  }
  return '${module.name}\u001f${normalizeHeader(values[module.referenceKey] ?? '')}\u001f${normalizeHeader(values['nomenclatureYear'] ?? '')}';
}

String mergeUniqueLines(String existing, String incoming) {
  final values = <String, String>{};
  for (final item in '$existing\n$incoming'.split(RegExp(r'[;\n\r]+'))) {
    final trimmed = item.trim();
    if (trimmed.isNotEmpty)
      values.putIfAbsent(normalizeHeader(trimmed), () => trimmed);
  }
  return values.values.join('\n');
}

/// Empty cells never erase data. Participants and case proceedings are unions.
Map<String, String> mergeRecordValues(
  Map<String, String> existing,
  Map<String, String> incoming, {
  bool replaceExisting = false,
}) {
  final result = Map<String, String>.from(existing);
  for (final entry in incoming.entries) {
    if (entry.value.trim().isEmpty) continue;
    if (entry.key == 'participants' || entry.key == 'proceedingNumber') {
      result[entry.key] = mergeUniqueLines(
        result[entry.key] ?? '',
        entry.value,
      );
    } else if (replaceExisting || (result[entry.key] ?? '').trim().isEmpty) {
      result[entry.key] = entry.value;
    }
  }
  if (existing.containsKey('participantDetails') ||
      incoming.containsKey('participantDetails')) {
    final proceedings = result['proceedingNumber'] ?? '';
    result.addAll(
      participantValues([
        ...caseParticipants(existing),
        ...caseParticipants(incoming),
      ]),
    );
    final combined = mergeUniqueLines(
      proceedings,
      result['proceedingNumber'] ?? '',
    );
    if (combined.isNotEmpty)
      result['proceedingNumber'] = combined;
    else
      result.remove('proceedingNumber');
  }
  return result;
}

bool sameRecordValues(Map<String, String> a, Map<String, String> b) =>
    a.length == b.length && a.entries.every((e) => b[e.key] == e.value);

bool canReadModule(Map<String, dynamic> profile, ArchiveModule module) =>
    profile['passwordChangeRequired'] != true &&
    (profile['role'] == 'admin' ||
        (['reader', 'editor'].contains(profile['role']) &&
            profile['${module.name}Access'] == true));

bool canWriteModule(Map<String, dynamic> profile, ArchiveModule module) =>
    profile['passwordChangeRequired'] != true &&
    (profile['role'] == 'admin' ||
        (profile['role'] == 'editor' && canReadModule(profile, module)));

const roleLabels = {
  'pending': 'Очікує підтвердження',
  'reader': 'Читач',
  'editor': 'Редактор',
  'admin': 'Адміністратор',
  'blocked': 'Заблоковано',
};
