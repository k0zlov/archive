import 'package:flutter/material.dart';

class NomenclatureDetails {
  const NomenclatureDetails(this.title, this.year);
  final String title;
  final int year;
}

Future<NomenclatureDetails?> showNomenclatureDialog(BuildContext context) =>
    showDialog<NomenclatureDetails>(
      context: context,
      builder: (_) => const NomenclatureDialog(),
    );

/// Controllers belong to the route and live until its closing animation ends.
class NomenclatureDialog extends StatefulWidget {
  const NomenclatureDialog({super.key});
  @override
  State<NomenclatureDialog> createState() => _NomenclatureDialogState();
}

class _NomenclatureDialogState extends State<NomenclatureDialog> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  final year = TextEditingController(text: '${DateTime.now().year}');

  @override
  void dispose() {
    name.dispose();
    year.dispose();
    super.dispose();
  }

  void submit() {
    if (!form.currentState!.validate()) return;
    Navigator.pop(
      context,
      NomenclatureDetails(name.text.trim(), int.parse(year.text)),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Нова номенклатура'),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(
        child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const ValueKey('nomenclature-title'),
                controller: name,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Назва'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Введіть назву номенклатури.'
                    : v.trim().length > 300
                    ? 'Назва має містити до 300 символів.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('nomenclature-year'),
                controller: year,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Рік'),
                onFieldSubmitted: (_) => submit(),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  return n == null || n < 1900 || n > 2200
                      ? 'Введіть рік від 1900 до 2200.'
                      : null;
                },
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Скасувати'),
      ),
      FilledButton(
        onPressed: submit,
        child: const Text('Обрати документ Word'),
      ),
    ],
  );
}
