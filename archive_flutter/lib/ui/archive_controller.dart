import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:archive_shared/archive_schema.dart';
import '../data/archive_repository.dart';
import '../data/archive_live_sync.dart';
import '../data/auth_gateway.dart';
import 'package:archive_client/archive_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

class ArchiveController extends ChangeNotifier {
  ArchiveController(this.repository) {
    repository.access?.addListener(_accessChanged);
    _networkBlocked = !repository.networkAllowed;
    unawaited(loadPage());
  }
  final ArchiveRepository repository;
  Timer? _timer;
  Timer? _eventDebounce;
  bool _refreshPending = false;
  bool _networkBlocked = false, _initialized = false;

  void _accessChanged() {
    if (_disposed) return;
    final blocked = !repository.networkAllowed;
    if (blocked == _networkBlocked) return;
    _networkBlocked = blocked;
    if (blocked) {
      _timer?.cancel();
      _eventDebounce?.cancel();
      _live.stop();
      repository.online = false;
      repository.notice =
          'Локальна копія · для роботи із сервером потрібне оновлення.';
      if (_initialized) unawaited(repository.prepareForUpdate());
      _notify();
    } else if (_initialized && !_paused) {
      unawaited(refresh());
      _startSynchronization();
    }
  }

  Future<void>? _membersRefresh;
  String? _watchSession;
  String? get _currentSession => repository.client.auth.authInfo?.refreshToken
      ?.split(':')
      .take(2)
      .join(':');
  late final _live = ArchiveLiveSync(
    watch: (heartbeat) {
      _watchSession = _currentSession;
      return repository.client.archiveSync.watch(heartbeat);
    },
    beforeHeartbeat: () async {
      final auth = repository.client.auth;
      final signedIn = auth.isAuthenticated;
      await auth.refreshAuthKey();
      if (signedIn && !auth.isAuthenticated) await repository.clear();
    },
    onData: _scheduleRefresh,
    onPresenceSnapshot: repository.applyMemberPresence,
    onUpdateRequired: (raw) async {
      try {
        await repository.access?.accept(raw);
      } catch (_) {
        repository.access?.checkFailed();
      }
    },
    onAlive: () {
      if (!repository.online) _scheduleRefresh();
    },
    onPresence: () {
      if (_disposed || _paused || _membersRefresh != null) return;
      _membersRefresh = repository
          .refreshMembers()
          .catchError((Object _) {})
          .whenComplete(() {
            _membersRefresh = null;
          });
    },
    onDisconnected: () {
      if (_disposed || _paused) return;
      repository.online = false;
      repository.notice = 'Немає зв’язку із сервером. Доступна локальна копія.';
      _notify();
    },
    onError: (error) async {
      if (_disposed || _paused) return;
      if (error is ArchiveAuthException ||
          error is ServerpodClientUnauthorized ||
          error is ServerpodClientForbidden) {
        final failedSession = _watchSession;
        await waitForAuthenticationOperations();
        if (_disposed || _paused) return;
        if (_currentSession != null && _currentSession != failedSession) return;
        await repository.invalidateAuthentication();
        _notify();
      }
    },
  );

  void _scheduleRefresh() {
    if (_disposed || _paused || _networkBlocked) return;
    _eventDebounce?.cancel();
    _eventDebounce = Timer(const Duration(milliseconds: 150), () {
      if (loading) {
        _refreshPending = true;
        return;
      }
      unawaited(refresh());
    });
  }

  void _startSynchronization() {
    if (_networkBlocked || _disposed || _paused) return;
    _live.start();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => refresh());
  }

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
    _initialized = true;
    await loadPage();
    await refresh();
    if (!_disposed && !_paused) {
      _startSynchronization();
    }
  }

  Future<void> refresh() async {
    if (loading || _disposed || _paused || _networkBlocked) return;
    loading = true;
    _notify();
    try {
      await repository.refresh();
      await loadPage();
    } finally {
      loading = false;
      _notify();
      if (_refreshPending && !_disposed && !_paused) {
        _refreshPending = false;
        _scheduleRefresh();
      }
    }
  }

  Future<void> prepareForUpdate() async {
    _paused = true;
    _pageRequest++;
    _timer?.cancel();
    _eventDebounce?.cancel();
    _live.stop();
    _searchTimer?.cancel();
    await repository.prepareForUpdate();
  }

  Future<void> prepareServerChange() async {
    _paused = true;
    _pageRequest++;
    _timer?.cancel();
    _eventDebounce?.cancel();
    _live.stop();
    _searchTimer?.cancel();
    await repository.clear();
  }

  void resumeAfterServerChange() {
    if (_disposed || !_paused) return;
    _paused = false;
    unawaited(refresh());
    _startSynchronization();
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
    _eventDebounce?.cancel();
    _live.stop();
    _searchTimer?.cancel();
    repository.access?.removeListener(_accessChanged);
    repository.dispose();
    super.dispose();
  }
}
