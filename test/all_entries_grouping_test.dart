import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:kgl_time/data_model/work_entries.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/enums/calendar_unit.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/pages/all_entries_page.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';
import 'package:kgl_time/work_entry_widgets/work_entry_details.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'support/memory_storage.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('de');
  });

  for (final String language in <String>['en', 'de']) {
    testWidgets('compact $language grouping controls switch day, week, and month on a phone', (
      WidgetTester tester,
    ) async {
      final MemoryStorage storage = MemoryStorage();
      PersistentStorageService.setImplementation(storage);
      addTearDown(storage.close);
      final WorkEntries entries = WorkEntries(<WorkEntry>[
        WorkEntry.fromDuration(duration: const Duration(minutes: 10), date: DateTime(2026, 10, 31))
          ..id = 1,
        WorkEntry.fromDuration(duration: const Duration(minutes: 20), date: DateTime(2026, 10, 30))
          ..id = 2,
      ]);
      addTearDown(entries.dispose);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ChangeNotifierProvider<WorkEntries>.value(
          value: entries,
          child: MaterialApp(
            locale: Locale(language),
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[
              ...GlobalMaterialLocalizations.delegates,
              AppLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AllEntriesPage(appTitle: 'Test'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final AppLocalizations loc = AppLocalizations.of(
        tester.element(find.byType(AllEntriesPage)),
      )!;
      final Finder selector = find.byType(SegmentedButton<CalendarUnit>);
      final Finder caption = find.text(language == 'en' ? 'Group by' : 'Gruppieren nach');
      expect(caption, findsOneWidget);
      expect(tester.getTopLeft(caption).dx, closeTo(tester.getTopLeft(selector).dx, 0.01));
      expect(tester.getBottomLeft(caption).dy, lessThan(tester.getTopLeft(selector).dy));
      final Finder controlsSurface = find.ancestor(of: caption, matching: find.byType(Card)).first;
      final Card surface = tester.widget<Card>(controlsSurface);
      expect(surface.color, Theme.of(tester.element(caption)).canvasColor);
      expect(surface.color!.a, 1);
      expect(find.descendant(of: controlsSurface, matching: selector), findsOneWidget);
      expect(
        tester
            .widget<SegmentedButton<CalendarUnit>>(selector)
            .segments
            .map(
              (ButtonSegment<CalendarUnit> segment) => (segment.label! as Text).data,
            ),
        language == 'en' ? <String>['Day', 'Week', 'Month'] : <String>['Tag', 'Woche', 'Monat'],
      );
      expect(tester.widget<SegmentedButton<CalendarUnit>>(selector).selected, <CalendarUnit>{
        CalendarUnit.week,
      });
      expect(find.text('30 min'), findsOneWidget);

      await tester.tap(find.text(loc.groupByDay));
      await tester.pumpAndSettle();
      for (final int day in <int>[30, 31]) {
        expect(
          find.text(DateFormat.yMMMd(language).format(DateTime(2026, 10, day))),
          findsOneWidget,
        );
      }
      expect(find.text('30 min'), findsNothing);
      expect(find.byType(WorkEntryDetails), findsNWidgets(2));

      await tester.tap(find.text(loc.groupByMonth));
      await tester.pumpAndSettle();
      expect(find.text(DateFormat.yMMMM(language).format(DateTime(2026, 10))), findsOneWidget);
      expect(find.text('30 min'), findsOneWidget);

      await tester.tap(find.text(loc.groupByWeek));
      await tester.pumpAndSettle();
      expect(find.text('30 min'), findsOneWidget);
      expect(find.byType(WorkEntryDetails), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  }
}
