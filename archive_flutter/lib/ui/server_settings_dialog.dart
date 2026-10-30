import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../client.dart';
import '../data/server_connection.dart';
import 'theme.dart';
import 'appearance_controller.dart';
import '../data/updates/windows_updates.dart';
import 'windows_update_controller.dart';
import 'windows_update_panel.dart';

Future<void> showServerSettings(
  BuildContext context, {
  Future<void> Function()? beforeSwitch,
}) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (_) => ServerSettingsDialog(
    initialUrl: serverConnection.url,
    initialThemeMode: appearanceController.mode,
    updates: windowsUpdates,
    onSave: (url, mode) async {
      await appearanceController.setMode(mode);
      await serverConnection.changeServer(url, beforeSwitch: beforeSwitch);
    },
  ),
);

class ServerSettingsDialog extends StatefulWidget {
  const ServerSettingsDialog({
    super.key,
    required this.initialUrl,
    required this.onSave,
    this.initialThemeMode = ThemeMode.system,
    this.updates,
  });
  final String initialUrl;
  final Future<void> Function(String url, ThemeMode mode) onSave;
  final ThemeMode initialThemeMode;
  final WindowsUpdateController? updates;
  @override
  State<ServerSettingsDialog> createState() => _ServerSettingsDialogState();
}

class _ServerSettingsDialogState extends State<ServerSettingsDialog> {
  final form = GlobalKey<FormState>();
  late final address = TextEditingController(text: widget.initialUrl);
  late ThemeMode mode = widget.initialThemeMode;
  bool saving = false;
  bool get busy => saving || (widget.updates?.installing ?? false);
  @override
  void initState() {
    super.initState();
    widget.updates?.addListener(updateState);
  }

  void updateState() {
    if (mounted) setState(() {});
  }

  String? error;
  @override
  void dispose() {
    widget.updates?.removeListener(updateState);
    address.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (busy || !form.currentState!.validate()) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await widget.onSave(normalizeServerUrl(address.text), mode);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          saving = false;
          error = 'Не вдалося зберегти налаштування. Спробуйте ще раз.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: AlertDialog(
      title: const Text('Налаштування'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<ThemeMode>(
                  key: const ValueKey('theme-mode'),
                  initialValue: mode,
                  decoration: const InputDecoration(labelText: 'Тема'),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('Системна'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Світла'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Темна'),
                    ),
                  ],
                  onChanged: busy
                      ? null
                      : (value) => setState(() => mode = value!),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  key: const ValueKey('server-url'),
                  controller: address,
                  enabled: !busy,
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => save(),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    try {
                      normalizeServerUrl(value ?? '');
                      return null;
                    } on FormatException catch (e) {
                      return e.message;
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Адреса сервера',
                    hintText: 'http://192.168.0.102:8080/',
                    errorMaxLines: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Після зміни адреси потрібно увійти знову.',
                  style: TextStyle(
                    color: context.archiveScheme.onSurfaceVariant,
                  ),
                ),
                if (widget.updates != null) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(),
                  ),
                  WindowsUpdatePanel(controller: widget.updates!),
                ],
                if (error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Скасувати'),
        ),
        FilledButton(
          onPressed: busy ? null : save,
          child: Text(busy ? 'Збереження…' : 'Зберегти'),
        ),
      ],
    ),
  );
}

@Preview(name: 'Налаштування сервера', size: Size(660, 420))
Widget serverSettingsPreview() => MaterialApp(
  theme: archiveTheme(),
  home: Scaffold(
    body: ServerSettingsDialog(
      initialUrl: 'http://192.168.0.102:8080/',
      onSave: previewSaveServer,
    ),
  ),
);

Future<void> previewSaveServer(String url, ThemeMode mode) async {}
