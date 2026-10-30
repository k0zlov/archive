import 'dart:convert';
import 'package:archive_flutter/data/archive_repository.dart';
import 'package:archive_flutter/ui/admin_panel.dart';
import 'package:archive_flutter/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'archive_repository_test.dart' show TestClient, MemoryStore;

class AdminClient extends TestClient {
  final users = <Map<String, dynamic>>[
    {
      'id': 1,
      'userId': 'admin',
      'login': 'admin',
      'role': 'admin',
      'online': true,
      'activeSessions': 1,
    },
    {
      'id': 2,
      'userId': 'reader',
      'login': 'reader',
      'role': 'reader',
      'online': true,
      'activeSessions': 2,
    },
  ];
  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) async {
    if (method == 'members') {
      return jsonEncode({'ok': true, 'data': users}) as T;
    }
    if (method == 'deleteMember') {
      users.removeWhere((m) => m['id'] == args['memberId']);
      return null as T;
    }
    return super.callServerEndpoint<T>(
      endpoint,
      method,
      args,
      authenticated: authenticated,
    );
  }
}

void main() {
  testWidgets(
    'admin list receives live status changes, protects own account and confirms deletion',
    (tester) async {
      final client = AdminClient();
      final repo =
          ArchiveRepository(
              client: client,
              store: MemoryStore(),
              server: 'test',
              userId: 'admin',
            )
            ..online = true
            ..profile = {'userId': 'admin', 'role': 'admin'};
      await tester.pumpWidget(
        MaterialApp(
          theme: archiveTheme(brightness: Brightness.dark),
          home: Scaffold(body: AdminPanel(repository: repo)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Активні сеанси: 2'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(
              find
                  .byWidgetPredicate(
                    (w) =>
                        w is IconButton && w.tooltip == 'Видалити користувача',
                  )
                  .first,
            )
            .onPressed,
        isNull,
      );
      client.users.last['online'] = false;
      client.users.last['activeSessions'] = 0;
      await repo.refreshMembers();
      await tester.pump();
      expect(find.text('○ Не в мережі'), findsOneWidget);
      expect(find.text('Активні сеанси: 0'), findsOneWidget);
      await tester.tap(find.byTooltip('Видалити користувача').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Видалити'));
      await tester.pumpAndSettle();
      expect(find.text('reader'), findsNothing);
      expect(client.users, hasLength(1));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      repo.memberChanges.dispose();
    },
  );
}
