import 'package:flutter/material.dart';
import '../data/auth_gateway.dart';

Future<void> showPasswordDialog(
  BuildContext context,
  Future<void> Function() onChanged,
) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (dialogContext) => Dialog(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: PasswordChangeForm(
        onChanged: () async {
          await onChanged();
          if (dialogContext.mounted) Navigator.pop(dialogContext);
        },
        onCancel: () => Navigator.pop(dialogContext),
      ),
    ),
  ),
);

class PasswordChangeForm extends StatefulWidget {
  const PasswordChangeForm({
    super.key,
    required this.onChanged,
    this.onCancel,
    this.gateway,
    this.requiredChange = false,
  });
  final Future<void> Function() onChanged;
  final VoidCallback? onCancel;
  final AuthGateway? gateway;
  final bool requiredChange;
  @override
  State<PasswordChangeForm> createState() => _PasswordChangeFormState();
}

class _PasswordChangeFormState extends State<PasswordChangeForm> {
  late final gateway = widget.gateway ?? ServerpodAuthGateway();
  final current = TextEditingController();
  final password = TextEditingController();
  final confirmation = TextEditingController();
  bool busy = false;
  String? error;
  @override
  void dispose() {
    current.dispose();
    password.dispose();
    confirmation.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (busy) return;
    if (password.text != confirmation.text) {
      setState(() => error = 'Паролі не збігаються.');
      return;
    }
    if (current.text.isEmpty || password.text.length < 8) {
      setState(
        () =>
            error = 'Введіть поточний і новий пароль (щонайменше 8 символів).',
      );
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await gateway.changePassword(current.text, password.text);
      await widget.onChanged();
    } catch (e) {
      if (mounted) setState(() => error = authErrorMessage(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 400),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.requiredChange
                ? 'Створіть власний пароль'
                : 'Змінити пароль',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (widget.requiredChange) ...[
            const SizedBox(height: 12),
            const Text('Замініть тимчасовий пароль, щоб відкрити архів.'),
          ],
          const SizedBox(height: 24),
          for (final field in [
            (
              current,
              widget.requiredChange ? 'Тимчасовий пароль' : 'Поточний пароль',
              'password-current',
            ),
            (password, 'Новий пароль', 'password-new'),
            (confirmation, 'Повторіть новий пароль', 'password-confirmation'),
          ]) ...[
            TextField(
              key: ValueKey(field.$3),
              controller: field.$1,
              enabled: !busy,
              obscureText: true,
              onSubmitted: (_) => save(),
              decoration: InputDecoration(labelText: field.$2),
            ),
            const SizedBox(height: 16),
          ],
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(error!, style: const TextStyle(color: Colors.red)),
            ),
          FilledButton(
            onPressed: busy ? null : save,
            child: Text(busy ? 'Збереження…' : 'Зберегти пароль'),
          ),
          if (widget.onCancel != null)
            TextButton(
              onPressed: busy ? null : widget.onCancel,
              child: Text(widget.requiredChange ? 'Вийти' : 'Скасувати'),
            ),
        ],
      ),
    ),
  );
}
