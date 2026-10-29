import 'package:flutter/material.dart';
import '../data/auth_gateway.dart';
import 'theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.gateway});
  final AuthGateway? gateway;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late final gateway = widget.gateway ?? ServerpodAuthGateway();
  final login = TextEditingController();
  final password = TextEditingController();
  final confirmation = TextEditingController();
  bool registering = false, busy = false, visiblePassword = false;
  String? error;
  @override
  void dispose() {
    login.dispose();
    password.dispose();
    confirmation.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy) return;
    final name = login.text.trim().toLowerCase();
    if (name.isEmpty || password.text.isEmpty) {
      setState(() => error = 'Введіть логін і пароль.');
      return;
    }
    if (registering && password.text != confirmation.text) {
      setState(() => error = 'Паролі не збігаються.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (registering) {
        await gateway.register(name, password.text);
      } else {
        await gateway.login(name, password.text);
      }
    } catch (e) {
      if (mounted) setState(() => error = authErrorMessage(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: LayoutBuilder(
      builder: (context, constraints) => Row(
        children: [
          if (constraints.maxWidth >= 1000)
            Expanded(
              child: Container(
                color: archiveInk,
                padding: const EdgeInsets.all(64),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_outlined,
                          color: archiveAccent,
                          size: 32,
                        ),
                        SizedBox(width: 14),
                        Text(
                          'Архів',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Text(
                      'Електронний архів',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (constraints.maxWidth < 1000) ...[
                          const Text(
                            'Архів',
                            style: TextStyle(
                              color: archiveInk,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                        Text(
                          registering
                              ? 'Створити обліковий запис'
                              : 'Увійти до архіву',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (registering) ...[
                          const SizedBox(height: 14),
                          const Text(
                            'Доступ надає адміністратор.',
                            style: TextStyle(color: Color(0xFF68786E)),
                          ),
                        ],
                        const SizedBox(height: 30),
                        TextField(
                          key: const ValueKey('auth-login'),
                          controller: login,
                          enabled: !busy,
                          autocorrect: false,
                          enableSuggestions: false,
                          autofillHints: const [AutofillHints.username],
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Логін',
                            helperText: registering
                                ? '3–64 символи: латиниця, цифри, . _ -'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          key: const ValueKey('auth-password'),
                          controller: password,
                          enabled: !busy,
                          obscureText: !visiblePassword,
                          autofillHints: [
                            registering
                                ? AutofillHints.newPassword
                                : AutofillHints.password,
                          ],
                          onSubmitted: (_) => submit(),
                          decoration: InputDecoration(
                            labelText: 'Пароль',
                            helperText: registering
                                ? 'Щонайменше 8 символів'
                                : null,
                            suffixIcon: IconButton(
                              tooltip: visiblePassword
                                  ? 'Приховати пароль'
                                  : 'Показати пароль',
                              onPressed: () => setState(
                                () => visiblePassword = !visiblePassword,
                              ),
                              icon: Icon(
                                visiblePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                          ),
                        ),
                        if (registering) ...[
                          const SizedBox(height: 18),
                          TextField(
                            key: const ValueKey('auth-password-confirmation'),
                            controller: confirmation,
                            enabled: !busy,
                            obscureText: !visiblePassword,
                            autofillHints: const [AutofillHints.newPassword],
                            onSubmitted: (_) => submit(),
                            decoration: const InputDecoration(
                              labelText: 'Повторіть пароль',
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        if (error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              error!,
                              style: const TextStyle(color: Color(0xFFB34332)),
                            ),
                          ),
                        FilledButton(
                          onPressed: busy ? null : submit,
                          child: Text(
                            busy
                                ? 'Зачекайте…'
                                : registering
                                ? 'Створити обліковий запис'
                                : 'Увійти',
                          ),
                        ),
                        if (!registering)
                          TextButton(
                            onPressed: busy
                                ? null
                                : () => showArchiveMessage(
                                    context,
                                    'Для скидання пароля зверніться до адміністратора.',
                                  ),
                            child: const Text('Забули пароль?'),
                          ),
                        TextButton(
                          onPressed: busy
                              ? null
                              : () => setState(() {
                                  registering = !registering;
                                  password.clear();
                                  confirmation.clear();
                                  error = null;
                                }),
                          child: Text(
                            registering
                                ? 'Повернутися до входу'
                                : 'Створити обліковий запис',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
