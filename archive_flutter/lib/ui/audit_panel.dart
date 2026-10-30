import 'dart:async';
import 'package:flutter/material.dart';
import 'package:archive_shared/archive_schema.dart';
import '../data/archive_repository.dart';
import 'archive_controller.dart';
import 'theme.dart';

const auditActionLabels = {
  'record.create': 'Створення справи',
  'record.update': 'Редагування справи',
  'record.merge': 'Об’єднання справ',
  'record.delete': 'Видалення справи',
  'record.restore': 'Відновлення справи',
  'record.import.create': 'Створення з Excel',
  'record.import.update': 'Доповнення з Excel',
  'record.identity-migration': 'Оновлення ідентифікації справи',
  'attachment.create': 'Додавання файлу до справи',
  'attachment.delete': 'Видалення файлу справи',
  'attachment.restore': 'Відновлення файлу справи',
  'attachment.move': 'Перенесення файлу при об’єднанні справ',
  'document.create': 'Додавання номенклатури',
  'document.delete': 'Видалення номенклатури',
  'document.restore': 'Відновлення номенклатури',
  'member.create': 'Реєстрація користувача',
  'member.bootstrap': 'Призначення першого адміністратора',
  'member.access': 'Зміна прав доступу',
  'member.password.change': 'Зміна пароля',
  'member.password.reset': 'Скидання пароля',
  'import.begin': 'Початок імпорту',
  'import.commit': 'Завершення імпорту',
  'import.cancel': 'Скасування імпорту',
};
const _detailLabels = {
  'sources': 'Файли',
  'replaceExisting': 'Замінювати значення',
  'count': 'Справ',
  'rows': 'Записів у файлах',
  'created': 'Створено',
  'updated': 'Доповнено',
  'unchanged': 'Без змін',
  'merged': 'Об’єднано записів',
  'mergedInto': 'Об’єднано зі справою',
};

class AuditPanel extends StatefulWidget {
  const AuditPanel({super.key, required this.controller});
  final ArchiveController controller;
  @override
  State<AuditPanel> createState() => _AuditPanelState();
}

class _AuditPanelState extends State<AuditPanel> {
  final entries = <Map<String, dynamic>>[];
  Timer? debounce;
  String query = '';
  String? error;
  bool loading = false;
  bool hasMore = false;
  int revision = 0;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  Future<void> load({bool more = false}) async {
    final request = ++revision;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      if (!widget.controller.repository.online) {
        final filtered = widget.controller.repository.audit
            .where(
              (e) =>
                  query.trim().isEmpty ||
                  '${e['actor']} ${e['target']}'.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
        if (mounted && request == revision) {
          setState(() {
            entries
              ..clear()
              ..addAll(filtered);
            hasMore = false;
          });
        }
        return;
      }
      final result =
          await widget.controller.repository.request('auditEntries', {
                'beforeId': more && entries.isNotEmpty ? entries.last['id'] : 0,
                'query': query,
              })
              as Map;
      if (!mounted || request != revision) return;
      setState(() {
        if (!more) entries.clear();
        entries.addAll(
          (result['items'] as List).map(
            (e) => Map<String, dynamic>.from(e as Map),
          ),
        );
        hasMore = result['hasMore'] == true;
      });
    } catch (e) {
      if (mounted && request == revision) {
        setState(
          () => error = e is ArchiveFailure
              ? e.message
              : 'Не вдалося завантажити журнал.',
        );
      }
    } finally {
      if (mounted && request == revision) setState(() => loading = false);
    }
  }

  String time(dynamic value) {
    final d = DateTime.tryParse('$value')?.toLocal();
    if (d == null) return '$value';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }

