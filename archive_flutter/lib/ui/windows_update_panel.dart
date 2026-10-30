import 'package:flutter/material.dart';
import 'windows_update_controller.dart';
import 'theme.dart';
import 'server_settings_dialog.dart';

class WindowsUpdatePanel extends StatelessWidget {
  const WindowsUpdatePanel({super.key, required this.controller});
  final WindowsUpdateController controller;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final c = controller, release = c.release;
      final status = c.installing
          ? 'Підготовка до встановлення…'
          : c.downloading
          ? 'Завантаження: ${c.percent}%'
          : c.checking
          ? 'Перевірка оновлень…'
          : c.prepared != null
          ? 'Оновлення готове до встановлення.'
          : release != null
          ? 'Доступна версія ${release.version} (${release.build}).'
          : c.checked
          ? 'Оновлень немає.'
          : 'Перевірте наявність нової версії.';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Оновлення',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Встановлено: ${c.version} (${c.build})',
            style: TextStyle(color: context.archiveScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(status),
          if (release != null && release.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            SelectableText(release.notes),
          ],
          if (c.error != null) ...[
            const SizedBox(height: 8),
            Text(
              c.error!,
              style: TextStyle(color: context.archiveScheme.error),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (c.downloading)
                TextButton(
                  onPressed: c.cancelDownload,
                  child: const Text('Скасувати завантаження'),
                )
              else ...[
                OutlinedButton(
                  onPressed: c.busy ? null : c.check,
                  child: const Text('Перевірити'),
                ),
                if (release != null && c.prepared == null)
                  FilledButton(
                    onPressed: c.busy ? null : c.download,
                    child: const Text('Завантажити'),
                  ),
                if (c.prepared != null)
                  FilledButton(
                    onPressed: c.busy ? null : c.install,
                    child: const Text('Встановити й перезапустити'),
                  ),
              ],
            ],
          ),
        ],
      );
    },
  );
}

Future<void> showWindowsUpdateDialog(
  BuildContext context,
  WindowsUpdateController controller,
) => showDialog<void>(
  context: context,
  builder: (context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => PopScope(
      canPop: !controller.installing,
      child: AlertDialog(
        title: const Text('Оновлення застосунку'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: WindowsUpdatePanel(controller: controller),
          ),
        ),
        actions: [
          TextButton(
            onPressed: controller.installing
                ? null
                : () => Navigator.pop(context),
            child: const Text('Закрити'),
          ),
        ],
      ),
    ),
  ),
);

class WindowsUpdateHost extends StatelessWidget {
  const WindowsUpdateHost({
    super.key,
    required this.child,
    this.controller,
    this.offlineAvailable,
  });
  final Widget child;
  final WindowsUpdateController? controller;
  final Future<bool> Function()? offlineAvailable;
  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (c == null) return child;
    return ListenableBuilder(
      listenable: c,
      child: child,
      builder: (context, child) {
        final access = c.access;
        if (!access.checked) {
          return const Scaffold(
            body: Center(child: Text('Перевірка сумісності із сервером…')),
          );
        }
        if (access.requiredUpdate && !access.offlineChosen) {
          return Scaffold(
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Потрібне оновлення',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ця версія більше не підтримує роботу із сервером. Оновіть застосунок або переглядайте локальну копію без змін.',
                      ),
                      const SizedBox(height: 24),
                      WindowsUpdatePanel(controller: c),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: c.installing
                            ? null
                            : () async {
                                final available =
                                    await offlineAvailable?.call() ?? true;
                                if (!context.mounted) return;
                                if (available) {
                                  access.chooseOffline();
                                } else {
                                  showArchiveMessage(
                                    context,
                                    'Локальної копії немає. Спочатку оновіть застосунок і підключіться до сервера.',
                                  );
                                }
                              },
                        child: const Text('Працювати офлайн'),
                      ),
                      TextButton(
                        onPressed: c.installing
                            ? null
                            : () => showServerSettings(context),
                        child: const Text('Налаштування'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return Column(
          children: [
            if (access.requiredUpdate || access.unavailable)
              Material(
                color: context.archiveColors.subtleSurface,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            access.requiredUpdate
                                ? 'Офлайн · потрібне оновлення для роботи із сервером'
                                : 'Офлайн · не вдалося перевірити зв’язок із сервером',
                          ),
                        ),
                        TextButton(
                          onPressed: access.requiredUpdate
                              ? access.showChoice
                              : c.busy
                              ? null
                              : c.check,
                          child: Text(
                            access.requiredUpdate ? 'Оновити' : 'Повторити',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (c.release != null &&
                !access.requiredUpdate &&
                !access.unavailable)
              Material(
                color: context.archiveColors.subtleSurface,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Доступне оновлення ${c.release!.version}',
                            style: TextStyle(
                              color: context.archiveScheme.onSurface,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => showWindowsUpdateDialog(context, c),
                          child: const Text('Переглянути'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(child: child!),
          ],
        );
      },
    );
  }
}
