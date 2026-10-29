import 'dart:io';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';

Future<void> saveFile(String name, Uint8List bytes) async {
  final location = await getSaveLocation(suggestedName: name);
  if (location == null) return;
  await XFile.fromData(bytes, name: name).saveTo(location.path);
}

Future<void> openWordDocument(String name, Uint8List bytes) async {
  if (!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux) {
    await saveFile(name, bytes);
    return;
  }
  final dir = await getTemporaryDirectory();
  final safeName = name.replaceAll(RegExp(r'[/\\]'), '_');
  final f = File(
    '${dir.path}/archive_${DateTime.now().microsecondsSinceEpoch}_$safeName',
  );
  await f.writeAsBytes(bytes, flush: true);
  final result = Platform.isMacOS
      ? await Process.run('open', [f.path])
      : Platform.isWindows
      ? await Process.run('rundll32', ['url.dll,FileProtocolHandler', f.path])
      : await Process.run('xdg-open', [f.path]);
  if (result.exitCode != 0) {
    throw const FileSystemException(
      'Не вдалося відкрити документ. Перевірте, чи встановлено Word.',
    );
  }
}
