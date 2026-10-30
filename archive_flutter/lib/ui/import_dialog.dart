import 'dart:async';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart' show XFile;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:archive_shared/archive_schema.dart';
import '../data/workbook_service.dart';
import '../data/file_actions.dart';
import '../data/archive_repository.dart';
import 'archive_controller.dart';
import 'theme.dart';

class ImportFileConfiguration {
  ImportFileConfiguration(this.name, this.sheets, {this.error});
  final String name;
  final List<WorkbookSheet> sheets;
  final String? error;
  int selectedSheet = 0;
  Map<int, String?> mapping = {};
  WorkbookSheet? get sheet => sheets.isEmpty ? null : sheets[selectedSheet];
}

Future<void> showImportDialog(
  BuildContext context,
  ArchiveController controller,
) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ArchiveImportDialog(controller: controller),
  );
  await controller.loadPage();
}

class ArchiveImportDialog extends StatefulWidget {
  const ArchiveImportDialog({
    super.key,
    required this.controller,
    this.initialFiles = const [],
  });
  final ArchiveController controller;
  final List<ImportFileConfiguration> initialFiles;
  @override
  State<ArchiveImportDialog> createState() => _ArchiveImportDialogState();
}

class _ArchiveImportDialogState extends State<ArchiveImportDialog> {
  final service = WorkbookService();
  late ArchiveModule module = widget.controller.module;
  final files = <ImportFileConfiguration>[];
  int selectedFile = 0;
  bool moduleChosen = false;
  bool replaceExisting = false;
  bool loading = false;
  bool picking = false;
  bool dragging = false;
  String? fileNotice;
  bool importing = false;
  bool validating = false;
  bool cancelRequested = false;
  int processed = 0;
  int total = 0;
  int revision = 0;
  String filter = '';
  String? error;
  ImportPreview? preview;
  Timer? debounce;
  @override
  void initState() {
    super.initState();
    files.addAll(widget.initialFiles);
    for (final f in files) {
      if (f.sheet != null) f.mapping = service.autoMapping(f.sheet!, module);
    }
    if (files.isNotEmpty) scheduleValidation();
  }

  @override
  void dispose() {
    debounce?.cancel();
    revision++;
    super.dispose();
  }

  void scheduleValidation() {
    debounce?.cancel();
    final next = ++revision;
    if (files.isEmpty) {
      setState(() {
        preview = null;
        validating = false;
      });
      return;
    }
    setState(() {
      validating = true;
      error = null;
    });
    debounce = Timer(const Duration(milliseconds: 250), () => validate(next));
  }

  Future<void> validate(int version) async {
    final activity = widget.controller.repository.activity;
    final task = activity.begin('Перевірка колонок і даних Excel', priority: 5);
    final selections = [
      for (final f in files)
        if (f.sheet != null)
          ImportSourceSelection(f.name, f.sheet!, Map.of(f.mapping)),
    ];
    final request = ImportSessionPreparation(
      module,
      selections,
      existing: widget.controller.repository.records
          .where((r) => r.module == module)
          .map((r) => r.values)
          .toList(),
      replaceExisting: replaceExisting,
    );
    try {
      final result = await compute(prepareArchiveImportSession, request);
      if (mounted && revision == version) {
        setState(() {
          preview = result;
          validating = false;
        });
      }
    } catch (_) {
      if (mounted && revision == version) {
        setState(() {
          error = 'Не вдалося перевірити конфігурацію.';
          validating = false;
        });
      }
    } finally {
      activity.end(task);
    }
  }

  Future<void> addFiles() async {
    if (picking || loading || importing) return;
    setState(() => picking = true);
    try {
      final selected = await chooseFiles(['xlsx']);
      if (!mounted) return;
      setState(() => picking = false);
      await loadFiles(selected);
    } catch (_) {
      if (mounted) {
        setState(() {
          picking = false;
          error = 'Не вдалося відкрити вибір файлів.';
        });
      }
    }
  }

