import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'client.dart';
import 'ui/auth_screen.dart';
import 'ui/archive_shell.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeClient();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Archive',
    debugShowCheckedModeBanner: false,
    theme: archiveTheme(),
    locale: const Locale('uk'),
    supportedLocales: const [Locale('uk')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: ValueListenableBuilder(
      valueListenable: client.auth.authInfoListenable,
      builder: (context, info, _) => info == null
          ? const AuthScreen()
          : ArchiveShell(
              key: ValueKey(info.authUserId.toString()),
              userId: info.authUserId.toString(),
            ),
    ),
  );
}
