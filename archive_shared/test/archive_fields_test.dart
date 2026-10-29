import 'package:archive_shared/archive_shared.dart';
import 'package:test/test.dart';

void main() {
  test('calendar dates reject overflow and accept leap days', () {
    expect(parseArchiveDate('29.02.2024'), DateTime.utc(2024, 2, 29));
    expect(parseArchiveDate('29.02.2025'), isNull);
    expect(parseArchiveDate('31.04.2026'), isNull);
    expect(parseArchiveDate('2026-10-29'), DateTime.utc(2026, 10, 29));
  });
  test(
    'record validation preserves identifiers and normalizes dates and choices',
    () {
      final values = validateRecord(ArchiveModule.court, {
        'caseNumber': ' 001/26 ',
        'receivedDate': '1.02.2026',
        'caseForm': 'паперова',
      });
      expect(values['caseNumber'], '001/26');
      expect(values['receivedDate'], '2026-02-01');
      expect(values['caseForm'], 'Паперова');
    },
  );
  test(
    'missing identifiers, unknown fields and reversed dates are rejected',
    () {
      expect(
        () => validateRecord(ArchiveModule.court, {}),
        throwsFormatException,
      );
      expect(
        () => validateRecord(ArchiveModule.court, {
          'caseNumber': '1',
          'role': 'admin',
        }),
        throwsFormatException,
      );
      expect(
        () => validateRecord(ArchiveModule.management, {
          'caseIndex': '1',
          'title': 'Накази',
          'startDate': '2026-02-01',
          'endDate': '2026-01-01',
        }),
        throwsFormatException,
      );
    },
  );
  test(
    'pending, blocked, reader and module boundaries control permissions',
    () {
      for (final role in ['pending', 'blocked', 'reader']) {
        expect(
          canWriteModule({
            'role': role,
            'courtAccess': true,
          }, ArchiveModule.court),
          false,
        );
      }
      expect(
        canReadModule({
          'role': 'blocked',
          'courtAccess': true,
        }, ArchiveModule.court),
        false,
      );
      expect(
        canReadModule({
          'role': 'reader',
          'courtAccess': true,
        }, ArchiveModule.court),
        true,
      );
      expect(
        canReadModule({
          'role': 'editor',
          'courtAccess': true,
        }, ArchiveModule.management),
        false,
      );
      expect(canWriteModule({'role': 'admin'}, ArchiveModule.management), true);
    },
  );
  test(
    'case identity groups proceedings while nomenclature years stay separate',
    () {
      expect(
        recordIdentity(ArchiveModule.court, {
          'caseNumber': '001',
          'proceedingNumber': '1',
        }),
        equals(
          recordIdentity(ArchiveModule.court, {
            'caseNumber': '001',
            'proceedingNumber': '2',
          }),
        ),
      );
      expect(
        recordIdentity(ArchiveModule.management, {
          'caseIndex': '02-01',
          'nomenclatureYear': '2021',
        }),
        isNot(
          recordIdentity(ArchiveModule.management, {
            'caseIndex': '02-01',
            'nomenclatureYear': '2026',
          }),
        ),
      );
    },
  );
  test('case number is mandatory even when a proceeding is present', () {
    expect(
      () => validateRecord(ArchiveModule.court, {'proceedingNumber': '2/1'}),
      throwsFormatException,
    );
  });
  test(
    'participant merge retains role and proceeding associations without repeated people',
    () {
      final a = {
        'caseNumber': '001',
        ...participantValues([
          const CaseParticipant('Олена', role: 'позивач', proceeding: '2/1'),
        ]),
      };
      final b = {
        'caseNumber': '001',
        ...participantValues([
          const CaseParticipant('Олена', role: 'позивач', proceeding: '2/1'),
          const CaseParticipant('Іван', role: 'відповідач', proceeding: '2/2'),
        ]),
      };
      final merged = validateRecord(
        ArchiveModule.court,
        mergeRecordValues(a, b),
      );
      expect(caseParticipants(merged), hasLength(2));
      expect(merged['proceedingNumber'], '2/1\n2/2');
    },
  );
  test(
    'import chronology warnings retain source dates and strict edits still validate',
    () {
      final values = {
        'caseNumber': '001',
        'receivedDate': '2026-10-10',
        'hearingDate': '2026-01-01',
        ...participantValues([
          const CaseParticipant('Іван', role: 'позивач', proceeding: '2/1'),
        ]),
      };
      final imported = validateRecord(
        ArchiveModule.court,
        values,
        allowDateOrderWarnings: true,
      );
      expect(imported['receivedDate'], '2026-10-10');
      expect(imported['hearingDate'], '2026-01-01');
      expect(
        recordDateWarnings(ArchiveModule.court, imported).single,
        contains('Дата розгляду'),
      );
      expect(
        () => validateRecord(ArchiveModule.court, values),
        throwsFormatException,
      );
      expect(
        () => validateRecord(ArchiveModule.court, {
          ...values,
          'hearingDate': '31.02.2026',
        }, allowDateOrderWarnings: true),
        throwsFormatException,
      );
    },
  );
  test('unsupported-field errors identify the field and selected module', () {
    expect(
      () => validateRecord(ArchiveModule.court, {
        'caseNumber': '001',
        'unexpected': 'value',
      }),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(contains('unexpected'), contains('Судові справи')),
        ),
      ),
    );
  });
}
