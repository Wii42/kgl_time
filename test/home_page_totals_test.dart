import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/kgl_time_app.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';
import 'package:material_ui/material_ui.dart';

import 'support/memory_storage.dart';
import 'support/test_clock.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('de');
  });

  for (final String language in <String>['en', 'de']) {
    for (final bool empty in <bool>[false, true]) {
      testWidgetsWithAdvancingClock('Home shows today total in $language, empty=$empty', (
        WidgetTester tester,
      ) async {
        final MemoryStorage storage = MemoryStorage();
        PersistentStorageService.setImplementation(storage);
        addTearDown(storage.close);
        tester.binding.platformDispatcher.localesTestValue = <Locale>[Locale(language)];
        addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);
        tester.view.physicalSize = const Size(390, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final DateTime now = clock.now();
        WorkEntry entry(int id, DateTime date, int minutes, {bool trashed = false}) =>
            WorkEntry.fromDuration(
              date: date,
              duration: Duration(minutes: minutes),
              wasMovedToTrashAt: trashed ? now : null,
            )..id = id;
        await tester.pumpWidget(
          KglTimeApp(
            appTitle: 'Test',
            initialEntries: empty
                ? const <WorkEntry>[]
                : <WorkEntry>[
                    entry(1, DateTime(now.year, now.month, now.day, 0, 1), 40),
                    entry(2, DateTime(now.year, now.month, now.day, 23, 59), 35),
                    entry(3, DateTime(now.year, now.month, now.day - 1), 100),
                    entry(4, DateTime(now.year - 1, now.month, now.day), 200),
                    entry(5, DateTime(now.year, now.month, now.day + 1), 300),
                    entry(6, now, 400, trashed: true),
                  ],
          ),
        );
        await tester.pumpAndSettle();
        final String label = language == 'en' ? 'Today' : 'Heute';
        final Finder total = find.text('$label: ${empty ? '0 min' : '1h 15 min'}');
        expect(total, findsOneWidget);
        final Finder week = find.textContaining(
          language == 'en' ? 'Current week:' : 'Aktuelle Woche:',
        );
        final Finder month = find.textContaining(
          language == 'en' ? 'Current month:' : 'Aktueller Monat:',
        );
        expect(week, findsOneWidget);
        expect(month, findsOneWidget);
        expect(tester.getTopLeft(total).dy, lessThan(tester.getTopLeft(week).dy));
        expect(tester.widget<Text>(total).style, tester.widget<Text>(week).style);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
