import 'dart:io';
import 'dart:typed_data';
import 'file_action_failure.dart';

/// Prepare a complete copy before handing its file URL to the desktop.
class DesktopDocumentOpener {
  const DesktopDocumentOpener({
    required this.temporaryDirectory,
    required this.launchFile,
  });
  final Future<Directory> Function() temporaryDirectory;
  final Future<bool> Function(Uri) launchFile;

  Future<void> open(String name, Stream<Uint8List> content) async {
    Directory? workingDirectory;
    var opened = false;
    try {
      final temporary = await temporaryDirectory();
      // path_provider's bundle-specific macOS cache path may not yet exist.
      await temporary.create(recursive: true);
      workingDirectory = await temporary.createTemp('archive-open-');
      final safeName = name.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1f]'), '_');
      final file = File('${workingDirectory.path}/document_$safeName');
      final sink = file.openWrite();
      try {
        await sink.addStream(content);
        await sink.flush();
      } catch (_) {
        // Closing a failed sink must not hide a download or cache error.
        try {
          await sink.close();
        } catch (_) {
          // Preserve the original error below.
        }
        rethrow;
      }
      await sink.close();
      try {
        opened = await launchFile(file.uri);
      } catch (_) {
        throw const FileActionFailure(
          'Не вдалося відкрити файл у стандартній програмі. Спробуйте зберегти його на диск.',
        );
      }
      if (!opened) {
        throw const FileActionFailure(
          'Не вдалося відкрити файл у стандартній програмі. Спробуйте зберегти його на диск.',
        );
      }
    } on FileSystemException {
      throw const FileActionFailure(
        'Не вдалося створити локальну копію файлу. Спробуйте зберегти його на диск.',
      );
    } finally {
      if (!opened && workingDirectory != null) {
        try {
          await workingDirectory.delete(recursive: true);
        } on FileSystemException {
          /* The source and its Drift copy are intact. */
        }
      }
    }
  }
}