  Future<void> detail(Map<String, dynamic> entry) async {
    final before = Map<String, dynamic>.from(entry['before'] as Map? ?? {});
    final after = Map<String, dynamic>.from(entry['after'] as Map? ?? {});
    final details = Map<String, dynamic>.from(entry['details'] as Map? ?? {});
    final oldValues = Map<String, dynamic>.from(
      before['values'] as Map? ?? before,
    );
    final newValues = Map<String, dynamic>.from(
      after['values'] as Map? ?? after,
    );
    final fields = {
      for (final m in ArchiveModule.values)
        for (final f in m.fields) f.key: f.label,
      'role': 'Роль',
      'email': 'Електронна пошта',
      'displayName': 'Ім’я',
      'managementAccess': 'Управлінська документація',
      'courtAccess': 'Судові справи',
      'deletedAt': 'Дата видалення',
      'title': 'Назва',
      'fileName': 'Файл',
      'year': 'Рік',
    };
    final changed = {...oldValues.keys, ...newValues.keys}
        .where(
          (k) =>
              oldValues[k] != newValues[k] &&
              ![
                'id',
                'participantDetails',
                'module',
                'version',
                'updatedAt',
                'userId',
                'kind',
              ].contains(k),
        )
        .toList();
    final restore = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(auditActionLabels[entry['action']] ?? '${entry['action']}'),
        content: SizedBox(
          width: 760,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                SelectableText(
                  '${time(entry['at'])}\n${entry['actor']}\nЗапис: ${entry['target']}',
                ),
                const SizedBox(height: 20),
                if (changed.isNotEmpty)
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(1.5),
                      2: FlexColumnWidth(1.5),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.top,
                    children: [
                      const TableRow(
                        children: [
                          Text(
                            'Поле',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'До',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Після',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      for (final key in changed)
                        TableRow(
                          children: [
                            for (final value in [
                              fields[key] ??
                                  const {
                                    'recordId': 'Справа',
                                    'fileName': 'Назва файлу',
                                    'byteLength': 'Розмір файлу',
                                    'createdAt': 'Додано',
                                  }[key] ??
                                  key,
                              oldValues[key] ?? '—',
                              newValues[key] ?? '—',
                            ])
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  0,
                                  10,
                                  14,
                                  10,
                                ),
                                child: SelectableText(
                                  value == true
                                      ? 'Так'
                                      : value == false
                                      ? 'Ні'
                                      : '$value',
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                if (changed.isEmpty)
                  const Text('Детальні значення для цієї події відсутні.'),
                for (final e in details.entries)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SelectableText(
                      '${_detailLabels[e.key] ?? e.key}: ${e.value is List
                          ? (e.value as List).join(', ')
                          : e.value == true
                          ? 'Так'
                          : e.value == false
                          ? 'Ні'
                          : e.value}',
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрити'),
          ),
          if (widget.controller.repository.online &&
              [
                'record.delete',
                'document.delete',
                'attachment.delete',
              ].contains(entry['action']))
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.restore),
              label: const Text('Відновити'),
            ),
        ],
      ),
    );
    if (restore == true) {
      try {
        final id = int.parse('${entry['target']}');
        if (entry['action'] == 'record.delete') {
          await widget.controller.repository.restoreRecord(id);
        } else if (entry['action'] == 'attachment.delete') {
          await widget.controller.repository.attachments.restoreFile(id);
        } else {
          await widget.controller.repository.restoreDocument(id);
        }
        await widget.controller.loadPage();
        await load();
        if (mounted) showArchiveMessage(context, 'Запис відновлено.');
      } catch (e) {
        if (mounted) {
          showArchiveMessage(
            context,
            e is ArchiveFailure ? e.message : 'Не вдалося відновити запис.',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Пошук за електронною поштою або номером запису…',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  query = value;
                  revision++;
                  debounce?.cancel();
                  debounce = Timer(
                    const Duration(milliseconds: 300),
                    () => load(),
                  );
                },
              ),
            ),
            IconButton(
              tooltip: 'Оновити журнал',
              onPressed: loading ? null : () => load(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),

        if (error != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              error!,
              style: TextStyle(color: context.archiveScheme.error),
            ),
          ),
        const SizedBox(height: 12),
        Expanded(
          child: entries.isEmpty && !loading
              ? const EmptyArchive(
                  title: 'Подій поки немає',
                  message: 'Зміни автоматично з’являтимуться тут.',
                )
              : ListView.builder(
                  itemCount: entries.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == entries.length) {
                      return TextButton(
                        onPressed: loading ? null : () => load(more: true),
                        child: const Text('Показати ще'),
                      );
                    }
                    final e = entries[index];
                    final snapshot = e['after'] as Map? ?? {};
                    final values = snapshot['values'] as Map? ?? {};
                    final reference =
                        values['caseNumber'] ??
                        values['proceedingNumber'] ??
                        values['caseIndex'] ??
                        snapshot['title'] ??
                        e['target'];
                    return Card(
                      elevation: 0,
                      color: context.archiveScheme.surface,
                      child: ListTile(
                        onTap: () => detail(e),
                        leading: Icon(
                          Icons.history,
                          color: context.archiveScheme.primary,
                        ),
                        title: Text(
                          '${auditActionLabels[e['action']] ?? e['action']} · $reference',
                        ),
                        subtitle: Text(
                          '${time(e['at'])} · ${e['actor']}',
                          style: const TextStyle(height: 1.7),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
