import 'package:flutter/material.dart';
import 'package:archive_shared/archive_schema.dart';
import '../data/archive_repository.dart';
import 'archive_controller.dart';
import 'theme.dart';
import 'participants_editor.dart';
import 'attachment_panel.dart';
import 'record_layout.dart';

Future<void> editArchiveRecord(
  BuildContext context,
  ArchiveController controller, {
  CaseRecord? record,
}) async {
  final saved = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _RecordEditor(controller: controller, record: record),
  );
  if (saved == true) {
    await controller.loadPage();
    if (context.mounted && controller.repository.lastSaveMerged) {
      showArchiveMessage(context, 'Дані об’єднано з наявною справою.');
    }
  }
}

class _RecordEditor extends StatefulWidget {
  const _RecordEditor({required this.controller, this.record});
  final ArchiveController controller;
  final CaseRecord? record;
  @override
  State<_RecordEditor> createState() => _RecordEditorState();
}

class _RecordEditorState extends State<_RecordEditor> {
  late final module = widget.record?.module ?? widget.controller.module;
  late final fields = module.fields;
  late final inputs = {
    for (final f in fields)
      f.key: TextEditingController(
        text: f.kind == FieldKind.date
            ? displayDate(widget.record?.values[f.key] ?? '')
            : widget.record?.values[f.key] ?? '',
      ),
  };
  late List<CaseParticipant> participants = caseParticipants(
    widget.record?.values ?? {},
  );
  final scrollController = ScrollController();
  bool saving = false;
  String? error;
  @override
  void dispose() {
    scrollController.dispose();
    for (final c in inputs.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await widget.controller.repository.save(module, {
        for (final entry in inputs.entries) entry.key: entry.value.text,
        if (module == ArchiveModule.court) ...participantValues(participants),
      }, widget.record);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e is FormatException
              ? e.message
              : e is ArchiveFailure
              ? e.message
              : 'Не вдалося зберегти. Перевірте зв’язок із сервером та повторіть спробу.';
          saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.all(20),
    clipBehavior: Clip.antiAlias,
    child: SizedBox(
      width: 1210,
      height: MediaQuery.sizeOf(context).height * .9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.record == null
                            ? 'Нова справа'
                            : 'Редагування справи',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        module.label,
                        style: TextStyle(
                          color: context.archiveScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Закрити',
                  onPressed: saving ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          if (error != null)
            Container(
              color: context.archiveScheme.errorContainer,
              padding: const EdgeInsets.all(18),
              child: Text(
                error!,
                style: TextStyle(color: context.archiveScheme.error),
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: RecordDialogBody(
              information: SingleChildScrollView(
                key: const ValueKey('record-editor-scroll'),
                controller: scrollController,
                primary: false,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: LayoutBuilder(
                  builder: (context, constraints) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final section
                          in fields.map((f) => f.section).toSet())
                        ExpansionTile(
                          key: ValueKey('record-section-$section'),
                          maintainState: true,
                          expandedCrossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          expandedAlignment: Alignment.centerLeft,
                          initiallyExpanded:
                              section == 'Інформація про справу' ||
                              section == 'Номери справи',
                          tilePadding: EdgeInsets.zero,
                          title: Text(
                            section,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          children: [
                            if (section == 'Учасники справи')
                              ParticipantsEditor(
                                initial: participants,
                                enabled: !saving,
                                onChanged: (value) => participants = value,
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Wrap(
                                alignment: WrapAlignment.start,
                                spacing: 20,
                                runSpacing: 20,
                                children: [
                                  for (final f in fields.where(
                                    (f) =>
                                        f.section == section &&
                                        ![
                                          'participants',
                                          'proceedingNumber',
                                        ].contains(f.key),
                                  ))
                                    SizedBox(
                                      width:
                                          constraints.maxWidth > 640 &&
                                              f.kind != FieldKind.multiline
                                          ? (constraints.maxWidth - 20) / 2
                                          : constraints.maxWidth,
                                      child: f.kind == FieldKind.choice
                                          ? DropdownButtonFormField<String>(
                                              initialValue:
                                                  inputs[f.key]!.text.isEmpty
                                                  ? null
                                                  : inputs[f.key]!.text,
                                              isExpanded: true,
                                              decoration: InputDecoration(
                                                labelText: f.label,
                                              ),
                                              items: [
                                                const DropdownMenuItem(
                                                  value: '',
                                                  child: Text('Не зазначено'),
                                                ),
                                                ...f.options.map(
                                                  (o) => DropdownMenuItem(
                                                    value: o,
                                                    child: Text(o),
                                                  ),
                                                ),
                                              ],
                                              onChanged: saving
                                                  ? null
                                                  : (v) => inputs[f.key]!.text =
                                                        v ?? '',
                                            )
                                          : TextField(
                                              key: ValueKey(
                                                'record-field-${f.key}',
                                              ),
                                              controller: inputs[f.key],
                                              enabled: !saving,
                                              maxLines:
                                                  f.kind == FieldKind.multiline
                                                  ? 3
                                                  : 1,
                                              keyboardType:
                                                  f.kind == FieldKind.number
                                                  ? TextInputType.number
                                                  : f.kind ==
                                                        FieldKind.multiline
                                                  ? TextInputType.multiline
                                                  : TextInputType.text,
                                              decoration: InputDecoration(
                                                labelText:
                                                    '${f.label}${f.required ? ' *' : ''}',
                                                hintText:
                                                    f.kind == FieldKind.date
                                                    ? 'ДД.ММ.РРРР'
                                                    : null,
                                                suffixIcon:
                                                    f.kind != FieldKind.date
                                                    ? null
                                                    : IconButton(
                                                        tooltip: 'Обрати дату',
                                                        onPressed: () async {
                                                          final date = await showDatePicker(
                                                            context: context,
                                                            initialDate:
                                                                parseArchiveDate(
                                                                  inputs[f.key]!
                                                                      .text,
                                                                ) ??
                                                                DateTime.now(),
                                                            firstDate: DateTime(
                                                              1700,
                                                            ),
                                                            lastDate: DateTime(
                                                              2300,
                                                            ),
                                                          );
                                                          if (date != null) {
                                                            inputs[f.key]!
                                                                    .text =
                                                                displayDate(
                                                                  isoDate(date),
                                                                );
                                                          }
                                                        },
                                                        icon: const Icon(
                                                          Icons
                                                              .calendar_today_outlined,
                                                          size: 18,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              files: AttachmentPanel(
                repository: widget.controller.repository,
                record: widget.record,
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(context),
                  child: const Text('Скасувати'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: saving ? null : save,
                  child: Text(saving ? 'Збереження…' : 'Зберегти справу'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> showArchiveRecord(
  BuildContext context,
  ArchiveController controller,
  CaseRecord record,
) async {
  final action = await showDialog<String>(
    context: context,
    builder: (_) => _RecordCard(controller: controller, record: record),
  );
  if (action == 'edit' && context.mounted) {
    await editArchiveRecord(context, controller, record: record);
  }
  if (action == 'delete' && context.mounted) {
    await deleteArchiveItem(context, controller, record: record);
  }
}

class _RecordCard extends StatefulWidget {
  const _RecordCard({required this.controller, required this.record});
  final ArchiveController controller;
  final CaseRecord record;
  @override
  State<_RecordCard> createState() => _RecordCardState();
}

class _RecordCardState extends State<_RecordCard> {
  final scrollController = ScrollController();
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 1130,
        height: MediaQuery.sizeOf(context).height * .88,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.reference,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(r.module.label),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Закрити',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: RecordDialogBody(
                information: SingleChildScrollView(
                  key: const ValueKey('record-view-scroll'),
                  controller: scrollController,
                  primary: false,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final section
                          in r.module.fields.map((f) => f.section).toSet()) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 14),
                          child: Text(
                            section.toUpperCase(),
                            style: TextStyle(
                              color: context.archiveScheme.primary,
                              letterSpacing: 1.3,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        for (final f in r.module.fields.where(
                          (f) =>
                              f.section == section &&
                              (r.values[f.key] ?? '').isNotEmpty &&
                              f.key != 'participants' &&
                              !(f.key == 'proceedingNumber' &&
                                  r.values.containsKey('participantDetails')),
                        ))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  f.label,
                                  style: TextStyle(
                                    color:
                                        context.archiveScheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                SelectableText(
                                  f.kind == FieldKind.date
                                      ? displayDate(r.values[f.key]!)
                                      : r.values[f.key]!,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (section == 'Учасники справи')
                          ParticipantsView(
                            participants: caseParticipants(r.values),
                          ),
                      ],
                    ],
                  ),
                ),
                files: AttachmentPanel(
                  repository: widget.controller.repository,
                  record: widget.record,
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.controller.repository.online &&
                      canWriteModule(
                        widget.controller.repository.profile,
                        r.module,
                      )) ...[
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context, 'delete'),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Видалити'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () => Navigator.pop(context, 'edit'),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Редагувати'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> deleteArchiveItem(
  BuildContext context,
  ArchiveController controller, {
  CaseRecord? record,
  Map<String, dynamic>? document,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        record != null ? 'Видалити справу?' : 'Видалити номенклатуру?',
      ),
      content: Text(
        '${record?.reference ?? document?['title']}\nЗапис буде приховано з архіву. Його можна відновити через журнал аудиту.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Скасувати'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Видалити'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    if (record != null) {
      await controller.repository.deleteRecord(record);
    } else {
      await controller.repository.deleteDocument(document!['id'] as int);
    }
    await controller.loadPage();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Запис видалено.'),
          action: SnackBarAction(
            label: 'Відновити',
            onPressed: () async {
              try {
                if (record != null) {
                  await controller.repository.restoreRecord(record.id);
                } else {
                  await controller.repository.restoreDocument(
                    document!['id'] as int,
                  );
                }
                await controller.loadPage();
              } catch (e) {
                if (context.mounted) {
                  showArchiveMessage(
                    context,
                    e is ArchiveFailure
                        ? e.message
                        : 'Не вдалося відновити запис.',
                  );
                }
              }
            },
          ),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      showArchiveMessage(
        context,
        e is ArchiveFailure ? e.message : 'Не вдалося видалити запис.',
      );
    }
  }
}