  Future<Uint8List> readFile(XFile file) async {
    final bookmark = file is DropItem ? file.extraAppleBookmark : null;
    var accessing = false;
    try {
      if (bookmark?.isNotEmpty == true) {
        accessing = await DesktopDrop.instance
            .startAccessingSecurityScopedResource(bookmark: bookmark!);
      }
      return await file.readAsBytes();
    } finally {
      if (accessing) {
        await DesktopDrop.instance.stopAccessingSecurityScopedResource(
          bookmark: bookmark!,
        );
      }
    }
  }

  Future<void> loadFiles(List<XFile> incoming) async {
    if (loading || importing || !mounted) return;
    final selected = incoming
        .where(
          (file) =>
              file is! DropItemDirectory &&
              file.name.toLowerCase().endsWith('.xlsx'),
        )
        .toList();
    final unsupported = incoming.length - selected.length;
    setState(() {
      dragging = false;
      fileNotice = unsupported > 0
          ? 'Пропущено файлів іншого формату: $unsupported. Підтримується .xlsx.'
          : null;
    });
    if (selected.isEmpty) return;
    setState(() => loading = true);
    final activity = widget.controller.repository.activity;
    final task = activity.begin('Читання файлів Excel', priority: 5);
    var done = 0;
    try {
      for (final file in selected) {
        activity.stage(
          task,
          'Читання Excel: ${file.name}',
          completed: done,
          total: selected.length,
        );
        try {
          final sheets = await compute(
            readArchiveWorkbook,
            await readFile(file),
          );
          if (!mounted) return;
          if (files.isEmpty && !moduleChosen) {
            final mapped = service
                .autoMapping(sheets.first, ArchiveModule.court)
                .values;
            if ((mapped.contains('caseNumber') ||
                    mapped.contains('proceedingNumber')) &&
                canWriteModule(
                  widget.controller.repository.profile,
                  ArchiveModule.court,
                )) {
              module = ArchiveModule.court;
            }
          }
          final config = ImportFileConfiguration(file.name, sheets);
          config.mapping = service.autoMapping(config.sheet!, module);
          setState(() {
            files.add(config);
            selectedFile = files.length - 1;
          });
        } catch (e) {
          if (!mounted) return;
          setState(
            () => files.add(
              ImportFileConfiguration(
                file.name,
                [],
                error: e is FormatException
                    ? e.message
                    : 'Не вдалося прочитати файл Excel.',
              ),
            ),
          );
        }
        done++;
      }
    } finally {
      activity.end(task);
    }
    if (!mounted) return;
    setState(() {
      loading = false;
      filter = '';
    });
    scheduleValidation();
  }

