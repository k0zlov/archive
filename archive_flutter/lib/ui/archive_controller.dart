import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:archive_shared/archive_schema.dart';
import '../data/archive_repository.dart';

class ArchiveController extends ChangeNotifier {
  ArchiveController(this.repository) {
    unawaited(loadPage());
  }
  final ArchiveRepository repository;
  Timer? _timer;
  Timer? _searchTimer;
  bool loading = false;
  bool pageLoading = false;
  bool _disposed = false;
  bool _paused = false;
  int _pageRequest = 0;
  String? error;
  String? pageError;
  String search = '';
  String retentionFilter = '';
  ArchiveModule module = ArchiveModule.court;
  static const pageSize = 50;
  List<CaseRecord> recordsOnPage = const [];
  int totalRecords = 0;
  int pageIndex = 0;
  int get pageCount =>
      totalRecords == 0 ? 1 : (totalRecords + pageSize - 1) ~/ pageSize;
  bool get hasPreviousPage => !pageLoading && pageIndex > 0;
  bool get hasNextPage => !pageLoading && pageIndex + 1 < pageCount;
  bool get writable =>
      repository.online && canWriteModule(repository.profile, module);

  Future<void> loadPage({int? index, bool clear = false}) async {
    if (_disposed || _paused) return;
    final request = ++_pageRequest;
    final requestedPage = index ?? pageIndex;
    final activity = repository.activity;
    final task = activity.begin(
      'Відкриття сторінки справ із локальної бази',
      priority: 3,
    );
    pageLoading = true;
    pageError = null;
    if (clear) {
      recordsOnPage = const [];
      totalRecords = 0;
      pageIndex = 0;
    }
    _notify();
    try {
      final page = await repository.recordPage(
        module,
        query: search,
        retention: retentionFilter,
        page: requestedPage,
        size: pageSize,
      );
      if (_disposed || _paused || request != _pageRequest) return;
      recordsOnPage = List.unmodifiable(page.records);
      totalRecords = page.total;
      pageIndex = page.page;
    } catch (_) {
      if (!_disposed && request == _pageRequest) {
        pageError = 'Не вдалося завантажити сторінку справ.';
      }
    } finally {
      activity.end(task);
      if (!_disposed && request == _pageRequest) {
        pageLoading = false;
        _notify();
      }
    }
  }

  Future<void> previousPage() async {
    if (hasPreviousPage) await loadPage(index: pageIndex - 1);
  }

  Future<void> nextPage() async {
    if (hasNextPage) await loadPage(index: pageIndex + 1);
  }

  Future<void> initialize() async {
    await repository.restore();
    if (_disposed || _paused) return;
    await loadPage();
    await refresh();
    if (!_disposed && !_paused) {
      _timer = Timer.periodic(const Duration(seconds: 30), (_) => refresh());
    }
  }

  Future<void> refresh() async {
    if (loading || _disposed || _paused) return;
    loading = true;
    _notify();
    try {
      await repository.refresh();
      await loadPage();
    } finally {
      loading = false;
      _notify();
    }
  }

  Future<void> prepareForUpdate() async {
    _paused = true;
    _pageRequest++;
    _timer?.cancel();
    _searchTimer?.cancel();
    await repository.prepareForUpdate();
  }

  Future<void> prepareServerChange() async {
    _paused = true;
    _pageRequest++;
    _timer?.cancel();
    _searchTimer?.cancel();
    await repository.clear();
  }

  void resumeAfterServerChange() {
    if (_disposed || !_paused) return;
    _paused = false;
    unawaited(refresh());
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => refresh());
  }

  void setSearch(String value) {
    search = value;
    _searchTimer?.cancel();
    _pageRequest++;
    pageLoading = true;
    pageError = null;
    _notify();
    _searchTimer = Timer(
      const Duration(milliseconds: 250),
      () => loadPage(index: 0, clear: true),
    );
  }

  void setModule(ArchiveModule value) {
    _searchTimer?.cancel();
    module = value;
    search = '';
    retentionFilter = '';
    unawaited(loadPage(index: 0, clear: true));
  }

  void setRetention(String value) {
    _searchTimer?.cancel();
    retentionFilter = value;
    unawaited(loadPage(index: 0, clear: true));
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _pageRequest++;
    _timer?.cancel();
    _searchTimer?.cancel();
    repository.attachments.dispose();
    repository.activity.dispose();
    super.dispose();
  }
}
