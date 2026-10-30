import 'package:flutter/material.dart';
import '../data/archive_repository.dart';
import 'theme.dart';

class ArchiveMaintenancePanel extends StatelessWidget {
  const ArchiveMaintenancePanel({super.key, required this.repository});
  final ArchiveRepository repository;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(top: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'Дані архіву',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          OutlinedButton.icon(
            onPressed: repository.online
                ? () => showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        _MaintenanceDialog(repository: repository, full: false),
                  )
                : null,
            icon: const Icon(Icons.delete_sweep_outlined, size: 18),
            label: const Text('Видалити всі справи'),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: context.archiveScheme.error,
            ),
            onPressed: repository.online
                ? () => showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        _MaintenanceDialog(repository: repository, full: true),
                  )
                : null,
            icon: const Icon(Icons.delete_forever_outlined, size: 18),
            label: const Text('Очистити архів'),
          ),
        ],
      ),
    ),
  );
}

class _MaintenanceDialog extends StatefulWidget {
  const _MaintenanceDialog({required this.repository, required this.full});
  final ArchiveRepository repository;
  final bool full;
  @override
  State<_MaintenanceDialog> createState() => _MaintenanceDialogState();
}

class _MaintenanceDialogState extends State<_MaintenanceDialog> {
  final confirmation = TextEditingController();
  Map? counts;
  @override
  void initState() {
    super.initState();
    loadSummary();
  }

  Future<void> loadSummary() async {
    try {
      final value = await widget.repository.requestTo(
        'archiveMaintenance',
        'summary',
        const {},
      );
      if (mounted) setState(() => counts = value as Map);
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Не вдалося отримати кількість записів.');
      }
    }
  }

  bool busy = false;
  String? error;
  String get phrase => widget.full ? 'ОЧИСТИТИ АРХІВ' : 'ВИДАЛИТИ ВСІ СПРАВИ';
  @override
  void dispose() {
    confirmation.dispose();
    super.dispose();
  }

  Future<void> clear() async {
    if (busy || confirmation.text != phrase) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.repository.requestTo(
        'archiveMaintenance',
        widget.full ? 'clearArchive' : 'clearRecords',
        {'confirmation': confirmation.text},
      );
      await widget.repository.clear();
      await widget.repository.refresh();
      if (mounted) {
        Navigator.of(context).pop();
        showArchiveMessage(
          context,
          widget.full ? 'Архів очищено.' : 'Усі справи видалено.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          busy = false;
          error = e is ArchiveFailure
              ? e.message
              : 'Не вдалося підтвердити очищення. Оновіть дані та перевірте стан архіву.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: AlertDialog(
      title: Text(widget.full ? 'Очистити архів?' : 'Видалити всі справи?'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.full
                    ? 'Буде безповоротно видалено всі справи, прикріплені файли, номенклатури, дані імпорту та журнал аудиту.'
                    : 'Буде безповоротно видалено всі справи в обох розділах, прикріплені файли та дані імпорту. Номенклатури й журнал аудиту збережуться.',
              ),
              const SizedBox(height: 12),
              const Text('Облікові записи та права користувачів збережуться.'),
              const SizedBox(height: 16),
              if (counts == null && error == null)
                const Text('Підрахунок записів…'),
              if (counts != null)
                Text(
                  'Справ: ${counts!['records']} · Файлів: ${counts!['files']}'
                  '${widget.full ? '\nНоменклатур: ${counts!['documents']} · Подій аудиту: ${counts!['audit']}' : ''}',
                ),
              const SizedBox(height: 20),
              Text('Для підтвердження введіть: $phrase'),
              const SizedBox(height: 10),
              TextField(
                key: const ValueKey('maintenance-confirmation'),
                controller: confirmation,
                enabled: !busy,
                autocorrect: false,
                enableSuggestions: false,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Підтвердження'),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    error!,
                    style: TextStyle(color: context.archiveScheme.error),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Скасувати'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: context.archiveScheme.error,
            foregroundColor: context.archiveScheme.onError,
          ),
          onPressed: busy || counts == null || confirmation.text != phrase
              ? null
              : clear,
          child: Text(
            busy
                ? 'Очищення…'
                : widget.full
                ? 'Очистити назавжди'
                : 'Видалити назавжди',
          ),
        ),
      ],
    ),
  );
}
