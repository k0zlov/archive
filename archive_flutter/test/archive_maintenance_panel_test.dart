import 'package:archive_flutter/data/archive_repository.dart';
import 'package:archive_flutter/ui/archive_maintenance_panel.dart';
import 'package:archive_flutter/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'archive_repository_test.dart' show MemoryStore, TestClient;

class MaintenanceRepository extends ArchiveRepository {
  MaintenanceRepository()
    : super(
        client: TestClient(),
        store: MemoryStore(),
        server: 'test',
        userId: 'admin',
      );
  final calls = <String>[];
  int purges = 0;
  @override
  Future<dynamic> requestTo(
    String endpoint,
    String method,
    Map<String, dynamic> args,
  ) async {
    calls.add(method);
    if (method == 'summary') {
      return {'records': 12, 'files': 3, 'documents': 2, 'audit': 20};
    }
    expect(endpoint, 'archiveMaintenance');
    expect(args['confirmation'], 'ОЧИСТИТИ АРХІВ');
    return {};
  }

  @override
  Future<void> clear() async {
    purges++;
  }

  @override
  Future<void> refresh() async {}
}

void main() {
  testWidgets(
    'cleanup requires reviewing counts and typing the exact phrase; cancelling never deletes',
    (tester) async {
      final repo = MaintenanceRepository()
        ..online = true
        ..profile = {'role': 'admin'};
      await tester.pumpWidget(
        MaterialApp(
          theme: archiveTheme(),
          home: Scaffold(body: ArchiveMaintenancePanel(repository: repo)),
        ),
      );
      await tester.tap(find.text('Очистити архів'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Справ: 12 · Файлів: 3'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Очистити назавжди'),
            )
            .onPressed,
        isNull,
      );
      await tester.tap(find.text('Скасувати'));
      await tester.pumpAndSettle();
      expect(repo.calls, ['summary']);
      expect(repo.purges, 0);
      await tester.tap(find.text('Очистити архів'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('maintenance-confirmation')),
        'очистити архів',
      );
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Очистити назавжди'),
            )
            .onPressed,
        isNull,
      );
      await tester.enterText(
        find.byKey(const ValueKey('maintenance-confirmation')),
        'ОЧИСТИТИ АРХІВ',
      );
      await tester.pump();
      await tester.tap(find.text('Очистити назавжди'));
      await tester.pumpAndSettle();
      expect(repo.calls.where((m) => m == 'clearArchive'), hasLength(1));
      expect(repo.purges, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
