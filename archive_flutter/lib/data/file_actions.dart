import 'dart:typed_data';
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
