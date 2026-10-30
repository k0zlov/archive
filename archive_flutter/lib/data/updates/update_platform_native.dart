import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'package:archive_shared/windows_release.dart';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'update_platform.dart';

bool get supported => Platform.isWindows && Abi.current() == Abi.windowsX64;
UpdatePlatform createPlatform() => WindowsUpdateFiles();

Future<String> _fileHash(String path) async =>
    (await sha256.bind(File(path).openRead()).first).toString();

class WindowsUpdateFiles implements UpdatePlatform {
  WindowsUpdateFiles({
    Future<Directory> Function()? directory,
    Future<void> Function(String, List<String>)? launch,
    void Function()? quit,
  }) : _directory = directory ?? getTemporaryDirectory,
       _launch = launch ?? _launchInstaller,
       _quit = quit ?? (() => exit(0));
  final Future<Directory> Function() _directory;
  final Future<void> Function(String, List<String>) _launch;
  final void Function() _quit;
  static Future<void> _launchInstaller(String file, List<String> args) async {
    if (!supported) {
      throw const UpdateFailure('Встановлення доступне лише у Windows x64.');
    }
    await Process.start(file, args, mode: ProcessStartMode.detached);
  }

  @override
  Future<PreparedUpdate> download(
    WindowsRelease release,
    FetchUpdatePart fetch, {
    required bool Function() cancelled,
    required void Function(int) progress,
  }) async {
    final root = await _directory();
    await root.create(recursive: true);
    final folder = await root.createTemp('archive-update-');
    final partial = File('${folder.path}/Archive-Setup.exe.part');
    var keep = false;
    final sink = partial.openWrite();
    try {
      try {
        var offset = 0;
        while (offset < release.size) {
          if (cancelled()) throw UpdateCancelled();
          final part = await fetch(offset).timeout(const Duration(seconds: 30));
          if (cancelled()) throw UpdateCancelled();
          final expected = release.size - offset < windowsUpdateChunkSize
              ? release.size - offset
              : windowsUpdateChunkSize;
          if (part.lengthInBytes != expected) {
            throw const UpdateFailure(
              'Файл оновлення завантажено не повністю.',
            );
          }
          sink.add(
            part.buffer.asUint8List(part.offsetInBytes, part.lengthInBytes),
          );
          await sink.flush();
          offset += part.lengthInBytes;
          progress(offset * 100 ~/ release.size);
        }
      } catch (_) {
        try {
          await sink.close();
        } catch (_) {}
        rethrow;
      }
      await sink.close();
      if (cancelled()) throw UpdateCancelled();
      await _verify(partial.path, release);
      if (cancelled()) throw UpdateCancelled();
      final ready = await partial.rename('${folder.path}/Archive-Setup.exe');
      keep = true;
      return PreparedUpdate(ready.path);
    } finally {
      if (!keep && await folder.exists()) await folder.delete(recursive: true);
    }
  }

  Future<void> _verify(String path, WindowsRelease release) async {
    if (await File(path).length() != release.size ||
        await Isolate.run(() => _fileHash(path)) != release.sha256) {
      throw const UpdateFailure(
        'Файл оновлення пошкоджено. Завантажте його ще раз.',
      );
    }
  }

  @override
  Future<void> discard(PreparedUpdate update) async {
    final folder = File(update.path).parent;
    // Only remove directories created by this updater, never user data.
    if (folder.uri.pathSegments
            .where((p) => p.isNotEmpty)
            .last
            .startsWith('archive-update-') &&
        await folder.exists()) {
      await folder.delete(recursive: true);
    }
  }

  @override
  Future<void> install(PreparedUpdate update, WindowsRelease release) async {
    // Recheck immediately before execution, including when the user waited.
    await _verify(update.path, release);
    await _launch(update.path, [
      '/SILENT',
      '/SP-',
      '/NORESTART',
      '/ARCHIVEPID=$pid',
    ]);
    _quit();
  }
}
