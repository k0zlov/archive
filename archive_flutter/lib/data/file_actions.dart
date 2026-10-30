import 'dart:typed_data';
export 'file_action_failure.dart';
import 'package:file_selector/file_selector.dart';
import 'file_actions_native.dart'
    if (dart.library.js_interop) 'file_actions_web.dart'
    as platform;

Future<void> saveFile(String name, List<int> bytes) =>
    platform.saveFile(name, Uint8List.fromList(bytes));
Future<void> openWordDocument(String name, List<int> bytes) =>
    platform.openWordDocument(name, Uint8List.fromList(bytes));
Future<XFile?> chooseFile(List<String> extensions) => openFile(
  acceptedTypeGroups: [XTypeGroup(label: 'Документи', extensions: extensions)],
);
Future<List<XFile>> chooseFiles(List<String> extensions) => openFiles(
  acceptedTypeGroups: [XTypeGroup(label: 'Документи', extensions: extensions)],
);

bool canOpenAttachment(String name) => const {
  'pdf',
  'doc',
  'docx',
  'xls',
  'xlsx',
  'txt',
  'rtf',
  'png',
  'jpg',
  'jpeg',
  'tif',
  'tiff',
  'bmp',
  'webp',
  'odt',
  'ods',
  'csv',
}.contains(name.split('.').last.toLowerCase());
Future<void> handleAttachment(
  String name,
  Stream<Uint8List> content, {
  bool open = false,
}) => platform.handleAttachment(name, content, open && canOpenAttachment(name));
