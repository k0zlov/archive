import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:archive_shared/archive_schema.dart';
import '../data/archive_repository.dart';
import '../data/file_actions.dart';
import 'theme.dart';

class AttachmentPanel extends StatefulWidget {
  const AttachmentPanel({
    super.key,
    required this.repository,
    this.record,
    this.pickFiles,
  });
  final ArchiveRepository repository;
  final CaseRecord? record;
  final Future<List<XFile>> Function()? pickFiles;
  @override
  State<AttachmentPanel> createState() => _AttachmentPanelState();
}

class _AttachmentPanelState extends State<AttachmentPanel> {
  bool busy = false;
  String? message;
  @override
  void initState() {
    super.initState();
    widget.repository.attachments.restore();
  }

  Future<void> run(Future<void> Function() action, String label) async {
    setState(() {
      busy = true;
      message = label;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) {
        showArchiveMessage(
          context,
          e is ArchiveFailure
              ? e.message
              : e is FileActionFailure
              ? e.message
              : 'Не вдалося виконати дію з файлом.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
          message = null;
        });
      }
    }
  }

  Future<void> addFiles() async {
    final selected = await (widget.pickFiles?.call() ?? openFiles());
    if (selected.isEmpty || !mounted) return;
    await run(() async {
      for (final file in selected) {
        if (mounted) setState(() => message = file.name);
        await widget.repository.attachments.upload(widget.record!, file);
      }
    }, 'Завантаження…');
  }

  Future<void> remove(Map<String, dynamic> file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Видалити файл?'),
        content: Text(file['fileName'] as String),
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
    if (confirmed != true || !mounted) return;
    await run(() async {
      await widget.repository.attachments.delete(file['id'] as int);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Файл видалено.'),
            action: SnackBarAction(
              label: 'Відновити',
              onPressed: () async {
                try {
                  await widget.repository.attachments.restoreFile(
                    file['id'] as int,
                  );
                } catch (e) {
                  if (mounted) {
                    showArchiveMessage(
                      context,
                      e is ArchiveFailure
                          ? e.message
                          : 'Не вдалося відновити файл.',
                    );
                  }
                }
              },
            ),
          ),
        );
      }
    }, 'Видалення…');
  }

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('record-attachments'),
    color: context.archiveColors.panel,
    padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
    child: ListenableBuilder(
      listenable: widget.repository.attachments,
      builder: (context, _) {
        final files = widget.repository.attachments.forRecord(
          widget.record?.id ?? -1,
        );
        final writable =
            widget.record != null &&
            widget.repository.online &&
            canWriteModule(widget.repository.profile, widget.record!.module);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.attach_file,
                  color: context.archiveScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Файли · ${files.length}',
                    style: TextStyle(
                      color: context.archiveScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (writable)
                  IconButton(
                    tooltip: 'Додати файли',
                    onPressed: busy ? null : addFiles,
                    icon: Icon(
                      Icons.add,
                      color: context.archiveScheme.onSurface,
                    ),
                  ),
              ],
            ),
            if (busy)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  message ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.archiveScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: files.isEmpty
                  ? Center(
                      child: Text(
                        widget.record == null
                            ? 'Збережіть справу, щоб додати файли.'
                            : 'Файлів поки немає',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.archiveScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : ListView.builder(
                      key: const ValueKey('record-attachments-scroll'),
                      primary: false,
                      physics: const ClampingScrollPhysics(),
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        final file = files[index];
                        final name = file['fileName'] as String;
                        final available =
                            widget.repository.online || file['cached'] == true;
                        return Container(
                          key: ValueKey('attachment-${file['id']}'),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: context.archiveScheme.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                name,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.archiveScheme.onSurface,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${_size(file['byteLength'] as int)}${file['cached'] == true ? ' · Збережено локально' : ''}',
                                style: TextStyle(
                                  color: context.archiveScheme.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (canOpenAttachment(name))
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      tooltip: 'Відкрити файл',
                                      onPressed: busy || !available
                                          ? null
                                          : () => run(
                                              () => handleAttachment(
                                                name,
                                                widget.repository.attachments
                                                    .content(file['id'] as int),
                                                open: true,
                                              ),
                                              'Відкриття…',
                                            ),
                                      icon: Icon(
                                        Icons.open_in_new,
                                        color: context.archiveScheme.primary,
                                        size: 17,
                                      ),
                                    ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    tooltip: 'Зберегти файл',
                                    onPressed: busy || !available
                                        ? null
                                        : () => run(
                                            () => handleAttachment(
                                              name,
                                              widget.repository.attachments
                                                  .content(file['id'] as int),
                                            ),
                                            'Збереження…',
                                          ),
                                    icon: Icon(
                                      Icons.download_outlined,
                                      color: context.archiveScheme.primary,
                                      size: 18,
                                    ),
                                  ),
                                  if (writable)
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      tooltip: 'Видалити файл',
                                      onPressed: busy
                                          ? null
                                          : () => remove(file),
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: context.archiveScheme.primary,
                                        size: 18,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    ),
  );
  String _size(int bytes) => bytes < 1024
      ? '$bytes Б'
      : bytes < 1024 * 1024
      ? '${(bytes / 1024).toStringAsFixed(0)} КБ'
      : '${(bytes / (1024 * 1024)).toStringAsFixed(1)} МБ';
}
