import 'dart:async';
import 'package:flutter/material.dart';
import 'package:archive_shared/archive_schema.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import '../client.dart';
import '../data/archive_repository.dart';
import '../data/cache_store.dart';
import '../data/file_actions.dart';
import '../data/workbook_service.dart';
import 'admin_panel.dart';
import 'audit_panel.dart';
import 'archive_controller.dart';
import 'import_dialog.dart';
import 'nomenclature_dialog.dart';
import 'record_dialogs.dart';
import 'theme.dart';
import 'archive_status_text.dart';
import 'password_dialog.dart';
import 'server_settings_dialog.dart';
import '../data/updates/windows_updates.dart';

class ArchiveShell extends StatefulWidget {
  const ArchiveShell({super.key, required this.userId, this.controller});
  final String userId;
  final ArchiveController? controller;
  @override
  State<ArchiveShell> createState() => _ArchiveShellState();
}

class _ArchiveShellState extends State<ArchiveShell> {
  ArchiveController? controller;
  VoidCallback? unregisterUpdates;
  String page = 'overview';
  ArchiveModule inventoryModule = ArchiveModule.court;
  String inventoryKind = 'Тривале';
  bool signingOut = false;
  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      controller = widget.controller;
      registerUpdates();
    } else {
      initialize();
    }
  }

  Future<void> initialize() async {
    final source = client;
    final address = serverConnection.url;
    final repo = ArchiveRepository(
      client: source,
      store: createCacheStore(),
      server: address,
      userId: widget.userId,
    );
    if (!mounted) return;
    setState(() => controller = ArchiveController(repo));
    registerUpdates();
    unawaited(controller!.initialize());
  }

  void registerUpdates() {
    final c = controller!;
    unregisterUpdates = windowsUpdates?.registerPreparation(
      c.prepareForUpdate,
      c.resumeAfterServerChange,
    );
  }

  @override
  void dispose() {
    unregisterUpdates?.call();
    if (widget.controller == null) controller?.dispose();
    super.dispose();
  }

  Future<void> signOut() async {
    if (signingOut) return;
    setState(() => signingOut = true);
    try {
      await controller!.repository.clear();
      await controller!.repository.client.auth.signOutDevice();
    } catch (_) {
      if (mounted) {
        showArchiveMessage(
          context,
          'Не вдалося завершити вихід. Спробуйте ще раз.',
        );
      }
    } finally {
      if (mounted) setState(() => signingOut = false);
    }
  }

  Future<void> openSettings() async {
    final c = controller;
    final generation = serverConnection.generation;
    await showServerSettings(context, beforeSwitch: c?.prepareServerChange);
    if (mounted && generation == serverConnection.generation) {
      c?.resumeAfterServerChange();
    }
  }

  void navigate(String target, [ArchiveModule? module]) {
    setState(() => page = target);
    if (module != null) controller!.setModule(module);
  }

  String get title => switch (page) {
    'records' => controller!.module.label,
    'documents' => 'Номенклатура справ',
    'inventories' => 'Описи справ',
    'admin' => 'Користувачі та доступ',
    'audit' => 'Журнал аудиту',
    _ => 'Огляд',
  };

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (c == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final repo = c.repository;
        if (repo.profile['passwordChangeRequired'] == true) {
          return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  onPressed: openSettings,
                  tooltip: 'Налаштування',
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: PasswordChangeForm(
                  requiredChange: true,
                  onChanged: c.refresh,
                  onCancel: signOut,
                ),
              ),
            ),
          );
        }
        final active = [
          'reader',
          'editor',
          'admin',
        ].contains(repo.profile['role']);
        Widget sidebar({bool drawer = false}) => Container(
          color: archiveInk,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 4, 12, 36),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_outlined,
                        color: archiveAccent,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Архів',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 14, bottom: 12),
                  child: Text(
                    'РОБОЧИЙ ПРОСТІР',
                    style: TextStyle(
                      color: Color(0xFF90AC9D),
                      fontSize: 10,
                      letterSpacing: 1.8,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      nav(
                        'Огляд',
                        Icons.grid_view_outlined,
                        page == 'overview',
                        () => navigate('overview'),
                        drawer,
                      ),
                      for (final m in ArchiveModule.values.where(
                        (m) => canReadModule(repo.profile, m),
                      ))
                        nav(
                          m.label,
                          m == ArchiveModule.court
                              ? Icons.balance_outlined
                              : Icons.folder_copy_outlined,
                          page == 'records' && c.module == m,
                          () => navigate('records', m),
                          drawer,
                        ),
                      if (canReadModule(repo.profile, ArchiveModule.management))
                        nav(
                          'Номенклатура',
                          Icons.menu_book_outlined,
                          page == 'documents',
                          () => navigate('documents'),
                          drawer,
                        ),
                      if (active)
                        nav(
                          'Описи справ',
                          Icons.list_alt_outlined,
                          page == 'inventories',
                          () => navigate('inventories'),
                          drawer,
                        ),
                      if (repo.profile['role'] == 'admin') ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 16,
                          ),
                          child: Divider(color: Color(0xFF3C584A)),
                        ),
                        nav(
                          'Користувачі та доступ',
                          Icons.manage_accounts_outlined,
                          page == 'admin',
                          () => navigate('admin'),
                          drawer,
                        ),
                        nav(
                          'Журнал аудиту',
                          Icons.history,
                          page == 'audit',
                          () => navigate('audit'),
                          drawer,
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            repo.online
                                ? Icons.cloud_done_outlined
                                : Icons.cloud_off_outlined,
                            size: 18,
                            color: archiveAccent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              repo.online ? 'Підключено' : 'Локальна копія',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Змінити пароль',
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(
                              Icons.key_outlined,
                              size: 18,
                              color: Color(0xFFB9C9BF),
                            ),
                            onPressed: repo.online
                                ? () => showPasswordDialog(context, c.refresh)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        repo.profile['login'] as String? ??
                            repo.profile['email'] as String? ??
                            'Завантаження…',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFB9C9BF),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        roleLabels[repo.profile['role']] ?? '',
                        style: const TextStyle(
                          color: Color(0xFFB9C9BF),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: signingOut ? null : openSettings,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFB9C9BF),
                  ),
                  icon: const Icon(Icons.settings_outlined, size: 17),
                  label: const Text('Налаштування'),
                ),
                TextButton.icon(
                  onPressed: signingOut ? null : signOut,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFB9C9BF),
                  ),
                  icon: const Icon(Icons.logout, size: 17),
                  label: const Text('Вийти'),
                ),
              ],
            ),
          ),
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;
            return Scaffold(
              drawer: wide ? null : Drawer(child: sidebar(drawer: true)),
              body: Row(
                children: [
                  if (wide) SizedBox(width: 248, child: sidebar()),
                  Expanded(
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: wide ? 34 : 18,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: context.archiveScheme.outlineVariant,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                if (!wide)
                                  Builder(
                                    builder: (context) => IconButton(
                                      tooltip: 'Відкрити меню',
                                      onPressed: () =>
                                          Scaffold.of(context).openDrawer(),
                                      icon: const Icon(Icons.menu),
                                    ),
                                  ),
                                if (!wide)
                                  const Text(
                                    'Архів',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                const Spacer(),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: wide ? 320 : 150,
                                  ),
                                  child: ArchiveStatusText(
                                    activity: repo.activity,
                                    online: repo.online,
                                    updatedAt: repo.syncedAt,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  tooltip: 'Оновити дані',
                                  onPressed: c.loading ? null : c.refresh,
                                  icon: const Icon(Icons.sync, size: 21),
                                ),
                              ],
                            ),
                          ),
                          if (repo.notice != null)
                            Container(
                              color: context.archiveColors.warningSurface,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              child: Text(
                                repo.notice!,
                                style: TextStyle(
                                  color: context.archiveColors.warningText,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              wide ? 36 : 20,
                              30,
                              wide ? 36 : 20,
                              24,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -.7,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                wide ? 36 : 20,
                                0,
                                wide ? 36 : 20,
                                20,
                              ),
                              child: !active
                                  ? pending(c)
                                  : switch (page) {
                                      'records' => recordList(c),
                                      'documents' => documentList(c),
                                      'inventories' => inventoryList(c),
                                      'admin' =>
                                        repo.profile['role'] == 'admin'
                                            ? AdminPanel(repository: repo)
                                            : pending(c),
                                      'audit' =>
                                        repo.profile['role'] == 'admin'
                                            ? AuditPanel(controller: c)
                                            : pending(c),
                                      _ => overview(c),
                                    },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget nav(
    String label,
    IconData icon,
    bool selected,
    VoidCallback action,
    bool drawer,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Material(
      key: ValueKey('nav-$label'),
      color: selected ? archiveAccent : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          action();
          if (drawer) Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? archiveInk : const Color(0xFFB9C9BF),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? archiveInk : const Color(0xFFCFDAD2),
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget pending(ArchiveController c) =>
      c.loading && c.repository.profile.isEmpty
      ? const Center(child: CircularProgressIndicator())
      : EmptyArchive(
          icon: Icons.lock_outline,
          title: c.repository.profile['role'] == 'blocked'
              ? 'Доступ заблоковано'
              : c.repository.profile['role'] == 'pending'
              ? 'Очікуємо підтвердження'
              : 'Архів поки недоступний',
          message: c.repository.profile['role'] == 'pending'
              ? 'Обліковий запис створено. Адміністратор має надати вам доступ до потрібних модулів.'
              : 'Зверніться до адміністратора або відновіть підключення до сервера.',
          action: OutlinedButton.icon(
            onPressed: c.loading ? null : c.refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Перевірити доступ'),
          ),
        );

  Widget overview(ArchiveController c) => ListView(
    children: [
      LayoutBuilder(
        builder: (context, constraints) => Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final m in ArchiveModule.values.where(
              (m) => canReadModule(c.repository.profile, m),
            ))
              SizedBox(
                width: constraints.maxWidth > 700
                    ? (constraints.maxWidth - 16) / 2
                    : constraints.maxWidth,
                child: Material(
                  color: context.archiveScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => navigate('records', m),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                m == ArchiveModule.court
                                    ? Icons.balance_outlined
                                    : Icons.folder_copy_outlined,
                                color: context.archiveScheme.primary,
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_outward,
                                color: context.archiveScheme.onSurfaceVariant,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '${c.repository.records.where((r) => r.module == m).length}',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(m.label),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 30),
      Row(
        children: [
          const Expanded(
            child: Text(
              'Останні оновлення',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          if (c.repository.online &&
              ArchiveModule.values.any(
                (m) => canWriteModule(c.repository.profile, m),
              ))
            TextButton.icon(
              onPressed: () {
                c.setModule(
                  ArchiveModule.values.firstWhere(
                    (m) => canWriteModule(c.repository.profile, m),
                  ),
                );
                showImportDialog(context, c);
              },
              icon: const Icon(Icons.upload_file_outlined, size: 18),
              label: const Text('Імпортувати Excel'),
            ),
        ],
      ),
      const SizedBox(height: 14),
      if (c.repository.records.isEmpty)
        const SizedBox(
          height: 220,
          child: EmptyArchive(
            title: 'Справ поки немає',
            message: 'Додайте справу або імпортуйте Excel.',
          ),
        ),
      for (final r
          in (c.repository.records.toList()
                ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)))
              .take(8))
        recordTile(c, r),
    ],
  );

  Widget recordList(ArchiveController c) {
    if (!canReadModule(c.repository.profile, c.module)) return pending(c);
    final records = c.recordsOnPage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: c.writable
                  ? () => editArchiveRecord(context, c)
                  : null,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Додати справу'),
            ),
            OutlinedButton.icon(
              onPressed: c.writable ? () => showImportDialog(context, c) : null,
              icon: const Icon(Icons.upload_file_outlined, size: 18),
              label: const Text('Імпорт Excel'),
            ),
            TextButton.icon(
              onPressed: c.totalRecords == 0
                  ? null
                  : () => export(
                      c.module,
                      c.repository.matchingRecords(
                        c.module,
                        c.search,
                        c.retentionFilter,
                      ),
                    ),
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('Експорт'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        TextField(
          key: ValueKey(c.module),
          onChanged: c.setSearch,
          decoration: const InputDecoration(
            hintText: 'Пошук справ…',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final v in ['', 'Тимчасове', 'Тривале', 'Постійне'])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(v.isEmpty ? 'Усі справи' : v),
                    selected: c.retentionFilter == v,
                    onSelected: (_) => c.setRetention(v),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Знайдено справ: ${c.totalRecords}',
            style: TextStyle(
              color: context.archiveScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ),

        if (c.pageError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(child: Text(c.pageError!)),
                TextButton(
                  onPressed: () => c.loadPage(),
                  child: const Text('Повторити'),
                ),
              ],
            ),
          ),
        Expanded(
          child: records.isEmpty && c.pageLoading
              ? const SizedBox.shrink()
              : records.isEmpty
              ? EmptyArchive(
                  title: c.search.isEmpty
                      ? 'Справ поки немає'
                      : 'Нічого не знайдено',
                  message: c.search.isEmpty
                      ? 'Додайте першу картку справи або імпортуйте дані з Excel.'
                      : 'Спробуйте інший номер справи або пошуковий запит.',
                )
              : ListView.builder(
                  key: ValueKey(
                    'case-page-${c.module.name}-${c.pageIndex}-${c.search.trim()}-${c.retentionFilter}',
                  ),
                  itemExtent: 104,
                  itemCount: records.length,
                  itemBuilder: (context, index) =>
                      recordTile(c, records[index]),
                ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Text(
              c.totalRecords == 0
                  ? 'Справ на сторінці: 0'
                  : 'Показано ${c.pageIndex * ArchiveController.pageSize + 1}–${c.pageIndex * ArchiveController.pageSize + records.length} із ${c.totalRecords}',
              style: TextStyle(
                color: context.archiveScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Попередня сторінка',
                  onPressed: c.hasPreviousPage ? c.previousPage : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '${c.pageIndex + 1} / ${c.pageCount}',
                  key: const ValueKey('record-page-counter'),
                ),
                IconButton(
                  tooltip: 'Наступна сторінка',
                  onPressed: c.hasNextPage ? c.nextPage : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget recordTile(ArchiveController c, CaseRecord r) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Material(
      color: context.archiveScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        onTap: () => showArchiveRecord(context, c, r),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.archiveColors.subtleSurface,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            Icons.description_outlined,
            color: context.archiveScheme.primary,
            size: 22,
          ),
        ),
        title: Text(
          r.reference,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${r.listTitle}${r.listProceedings.isNotEmpty ? '\nПровадження: ${r.listProceedings}' : ''}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(height: 1.6, fontSize: 12),
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 22,
          color: context.archiveScheme.onSurfaceVariant,
        ),
      ),
    ),
  );

  Future<void> export(
    ArchiveModule module,
    List<CaseRecord> records, {
    String? kind,
  }) async {
    try {
      await saveFile(
        '${kind ?? module.label}.xlsx',
        WorkbookService().export(
          module,
          records.map((r) => r.values),
          title: kind == null ? 'Справи' : 'Опис справ',
        ),
      );
    } catch (_) {
      if (mounted) {
        showArchiveMessage(context, 'Не вдалося зберегти Excel-файл.');
      }
    }
  }

  Widget documentList(ArchiveController c) {
    if (!canReadModule(c.repository.profile, ArchiveModule.management)) {
      return pending(c);
    }
    final docs = c.repository.documents;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed:
                c.repository.online &&
                    canWriteModule(
                      c.repository.profile,
                      ArchiveModule.management,
                    )
                ? () => uploadDocument(c)
                : null,
            icon: const Icon(Icons.add),
            label: const Text('Додати номенклатуру'),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: docs.isEmpty
              ? const EmptyArchive(
                  title: 'Номенклатури ще не додано',
                  message:
                      'Додайте документи Word, щоб зберігати всі номенклатури в одному місці.',
                  icon: Icons.menu_book_outlined,
                )
              : ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    return Card(
                      elevation: 0,
                      color: context.archiveScheme.surface,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Icon(
                          Icons.article_outlined,
                          color: context.archiveScheme.primary,
                        ),
                        title: Text('${doc['title']}'),
                        subtitle: Text('${doc['year']} · ${doc['fileName']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (c.repository.online &&
                                canWriteModule(
                                  c.repository.profile,
                                  ArchiveModule.management,
                                ))
                              IconButton(
                                tooltip: 'Видалити номенклатуру',
                                onPressed: () => deleteArchiveItem(
                                  context,
                                  c,
                                  document: doc,
                                ),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            IconButton(
                              tooltip: 'Відкрити у Word',
                              icon: const Icon(Icons.open_in_new),
                              onPressed: () async {
                                try {
                                  final bytes = await c.repository.download(
                                    doc['id'] as int,
                                  );
                                  await openWordDocument(
                                    doc['fileName'] as String,
                                    bytes,
                                  );
                                } catch (e) {
                                  if (mounted) {
                                    showArchiveMessage(
                                      this.context,
                                      e is ArchiveFailure
                                          ? e.message
                                          : 'Не вдалося відкрити документ.',
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> uploadDocument(ArchiveController c) async {
    final details = await showNomenclatureDialog(context);
    if (details == null || !mounted) return;
    try {
      final file = await chooseFile(['doc', 'docx']);
      if (file == null) return;
      await c.repository.upload(
        details.title,
        file.name,
        details.year,
        await file.readAsBytes(),
      );
      await c.loadPage();
    } catch (e) {
      if (mounted) {
        showArchiveMessage(
          context,
          e is ArchiveFailure ? e.message : 'Не вдалося завантажити документ.',
        );
      }
    }
  }

  Widget inventoryList(ArchiveController c) {
    final modules = ArchiveModule.values
        .where((m) => canReadModule(c.repository.profile, m))
        .toList();
    if (modules.isEmpty) return pending(c);
    if (!modules.contains(inventoryModule)) inventoryModule = modules.first;
    final records = c.repository.records
        .where(
          (r) =>
              r.module == inventoryModule &&
              r.values['retentionType'] == inventoryKind &&
              r.values['inventoryRequired'] == 'Так' &&
              (r.values['destroyedDate'] ?? '').isEmpty,
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<ArchiveModule>(
          initialValue: inventoryModule,
          decoration: const InputDecoration(labelText: 'Модуль'),
          items: modules
              .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
              .toList(),
          onChanged: (v) => setState(() => inventoryModule = v!),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final v in ['Тривале', 'Постійне'])
              ChoiceChip(
                label: Text('$v зберігання'),
                selected: inventoryKind == v,
                onSelected: (_) => setState(() => inventoryKind = v),
              ),
            OutlinedButton.icon(
              onPressed: records.isEmpty
                  ? null
                  : () => export(
                      inventoryModule,
                      records,
                      kind: 'Опис_${inventoryKind.toLowerCase()}',
                    ),
              icon: const Icon(Icons.download_outlined),
              label: const Text('Сформувати опис Excel'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'До опису входять справи відповідного виду зберігання з позначкою «Справа підлягає внесенню до опису: Так». Строки та вид зберігання заповнюються вручну.',
          style: TextStyle(
            color: context.archiveScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        Text('Справ у списку: ${records.length}'),
        const SizedBox(height: 16),
        Expanded(
          child: records.isEmpty
              ? const EmptyArchive(
                  title: 'Немає справ для опису',
                  message:
                      'Заповніть вид зберігання та позначку внесення до опису у картках справ.',
                )
              : ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, i) => recordTile(c, records[i]),
                ),
        ),
      ],
    );
  }
}
