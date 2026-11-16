import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kgl_time/app/kgl_time_app.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';
import 'package:material_ui/material_ui.dart';

import 'support/memory_storage.dart';
import 'support/test_clock.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
  });

  for (final bool empty in <bool>[false, true]) {
    testWidgetsWithAdvancingClock('Home shows today total, empty=$empty', (
      WidgetTester tester,
    ) async {
      final MemoryStorage storage = MemoryStorage();
      PersistentStorageService.setImplementation(storage);
      addTearDown(storage.close);
      tester.binding.platformDispatcher.localesTestValue = <Locale>[const Locale('en')];
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
      final Finder total = find.text('Today: ${empty ? '0 min' : '1h 15 min'}');
      expect(total, findsOneWidget);
      final Finder week = find.textContaining(
        'Current week:',
      );
      final Finder month = find.textContaining(
        'Current month:',
      );
      expect(week, findsOneWidget);
      expect(month, findsOneWidget);
      expect(tester.getTopLeft(total).dy, lessThan(tester.getTopLeft(week).dy));
      expect(tester.takeException(), isNull);
    });
  }
}
