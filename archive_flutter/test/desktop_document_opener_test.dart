import 'dart:io';
import 'dart:typed_data';
import 'package:archive_flutter/data/desktop_document_opener.dart';
import 'package:archive_flutter/data/file_action_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'first PDF open creates the missing macOS cache directory and passes a complete Unicode file URL to the desktop',
    () async {
      final root = await Directory.systemTemp.createTemp('archive-pdf-open');
      addTearDown(() => root.delete(recursive: true));
      final missing = Directory(
        '${root.path}/Caches/com.example.archiveFlutter',
      );
      expect(await missing.exists(), false);
      final header = Uint8List.fromList('%PDF-1.7\n'.codeUnits);
      final tail = Uint8List.fromList('body\n%%EOF'.codeUnits);
      var streamed = false, launched = false;
      Stream<Uint8List> content() async* {
        yield header;
        yield tail;
        streamed = true;
      }

      final opener = DesktopDocumentOpener(
        temporaryDirectory: () async => missing,
        launchFile: (uri) async {
          expect(streamed, true);
          expect(uri.scheme, 'file');
          expect(uri.toFilePath(), endsWith('Заява № 1 (копія).pdf'));
          expect(await File.fromUri(uri).readAsBytes(), [...header, ...tail]);
          launched = true;
          return true;
        },
      );
      await opener.open('Заява № 1 (копія).pdf', content());
      expect(launched, true);
      expect(await missing.exists(), true);
    },
  );

  test(
    'a system launch failure is explained and removes only the temporary copy',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'archive-pdf-rejected',
      );
      addTearDown(() => root.delete(recursive: true));
      final opener = DesktopDocumentOpener(
        temporaryDirectory: () async => root,
        launchFile: (_) async => false,
      );
      await expectLater(
        opener.open('scan.pdf', Stream.value(Uint8List.fromList([1, 2]))),
        throwsA(
          isA<FileActionFailure>().having(
            (e) => e.message,
            'message',
            contains('стандартній програмі'),
          ),
        ),
      );
      expect(await root.list().toList(), isEmpty);
    },
  );

  test(
    'incomplete downloads never open and preserve the source failure',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'archive-pdf-incomplete',
      );
      addTearDown(() => root.delete(recursive: true));
      var launched = false;
      Stream<Uint8List> content() async* {
        yield Uint8List.fromList([1, 2]);
        throw StateError('stream interrupted');
      }

      final opener = DesktopDocumentOpener(
        temporaryDirectory: () async => root,
        launchFile: (_) async {
          launched = true;
          return true;
        },
      );
      await expectLater(opener.open('scan.pdf', content()), throwsStateError);
      expect(launched, false);
      expect(await root.list().toList(), isEmpty);
    },
  );
}
