import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/export_import/export_service.dart';
import 'package:kgl_time/l10n/generated/app_localizations_de.dart';
import 'package:kgl_time/l10n/generated/app_localizations_en.dart';

void main() {
  const ExportService service = ExportService();
  final AppLocalizationsEn english = AppLocalizationsEn();
  final AppLocalizationsDe german = AppLocalizationsDe();

  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('de');
  });

  group('ExportService.entriesToCsv', () {
    test('exports only the header when there are no entries', () {
      expect(csv.decode(service.entriesToCsv([], english)), [
        ['Working Time', 'Date', 'Description', 'From-To', 'Categories'],
      ]);
    });

    test('exports all columns and preserves entry order', () {
      final List<WorkEntry> entries = [
        WorkEntry.fromStartAndEndTime(
          startTime: DateTime(2026, 10, 23, 8, 5),
          endTime: DateTime(2026, 10, 23, 9, 35),
          description: 'Planning',
          categories: [
            EmbeddedWorkCategory(displayName: 'Office'),
            EmbeddedWorkCategory(displayName: 'Meetings'),
          ],
        ),
        WorkEntry.fromDuration(
          duration: const Duration(minutes: 45),
          date: DateTime(2026, 10, 22),
          description: 'Preparation',
        ),
      ];

      expect(csv.decode(service.entriesToCsv(entries, english)), [
        ['Working Time', 'Date', 'Description', 'From-To', 'Categories'],
        [
          '1h 30 min',
          'Fri 23.10.2026',
          'Planning',
          '08:05 - 09:35',
          'Office, Meetings',
        ],
        ['45 min', 'Thu 22.10.2026', 'Preparation', '', ''],
      ]);
    });

    test('localizes headers and dates in German', () {
      final WorkEntry entry = WorkEntry.fromDuration(
        duration: const Duration(hours: 2),
        date: DateTime(2026, 10, 23),
      );

      expect(csv.decode(service.entriesToCsv([entry], german)), [
        ['Arbeitszeit', 'Datum', 'Beschreibung', 'Von-Bis', 'Kategorien'],
        ['2h', 'Fr. 23.10.2026', '', '', ''],
      ]);
    });

    test('uses fallback headers when localizations are absent', () {
      final WorkEntry entry = WorkEntry.fromDuration(
        duration: Duration.zero,
        date: DateTime(2026, 10, 23),
      );
      final dynamic output = Intl.withLocale(
        'en',
        () => service.entriesToCsv([entry], null),
      );

      expect(csv.decode(output), [
        ['Working Time', 'Date', 'Description', 'From-To', 'Categories'],
        ['0 min', 'Fri 23.10.2026', '', '', ''],
      ]);
    });

    test('preserves commas, quotes, line breaks and Unicode in cells', () {
      const String description = 'Gespräch, "Büro"\nNächste Zeile\r\nGrüsse 👋';
      const String category = 'Team, "Süd"\nPlanung';
      final WorkEntry entry = WorkEntry.fromDuration(
        duration: const Duration(minutes: 10),
        date: DateTime(2026, 10, 23),
        description: description,
        categories: [EmbeddedWorkCategory(displayName: category)],
      );

      final List<List<dynamic>> rows = csv.decode(
        service.entriesToCsv([entry], english),
      );

      expect(rows, hasLength(2));
      expect(rows[1], ['10 min', 'Fri 23.10.2026', description, '', category]);
    });

    for (final description in <String?>[null, '']) {
      test(
        'exports empty cells for description $description and no categories',
        () {
          final WorkEntry entry = WorkEntry.fromDuration(
            duration: Duration.zero,
            date: DateTime(2026, 10, 23),
            description: description,
          );

          expect(csv.decode(service.entriesToCsv([entry], english))[1], [
            '0 min',
            'Fri 23.10.2026',
            '',
            '',
            '',
          ]);
        },
      );
    }

    for (final hasStartTime in [true, false]) {
      test('leaves the time range empty when ${hasStartTime ? 'end' : 'start'} '
          'time is missing', () {
        final WorkEntry entry = WorkEntry(
          workDurationInSeconds: 3600,
          date: DateTime(2026, 10, 23),
          startTime: hasStartTime ? DateTime(2026, 10, 23, 8) : null,
          endTime: hasStartTime ? null : DateTime(2026, 10, 23, 9),
        );

        expect(csv.decode(service.entriesToCsv([entry], english))[1][3], '');
      });
    }
  });
}
