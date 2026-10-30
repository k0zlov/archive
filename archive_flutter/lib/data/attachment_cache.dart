import 'dart:typed_data';

/// Metadata and binary parts are kept outside the full archive JSON snapshot.
abstract interface class AttachmentCache {
  Future<List<Map<String, dynamic>>> readAttachments(String account);
  Future<void> syncAttachments(
    String account,
    List<Map<String, dynamic>> files,
  );
  Future<void> putAttachmentChunk(
    String account,
    int id,
    int index,
    Uint8List bytes,
  );
  Future<Uint8List?> readAttachmentChunk(String account, int id, int index);
  Future<void> completeAttachment(String account, int id);
}
