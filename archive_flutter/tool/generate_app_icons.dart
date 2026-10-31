import 'dart:io';
import 'package:flutter_launcher_icons/config/config.dart';
import 'package:flutter_launcher_icons/main.dart' as launcher;
import 'package:image/image.dart' as image;

/// The stock generator writes a single Windows frame. Keep native sizes too,
/// so Windows does not have to scale a 256px frame for small UI surfaces.
Future<void> main() async {
  final root = Platform.script.resolve('../');
  final prefix = Directory.fromUri(root).path;
  final config = Config.loadConfigFromPath(
    'flutter_launcher_icons.yaml',
    prefix,
  );
  if (config == null) throw StateError('Icon configuration is missing.');
  await launcher.createIconsFromArguments([
    '--file',
    'flutter_launcher_icons.yaml',
    '--prefix',
    prefix,
  ]);
  if (config.windowsConfig?.generate != true) return;
  final sourcePath = config.windowsConfig?.imagePath ?? config.imagePath;
  if (sourcePath == null) throw StateError('Windows icon source is missing.');
  final source = image.decodePng(
    await File.fromUri(root.resolve(sourcePath)).readAsBytes(),
  );
  if (source == null || source.width != source.height)
    throw StateError('The icon must be a square PNG.');
  const sizes = [16, 20, 24, 32, 40, 48, 64, 96, 128, 256];
  final frames = [
    for (final size in sizes)
      image.copyResize(
        source,
        width: size,
        height: size,
        interpolation: image.Interpolation.average,
      ),
  ];
  final output = File.fromUri(
    root.resolve('windows/runner/resources/app_icon.ico'),
  );
  await output.writeAsBytes(
    image.IcoEncoder().encodeImages(frames),
    flush: true,
  );
  stdout.writeln('Windows ICO: ${sizes.join(', ')} px.');
}
