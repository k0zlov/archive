import 'theme.dart';
import 'package:flutter/material.dart';
import '../data/archive_activity.dart';

String _statusLabel(String label) {
  if (label.contains('Збереження справи')) return 'Збереження справи…';
  if (label.toLowerCase().contains('імпорт') || label.contains('Excel')) {
    return 'Імпорт…';
  }
  if (label.contains('Видалення')) return 'Видалення…';
  if (label.contains('Відновлення')) return 'Відновлення…';
  if (label.contains('Відкриття') ||
      label.contains('Завантаження') ||
      label.contains('Читання')) {
    return 'Завантаження…';
  }
  return 'Оновлення…';
}

class ArchiveStatusText extends StatelessWidget {
  const ArchiveStatusText({
    super.key,
    required this.activity,
    required this.online,
    this.updatedAt,
  });
  final ArchiveActivity activity;
  final bool online;
  final DateTime? updatedAt;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: activity,
    builder: (context, _) {
      final task = activity.current;
      final date = updatedAt?.toLocal();
      final text = task != null
          ? _statusLabel(task.label)
          : !online
          ? 'Без з’єднання'
          : date == null
          ? ''
          : 'Оновлено о ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      return Text(
        text,
        key: const ValueKey('archive-status'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 11,
          color: context.archiveScheme.onSurfaceVariant,
        ),
      );
    },
  );
}
