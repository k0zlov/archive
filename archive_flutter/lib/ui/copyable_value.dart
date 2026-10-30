import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'theme.dart';

/// The overlay has a permanent reserved gutter, so hovering never changes layout.
class CopyableValue extends StatefulWidget {
  const CopyableValue({
    super.key,
    required this.value,
    required this.child,
    this.label = 'значення',
  });
  final String value, label;
  final Widget child;
  @override
  State<CopyableValue> createState() => _CopyableValueState();
}

class _CopyableValueState extends State<CopyableValue> {
  bool hovered = false, focused = false, copied = false;
  Future<void> copy() async {
    try {
      await Clipboard.setData(ClipboardData(text: widget.value));
      if (mounted) setState(() => copied = true);
    } catch (_) {
      if (mounted) {
        showArchiveMessage(context, 'Не вдалося скопіювати значення.');
      }
    }
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => hovered = true),
    onExit: (_) => setState(() {
      hovered = false;
      copied = false;
    }),
    child: Focus(
      onFocusChange: (value) => setState(() => focused = value),
      child: Stack(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 28),
            child: Padding(
              padding: const EdgeInsets.only(right: 34),
              child: widget.child,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: hovered || focused ? 1 : 0,
              duration: const Duration(milliseconds: 100),
              child: IgnorePointer(
                ignoring: !hovered && !focused,
                child: IconButton(
                  tooltip: copied
                      ? 'Скопійовано'
                      : 'Копіювати: ${widget.label}',
                  onPressed: copy,
                  icon: Icon(
                    copied ? Icons.check : Icons.content_copy_outlined,
                    size: 16,
                  ),
                  constraints: const BoxConstraints.tightFor(
                    width: 28,
                    height: 28,
                  ),
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: context.archiveColors.subtleSurface,
                    foregroundColor: context.archiveScheme.primary,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

@Preview(name: 'Копіювання поля', size: Size(460, 130))
Widget copyableValuePreview() => MaterialApp(
  theme: archiveTheme(),
  home: const Scaffold(
    body: Padding(
      padding: EdgeInsets.all(24),
      child: CopyableValue(
        value: '243/6187/13-ц',
        label: 'Справа №',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [Text('Справа №'), SelectableText('243/6187/13-ц')],
        ),
      ),
    ),
  ),
);
