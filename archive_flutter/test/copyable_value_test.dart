import 'package:archive_flutter/ui/copyable_value.dart';
import 'package:archive_flutter/ui/theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      '$brightness copy appears on hover without moving content and copies the exact value',
      (tester) async {
        String? copied;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            if (call.method == 'Clipboard.setData') {
              copied = (call.arguments as Map)['text'] as String;
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: archiveTheme(brightness: brightness),
            home: const Scaffold(
              body: SizedBox(
                width: 320,
                child: CopyableValue(
                  value: '243/6187/13-ц',
                  label: 'Справа №',
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Справа №'),
                      SelectableText('243/6187/13-ц'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        final value = find.byType(CopyableValue),
            text = find.text('243/6187/13-ц');
        final rect = tester.getRect(text), size = tester.getSize(value);
        expect(
          tester
              .widget<AnimatedOpacity>(find.byType(AnimatedOpacity).first)
              .opacity,
          0,
        );
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: const Offset(700, 500));
        await mouse.moveTo(tester.getCenter(value));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<AnimatedOpacity>(find.byType(AnimatedOpacity).first)
              .opacity,
          1,
        );
        expect(tester.getRect(text), rect);
        expect(tester.getSize(value), size);
        await tester.tap(find.byTooltip('Копіювати: Справа №'));
        await tester.pump();
        expect(copied, '243/6187/13-ц');
        expect(find.byIcon(Icons.check), findsOneWidget);
        await mouse.moveTo(const Offset(700, 500));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<AnimatedOpacity>(find.byType(AnimatedOpacity).first)
              .opacity,
          0,
        );
        expect(tester.getRect(text), rect);
        await mouse.removePointer();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
