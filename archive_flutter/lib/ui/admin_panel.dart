import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/auth_gateway.dart';
import 'package:archive_shared/archive_schema.dart';
import '../data/archive_repository.dart';
import 'theme.dart';
import 'archive_maintenance_panel.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key, required this.repository});
  final ArchiveRepository repository;
  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  List<Map<String, dynamic>>? members;
  String? error;
  @override
  void initState() {
    super.initState();
    widget.repository.memberChanges.addListener(updateMembers);
    load();
  }

  void updateMembers() {
    if (mounted) setState(() => members = List.of(widget.repository.members));
  }

  @override
  void dispose() {
    widget.repository.memberChanges.removeListener(updateMembers);
    super.dispose();
  }

  Future<void> load() async {
    if (!widget.repository.online) {
      setState(() => members = List.of(widget.repository.members));
      return;
    }
    try {
      await widget.repository.refreshMembers();
      final data = widget.repository.members;
      if (mounted) {
        setState(() {
          members = data
              .map((v) => Map<String, dynamic>.from(v as Map))
              .toList();
          error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Не вдалося завантажити користувачів.');
      }
    }
  }

  Future<void> edit(Map<String, dynamic> member) async {
    var role = member['role'] as String;
    var management = member['managementAccess'] == true;
    var court = member['courtAccess'] == true;
    var saving = false;
    String? saveError;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text('Права користувача'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('${member['login'] ?? member['email']}'),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(labelText: 'Роль'),
                    items: roleLabels.entries
                        .map(
                          (r) => DropdownMenuItem(
                            value: r.key,
                            child: Text(r.value),
                          ),
                        )
                        .toList(),
                    onChanged: saving ? null : (v) => update(() => role = v!),
                  ),
                  const SizedBox(height: 16),
                  if (role == 'admin')
                    const Text(
                      'Адміністратор має доступ до обох модулів та керує правами користувачів.',
                    ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Управлінська документація'),
                    value: management,
                    onChanged: saving || role == 'admin'
                        ? null
                        : (v) => update(() => management = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Судові справи'),
                    value: court,
                    onChanged: saving || role == 'admin'
                        ? null
                        : (v) => update(() => court = v),
                  ),
                  if (saveError != null)
                    Text(
                      saveError!,
                      style: TextStyle(color: context.archiveScheme.error),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(context),
              child: const Text('Скасувати'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      update(() {
                        saving = true;
                        saveError = null;
                      });
                      try {
                        await widget.repository.request('setMemberAccess', {
                          'memberId': member['id'],
                          'role': role,
                          'managementAccess': management,
                          'courtAccess': court,
                        });
                        if (context.mounted) Navigator.pop(context, true);
                      } catch (_) {
                        if (context.mounted) {
                          update(() {
                            saving = false;
                            saveError = 'Не вдалося змінити права.';
                          });
                        }
                      }
                    },
              child: Text(saving ? 'Збереження…' : 'Зберегти права'),
            ),
          ],
        ),
      ),
    );
    if (saved == true) await load();
  }

  Future<void> resetPassword(Map<String, dynamic> member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Скинути пароль?'),
        content: Text(
          'Користувач ${member['login'] ?? member['email']} отримає тимчасовий пароль. Поточні сеанси буде завершено.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Скасувати'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Скинути пароль'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      final temporary = await ServerpodAuthGateway().resetPassword(
        member['id'] as int,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Тимчасовий пароль'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(temporary, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 16),
              const Text(
                'Передайте його користувачу. Після входу він має створити власний пароль.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Clipboard.setData(ClipboardData(text: temporary)),
              child: const Text('Копіювати'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Готово'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) showArchiveMessage(context, authErrorMessage(e));
    }
  }

  final deleting = <int>{};
  Future<void> deleteMember(Map<String, dynamic> member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Видалити користувача?'),
        content: Text(
          'Обліковий запис ${member['login'] ?? member['email']} буде видалено. Усі його сеанси буде завершено. Історія змін справ збережеться.',
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
    if (confirmed != true || !mounted) return;
    final id = member['id'] as int;
    setState(() => deleting.add(id));
    try {
      await widget.repository.client.account.deleteMember(id);
      await load();
    } catch (e) {
      if (mounted) showArchiveMessage(context, authErrorMessage(e));
    } finally {
      if (mounted) setState(() => deleting.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return EmptyArchive(
        title: error!,
        message: 'Спробуйте оновити список.',
        action: OutlinedButton(onPressed: load, child: const Text('Оновити')),
      );
    }
    if (members == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.repository.online)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Локальна копія користувачів. Зміна прав доступна після підключення до сервера.',
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Нові користувачі очікують підтвердження. Читачі переглядають дані, редактори можуть додавати та змінювати справи.',
                  style: TextStyle(
                    height: 1.6,
                    color: context.archiveScheme.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Оновити користувачів',
                onPressed: load,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: members!.length,
            separatorBuilder: (_, i) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final member = members![i];
              final own =
                  member['userId'] == widget.repository.profile['userId'];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: context.archiveColors.subtleSurface,
                  child: Icon(
                    member['role'] == 'pending'
                        ? Icons.person_add_alt_outlined
                        : Icons.person_outline,
                    color: context.archiveScheme.primary,
                  ),
                ),
                title: Text('${member['login'] ?? member['email']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${roleLabels[member['role']]}${own ? ' · Ваш обліковий запис' : ''}',
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Text(
                          widget.repository.online
                              ? (member['online'] == true
                                    ? '● Онлайн'
                                    : '○ Не в мережі')
                              : 'Статус невідомий',
                          style: TextStyle(
                            color:
                                widget.repository.online &&
                                    member['online'] == true
                                ? context.archiveScheme.primary
                                : context.archiveScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'Активні сеанси: ${widget.repository.online ? member['activeSessions'] ?? 0 : '—'}',
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Видалити користувача',
                      onPressed:
                          own ||
                              !widget.repository.online ||
                              deleting.contains(member['id'])
                          ? null
                          : () => deleteMember(member),
                      icon: const Icon(Icons.person_remove_outlined),
                    ),
                    IconButton(
                      tooltip: 'Скинути пароль',
                      onPressed: own || !widget.repository.online
                          ? null
                          : () => resetPassword(member),
                      icon: const Icon(Icons.lock_reset_outlined),
                    ),
                    IconButton(
                      tooltip: 'Змінити права',
                      onPressed: own || !widget.repository.online
                          ? null
                          : () => edit(member),
                      icon: const Icon(Icons.manage_accounts_outlined),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (widget.repository.profile['role'] == 'admin')
          ArchiveMaintenancePanel(repository: widget.repository),
      ],
    );
  }
}
