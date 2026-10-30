class RecordPageRequest {
  const RecordPageRequest({
    required this.account,
    required this.module,
    this.search = '',
    this.retention = '',
    this.page = 0,
    this.size = 50,
  });
  final String account, module, search, retention;
  final int page, size;
}

class RecordPageData {
  const RecordPageData(this.records, this.total, this.page);
  final List<Map<String, dynamic>> records;
  final int total, page;
}

abstract interface class RecordPageStore {
  Future<RecordPageData> readRecordPage(RecordPageRequest request);
}

abstract interface class RecordPatchStore {
  Future<void> applyRecordPatch(
    String account,
    Map<String, dynamic> record,
    List<int> removedIds,
  );
}

abstract interface class SnapshotMetadataStore {
  Future<void> updateMetadata(
    String account,
    Map<String, dynamic> profile,
    String syncedAt,
  );
}

String recordSearchText(Map values) => values.entries
    .where((e) => e.key != 'participantDetails')
    .map((e) => e.value)
    .join(' ')
    .toLowerCase();

/// Atomically applies a bounded journal page and its cursor to the local copy.
abstract interface class ArchiveDeltaStore {
  Future<void> applyArchiveDelta(String account, Map<String, dynamic> delta);
}
