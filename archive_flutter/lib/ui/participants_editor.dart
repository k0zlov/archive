import 'package:flutter/material.dart';
import 'package:archive_shared/archive_schema.dart';
import 'theme.dart';

class ParticipantsView extends StatelessWidget {
  const ParticipantsView({super.key, required this.participants});
  final List<CaseParticipant> participants;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final p in participants)
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: archivePaper,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (p.role.isNotEmpty)
                Chip(label: Text(p.role), visualDensity: VisualDensity.compact),
              SelectableText(
                p.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (p.proceeding.isNotEmpty)
                SelectableText(
                  'Провадження № ${p.proceeding}',
                  style: const TextStyle(color: archiveInk),
                ),
            ],
          ),
        ),
    ],
  );
}

class _ParticipantInputs {
  _ParticipantInputs(CaseParticipant p)
    : name = TextEditingController(text: p.name),
      role = TextEditingController(text: p.role),
      proceeding = TextEditingController(text: p.proceeding);
  final TextEditingController name, role, proceeding;
  CaseParticipant get value =>
      CaseParticipant(name.text, role: role.text, proceeding: proceeding.text);
  void dispose() {
    name.dispose();
    role.dispose();
    proceeding.dispose();
  }
}

class ParticipantsEditor extends StatefulWidget {
  const ParticipantsEditor({
    super.key,
    required this.initial,
    required this.onChanged,
    this.enabled = true,
  });
  final List<CaseParticipant> initial;
  final ValueChanged<List<CaseParticipant>> onChanged;
  final bool enabled;
  @override
  State<ParticipantsEditor> createState() => _ParticipantsEditorState();
}

class _ParticipantsEditorState extends State<ParticipantsEditor> {
  late final rows = widget.initial.map(_ParticipantInputs.new).toList();
  final removed = <_ParticipantInputs>[];
  void notify() => widget.onChanged(rows.map((r) => r.value).toList());
  @override
  void dispose() {
    for (final row in [...rows, ...removed]) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: LayoutBuilder(
              builder: (context, size) => Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: size.maxWidth > 700
                        ? (size.maxWidth - 68) * .23
                        : size.maxWidth,
                    child: TextField(
                      controller: row.role,
                      enabled: widget.enabled,
                      onChanged: (_) => notify(),
                      decoration: const InputDecoration(
                        labelText: 'Роль у справі',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: size.maxWidth > 700
                        ? (size.maxWidth - 68) * .42
                        : size.maxWidth,
                    child: TextField(
                      controller: row.name,
                      enabled: widget.enabled,
                      onChanged: (_) => notify(),
                      decoration: const InputDecoration(
                        labelText: 'Ім’я / назва',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: size.maxWidth > 700
                        ? (size.maxWidth - 68) * .35 - 20
                        : size.maxWidth - 58,
                    child: TextField(
                      controller: row.proceeding,
                      enabled: widget.enabled,
                      onChanged: (_) => notify(),
                      decoration: const InputDecoration(
                        labelText: 'Провадження №',
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Прибрати учасника',
                    onPressed: widget.enabled
                        ? () {
                            setState(() {
                              rows.remove(row);
                              removed.add(row);
                            });
                            notify();
                          }
                        : null,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: widget.enabled
                ? () => setState(
                    () =>
                        rows.add(_ParticipantInputs(const CaseParticipant(''))),
                  )
                : null,
            icon: const Icon(Icons.person_add_alt),
            label: const Text('Додати учасника'),
          ),
        ),
      ],
    ),
  );
}
