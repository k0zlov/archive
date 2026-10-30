import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'theme.dart';

class RecordDialogBody extends StatelessWidget {
  const RecordDialogBody({
    super.key,
    required this.information,
    required this.files,
  });
  final Widget information, files;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, size) => size.maxWidth >= 900
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: information),
              SizedBox(width: 270, child: files),
            ],
          )
        : Column(
            children: [
              Expanded(child: information),
              SizedBox(height: size.maxHeight < 450 ? 160 : 210, child: files),
            ],
          ),
  );
}

@Preview(name: 'Картка справи з файлами', size: Size(1100, 650))
Widget recordFilesPreview() => MaterialApp(
  theme: archiveTheme(),
  home: Builder(
    builder: (context) => Scaffold(
      body: RecordDialogBody(
        information: const Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Справа № 243/6187/13-ц',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 24),
              Text('ІНФОРМАЦІЯ ПРО СПРАВУ'),
              SizedBox(height: 14),
              Text('Дата надходження\n03.01.2014'),
            ],
          ),
        ),
        files: Container(
          color: context.archiveColors.panel,
          padding: const EdgeInsets.all(16),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Файли', style: TextStyle(fontWeight: FontWeight.w700)),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Документ.pdf'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
