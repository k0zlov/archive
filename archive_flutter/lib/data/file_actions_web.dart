import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

Future<void> saveFile(String name, Uint8List bytes) async {
  final blob = web.Blob([bytes.toJS].toJS);
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = name;
  web.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  // Keep the URL valid long enough for browsers to begin the download.
  Future<void>.delayed(
    const Duration(minutes: 1),
    () => web.URL.revokeObjectURL(url),
  );
}

Future<void> openWordDocument(String name, Uint8List bytes) =>
    saveFile(name, bytes);

Future<void> handleAttachment(
  String name,
  Stream<Uint8List> content,
  bool open,
) async {
  final bytes = BytesBuilder(copy: false);
  await for (final part in content) {
    bytes.add(part);
  }
  await saveFile(name, bytes.takeBytes());
}
