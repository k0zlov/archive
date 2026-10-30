import 'dart:io';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'desktop_document_opener.dart';

Future<void> saveFile(String name, Uint8List bytes) async {
  final location = await getSaveLocation(suggestedName: name);
  if (location == null) return;
  await XFile.fromData(bytes, name: name).saveTo(location.path);
}

final _documentOpener = DesktopDocumentOpener(
  temporaryDirectory: getTemporaryDirectory,
  launchFile: (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
);

Future<void> openWordDocument(String name, Uint8List bytes) async {
  if (!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux) {
    await saveFile(name, bytes);
    return;
  }
  await _documentOpener.open(name, Stream.value(bytes));
}

Future<void> handleAttachment(
  String name,
  Stream<Uint8List> content,
  bool open,
) async {
  if (open) {
    await _documentOpener.open(name, content);
    return;
  }
  final location = await getSaveLocation(suggestedName: name);
  if (location == null) return;
  final sink = File(location.path).openWrite();
  try {
    await sink.addStream(content);
    await sink.flush();
  } finally {
    await sink.close();
  }
}
