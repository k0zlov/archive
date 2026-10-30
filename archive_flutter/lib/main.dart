import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'client.dart';
import 'data/server_connection.dart';
import 'ui/auth_screen.dart';
import 'ui/archive_shell.dart';
import 'ui/theme.dart';
import 'ui/appearance_controller.dart';
import 'data/updates/windows_updates.dart';
import 'ui/windows_update_panel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appearanceController.initialize();
  await initializeClient();
  await initializeWindowsUpdates(serverConnection);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.connection, this.appearance});
  final ServerConnection? connection;
  final AppearanceController? appearance;
  @override
  Widget build(BuildContext context) {
    final current = connection ?? serverConnection;
    final preferences = appearance ?? appearanceController;
    return ListenableBuilder(
      listenable: Listenable.merge([current, preferences]),
      builder: (context, _) => MaterialApp(
        key: ValueKey(current.generation),
        title: 'Archive',
        debugShowCheckedModeBanner: false,
        theme: archiveTheme(),
        darkTheme: archiveTheme(brightness: Brightness.dark),
        themeMode: preferences.mode,
        locale: const Locale('uk'),
        supportedLocales: const [Locale('uk')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: WindowsUpdateHost(
          controller: windowsUpdates,
          child: ValueListenableBuilder(
            valueListenable: current.client.auth.authInfoListenable,
            builder: (context, info, _) => info == null
                ? const AuthScreen()
                : ArchiveShell(
                    key: ValueKey(info.authUserId.toString()),
                    userId: info.authUserId.toString(),
                  ),
          ),
        ),
      ),
    );
  }
}
