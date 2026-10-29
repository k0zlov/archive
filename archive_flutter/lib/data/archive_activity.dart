import 'dart:async';
import 'package:flutter/foundation.dart';

class ArchiveActivityTask {
  ArchiveActivityTask(this.id, this.label, this.priority);
  final int id, priority;
  String label;
  int? completed, total;
}

/// Status updates are independent of card-list rebuilds.
class ArchiveActivity extends ChangeNotifier {
  final _tasks = <int, ArchiveActivityTask>{};
  int _next = 0;
  bool _disposed = false;
  Timer? _pending;
  DateTime _lastEmit = DateTime.fromMillisecondsSinceEpoch(0);
  String lastResult = '';
  ArchiveActivityTask? get current {
    ArchiveActivityTask? result;
    for (final task in _tasks.values) {
      if (result == null ||
          task.priority > result.priority ||
          (task.priority == result.priority && task.id > result.id)) {
        result = task;
      }
    }
    return result;
  }

  int begin(String label, {int priority = 0}) {
    final id = ++_next;
    _tasks[id] = ArchiveActivityTask(id, label, priority);
    _changed();
    return id;
  }

  void stage(int id, String label, {int? completed, int? total}) {
    final task = _tasks[id];
    if (task == null) return;
    task.label = label;
    task.completed = completed;
    task.total = total;
    _changed();
  }

  void end(int id, {String? result}) {
    _tasks.remove(id);
    if (result != null) lastResult = result;
    _changed();
  }

  void _changed() {
    if (_disposed || !hasListeners) return;
    final elapsed = DateTime.now().difference(_lastEmit).inMilliseconds;
    // Requests can begin in a panel's initState while the header is mounted.
    // Dispatch on the next event so a sibling is never rebuilt during build.
    _pending ??= Timer(
      Duration(milliseconds: (120 - elapsed).clamp(0, 120)),
      () {
        _pending = null;
        _emit();
      },
    );
  }

  void _emit() {
    if (!_disposed) {
      _lastEmit = DateTime.now();
      notifyListeners();
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      _pending?.cancel();
      _pending = null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _pending?.cancel();
    super.dispose();
  }
}

String archiveRequestLabel(String method) => switch (method) {
  'saveRecord' => 'Збереження справи',
  'beginImport' ||
  'appendImportRows' ||
  'commitImport' ||
  'cancelImport' => 'Імпорт',
  'deleteRecord' || 'deleteDocument' => 'Видалення',
  'restoreRecord' || 'restoreDocument' => 'Відновлення',
  'records' => 'Завантаження справ',
  'downloadDocument' => 'Завантаження документа',
  _ => 'Оновлення даних',
};