  Future<void> import() async {
    final p = preview!;
    setState(() {
      importing = true;
      cancelRequested = false;
      processed = 0;
      total = p.records.length;
      error = null;
    });
    try {
      await widget.controller.repository.importRows(
        module,
        p.records,
        sourceNames: files.map((f) => f.name).toList(),
        replaceExisting: replaceExisting,
        isCancelled: () => cancelRequested,
        onProgress: (done, count) {
          if (mounted) {
            setState(() {
              processed = done;
              total = count;
            });
          }
        },
      );
      if (!mounted) return;
      final stats = widget.controller.repository.lastImportSummary;
      showArchiveMessage(
        context,
        'Імпорт завершено. Додано: ${stats['created'] ?? 0}, оновлено: ${stats['updated'] ?? 0}, без змін: ${stats['unchanged'] ?? 0}. Зауважень до дат: ${stats['warnings'] ?? 0}.',
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          importing = false;
          error = e is ArchiveFailure
              ? e.message
              : 'Не вдалося підтвердити завершення імпорту. Оновіть список справ перед повторною спробою.';
        });
      }
    }
  }

  Widget counter(String label, int value, {bool bad = false}) => Chip(
    label: Text(
      '$label: $value',
      style: TextStyle(
        fontSize: 12,
        color: bad
            ? context.archiveScheme.error
            : context.archiveScheme.primary,
      ),
    ),
    side: BorderSide.none,
    backgroundColor: bad
        ? context.archiveScheme.errorContainer
        : context.archiveColors.subtleSurface,
  );

  @override
  Widget build(BuildContext context) {
    final p = preview;
    final fileErrors = files.where((f) => f.error != null).length;
    final errors =
        (p?.errorCounts.values.fold<int>(0, (a, b) => a + b) ?? 0) + fileErrors;
    final ready =
        files.isNotEmpty &&
        !loading &&
        !validating &&
        !importing &&
        error == null &&
        errors == 0 &&
        p != null &&
        p.records.isNotEmpty;
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: DropTarget(
        enable: !loading && !importing && !picking,
        onDragEntered: (_) => setState(() => dragging = true),
        onDragExited: (_) => setState(() => dragging = false),
        onDragDone: (details) => unawaited(loadFiles(details.files)),
        child: Stack(
          children: [
            SizedBox(
              width: 1220,
              height: MediaQuery.sizeOf(context).height * .94,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 18, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Імпорт Excel',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Закрити',
                          onPressed: importing
                              ? null
                              : () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 280,
                          child: DropdownButtonFormField<ArchiveModule>(
                            key: ValueKey(module),
                            initialValue: module,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Модуль',
                            ),
                            items: ArchiveModule.values
                                .where(
                                  (m) => canWriteModule(
                                    widget.controller.repository.profile,
                                    m,
                                  ),
                                )
                                .map(
                                  (m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(m.label),
                                  ),
                                )
                                .toList(),
                            onChanged: importing || loading
                                ? null
                                : (m) {
                                    setState(() {
                                      module = m!;
                                      moduleChosen = true;
                                      for (final f in files) {
                                        if (f.sheet != null) {
                                          f.mapping = service.autoMapping(
                                            f.sheet!,
                                            module,
                                          );
                                        }
                                      }
                                    });
                                    scheduleValidation();
                                  },
                          ),
                        ),
                        SizedBox(
                          width: 310,
                          child: DropdownButtonFormField<bool>(
                            initialValue: false,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Наявні справи',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: false,
                                child: Text('Доповнювати порожні поля'),
                              ),
                              DropdownMenuItem(
                                value: true,
                                child: Text('Замінювати новими значеннями'),
                              ),
                            ],
                            onChanged: importing
                                ? null
                                : (v) {
                                    setState(() => replaceExisting = v!);
                                    scheduleValidation();
                                  },
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: loading || importing ? null : addFiles,
                          icon: const Icon(Icons.add),
                          label: Text(loading ? 'Читання…' : 'Додати файли'),
                        ),
                        TextButton.icon(
                          onPressed: importing
                              ? null
                              : () => saveFile(
                                  'Шаблон_${module.name}.xlsx',
                                  service.export(module, []),
                                ),
                          icon: const Icon(Icons.download_outlined),
                          label: const Text('Шаблон'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            counter('Файлів', files.length),
                            counter('Рядків', p?.totalRows ?? 0),
                            counter('Нових справ', p?.newCount ?? 0),
                            counter('Наявних', p?.updatedCount ?? 0),
                            counter('Об’єднань', p?.duplicateCount ?? 0),
                            counter(
                              'Без номера',
                              p?.skippedCount ?? 0,
                            ),
                            counter(
                              'Без зіставлення',
                              p?.ignoredColumns.length ?? 0,
                            ),
                            counter('Зауважень до дат', p?.warningCount ?? 0),
                            counter('Помилок', errors, bad: errors > 0),
                            if (validating)
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'Автоматична перевірка…',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                        if (fileNotice != null)
                          Text(
                            fileNotice!,
                            style: const TextStyle(fontSize: 12),
                          ),
                        if (p != null && p.warningCount > 0) ...[
                          const Text(
                            'Перевірте дати. Імпорт дозволено.',
                            style: TextStyle(fontSize: 12),
                          ),
                          for (final warning in p.warningCounts.entries.take(2))
                            Text(
                              '${warning.key} (${warning.value})',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.archiveScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                        if (p != null)
                          ...p.errorCounts.entries
                              .take(3)
                              .map(
                                (e) => Text(
                                  '${e.key} (${e.value})',
                                  style: TextStyle(
                                    color: context.archiveScheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                        if (fileErrors > 0)
                          Text(
                            'Не вдалося прочитати файлів: $fileErrors. Приберіть їх зі списку або оберіть виправлені файли.',
                            style: TextStyle(
                              color: context.archiveScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        if (error != null)
                          Text(
                            error!,
                            style: TextStyle(
                              color: context.archiveScheme.error,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),
                  Expanded(
                    child: files.isEmpty
                        ? EmptyArchive(
                            title: 'Додайте файли Excel',
                            message:
                                'Перетягніть файли .xlsx або оберіть їх кнопкою.',
                            action: OutlinedButton.icon(
                              onPressed: loading ? null : addFiles,
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Обрати файли'),
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, bounds) => Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  width: bounds.maxWidth > 700 ? 250 : 170,
                                  child: ListView.builder(
                                    itemCount: files.length,
                                    itemBuilder: (context, i) => ListTile(
                                      selected: selectedFile == i,
                                      selectedTileColor:
                                          context.archiveColors.subtleSurface,
                                      title: Text(
                                        files[i].name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      subtitle: Text(
                                        files[i].error != null
                                            ? 'Помилка читання'
                                            : 'Призначено: ${files[i].mapping.values.whereType<String>().length}',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      onTap: importing
                                          ? null
                                          : () => setState(() {
                                              selectedFile = i;
                                              filter = '';
                                            }),
                                      trailing: IconButton(
                                        tooltip: 'Прибрати файл',
                                        icon: const Icon(Icons.close, size: 17),
                                        onPressed: importing
                                            ? null
                                            : () {
                                                setState(() {
                                                  files.removeAt(i);
                                                  selectedFile = selectedFile
                                                      .clamp(
                                                        0,
                                                        files.isEmpty
                                                            ? 0
                                                            : files.length - 1,
                                                      );
                                                });
                                                scheduleValidation();
                                              },
                                      ),
                                    ),
                                  ),
                                ),
                                const VerticalDivider(width: 1),
                                Expanded(
                                  child: fileConfiguration(files[selectedFile]),
                                ),
                              ],
                            ),
                          ),
                  ),
                  if (p != null && p.previewRecords.isNotEmpty)
                    ExpansionTile(
                      title: const Text(
                        'Попередній перегляд справ',
                        style: TextStyle(fontSize: 13),
                      ),
                      children: [
                        SizedBox(
                          height: 160,
                          child: SingleChildScrollView(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: [
                                  for (final key
                                      in module == ArchiveModule.court
                                          ? [
                                              'caseNumber',
                                              'proceedingNumber',
                                              'participants',
                                              'category',
                                            ]
                                          : [
                                              'caseIndex',
                                              'title',
                                              'nomenclatureYear',
                                            ])
                                    DataColumn(
                                      label: Text(
                                        module.fields
                                            .firstWhere((f) => f.key == key)
                                            .label,
                                      ),
                                    ),
                                ],
                                rows: p.previewRecords
                                    .take(10)
                                    .map(
                                      (r) => DataRow(
                                        cells: [
                                          for (final key
                                              in module == ArchiveModule.court
                                                  ? [
                                                      'caseNumber',
                                                      'proceedingNumber',
                                                      'participants',
                                                      'category',
                                                    ]
                                                  : [
                                                      'caseIndex',
                                                      'title',
                                                      'nomenclatureYear',
                                                    ])
                                            DataCell(
                                              SizedBox(
                                                width: 220,
                                                child: Text(
                                                  r[key] ?? '',
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        if (importing && processed < total)
                          TextButton(
                            onPressed: cancelRequested
                                ? null
                                : () => setState(() => cancelRequested = true),
                            child: Text(
                              cancelRequested
                                  ? 'Скасування…'
                                  : 'Скасувати імпорт',
                            ),
                          ),
                        TextButton(
                          onPressed: importing
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text('Закрити'),
                        ),
                        FilledButton(
                          onPressed: ready ? import : null,
                          child: Text(
                            importing ? 'Імпортування…' : 'Імпортувати',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (dragging)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).scaffoldBackgroundColor.withValues(alpha: .96),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: context.archiveScheme.primary,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.upload_file_outlined,
                            size: 64,
                            color: context.archiveScheme.primary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Відпустіть файли Excel тут',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('Можна додати кілька .xlsx одночасно'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _columnLetter(int column) {
    var result = '';
    for (var n = column + 1; n > 0; n = (n - 1) ~/ 26) {
      result = String.fromCharCode(65 + (n - 1) % 26) + result;
    }
    return result;
  }

  Widget fileConfiguration(ImportFileConfiguration config) {
    final sheet = config.sheet;
    if (sheet == null) {
      return EmptyArchive(
        title: 'Не вдалося прочитати файл',
        message: config.error ?? 'Оберіть інший файл.',
      );
    }
    final fields = importFields(module)
        .where(
          (f) =>
              filter.isEmpty ||
              f.label.toLowerCase().contains(filter.toLowerCase()),
        )
        .toList();
    final sections = module.fields
        .map((f) => f.section)
        .toSet()
        .where((section) => fields.any((field) => field.section == section))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                config.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                key: ValueKey(
                  '${identityHashCode(config)}-${config.selectedSheet}',
                ),
                initialValue: config.selectedSheet,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Аркуш'),
                items: config.sheets.indexed
                    .map(
                      (s) =>
                          DropdownMenuItem(value: s.$1, child: Text(s.$2.name)),
                    )
                    .toList(),
                onChanged: importing
                    ? null
                    : (v) {
                        setState(() {
                          config.selectedSheet = v!;
                          config.mapping = service.autoMapping(
                            config.sheet!,
                            module,
                          );
                        });
                        scheduleValidation();
                      },
              ),
              const SizedBox(height: 10),
              TextField(
                key: ValueKey('filter-${identityHashCode(config)}'),
                onChanged: (v) => setState(() => filter = v),
                decoration: const InputDecoration(
                  labelText: 'Пошук полів',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            key: ValueKey(
              'import-sections-${identityHashCode(config)}-${config.selectedSheet}',
            ),
            primary: false,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final section = sections[index];
              final sectionFields = fields
                  .where((field) => field.section == section)
                  .toList();
              return ExpansionTile(
                key: PageStorageKey(
                  'import-section-${identityHashCode(config)}-${config.selectedSheet}-$section-${filter.isNotEmpty}',
                ),
                initiallyExpanded:
                    filter.isNotEmpty ||
                    [
                      'Номери справи',
                      'Інформація про справу',
                      'Учасники справи',
                    ].contains(section) ||
                    sectionFields.any(
                      (field) => config.mapping.containsValue(field.key),
                    ),
                tilePadding: EdgeInsets.zero,
                expandedAlignment: Alignment.centerLeft,
                expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                title: Text(
                  section,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                children: [
                  for (final field in sectionFields)
                    _mappingField(config, field),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _mappingField(ImportFileConfiguration config, ArchiveField field) {
    final sheet = config.sheet!;
    final value = config.mapping.entries
        .where((e) => e.value == field.key)
        .firstOrNull
        ?.key;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${field.label}${field.required ? ' *' : ''}',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<int>(
            key: ValueKey(
              '${identityHashCode(config)}-${config.selectedSheet}-${field.key}-$value',
            ),
            initialValue: value ?? -1,
            isExpanded: true,
            items: [
              const DropdownMenuItem(
                value: -1,
                child: Text('Не обрано'),
              ),
              for (final header in sheet.headers.entries)
                DropdownMenuItem(
                  value: header.key,
                  child: Text(
                    '${_columnLetter(header.key)} · ${header.value.text}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: importing
                ? null
                : (column) {
                    setState(() {
                      config.mapping.removeWhere(
                        (k, v) => v == field.key,
                      );
                      if (column != null && column >= 0) {
                        config.mapping[column] = field.key;
                      }
                    });
                    scheduleValidation();
                  },
          ),
        ],
      ),
    );
  }
}
