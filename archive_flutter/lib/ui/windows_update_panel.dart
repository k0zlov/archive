import 'package:flutter/material.dart';
import 'windows_update_controller.dart';
import 'theme.dart';

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
  const WindowsUpdateHost({super.key, required this.child, this.controller});
  final Widget child;
  final WindowsUpdateController? controller;
  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (c == null) return child;
    return ListenableBuilder(
      listenable: c,
      child: child,
      builder: (context, child) => Column(
        children: [
          if (c.release != null)
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
      ),
    );
  }
}
