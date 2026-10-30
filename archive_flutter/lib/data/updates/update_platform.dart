import 'dart:typed_data';
import 'package:archive_shared/windows_release.dart';
import 'update_platform_stub.dart'
    if (dart.library.io) 'update_platform_native.dart'
    as native;

class UpdateFailure implements Exception {
  const UpdateFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

class UpdateCancelled implements Exception {}

class PreparedUpdate {
  const PreparedUpdate(this.path);
  final String path;
}

typedef FetchUpdatePart = Future<ByteData> Function(int offset);

abstract interface class UpdatePlatform {
  Future<PreparedUpdate> download(
    WindowsRelease release,
    FetchUpdatePart fetch, {
    required bool Function() cancelled,
    required void Function(int percent) progress,
  });
  Future<void> discard(PreparedUpdate update);
  Future<void> install(PreparedUpdate update, WindowsRelease release);
}

bool get supportsWindowsUpdates => native.supported;
UpdatePlatform createUpdatePlatform() => native.createPlatform();
