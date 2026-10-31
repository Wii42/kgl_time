import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kgl_time/data_model/key_values.dart';
import 'package:kgl_time/data_model/work_entries.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/pages/home_page.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'support/memory_storage.dart';

WorkEntry _entry(int id, DateTime date, int minutes) => WorkEntry.fromDuration(
  date: date,
  duration: Duration(minutes: minutes),
)..id = id;

/// Calendar rollover tests must advance both app time and timers together.
/// Ordinary tests can continue using the real-speed clock in test_clock.dart.
class _CalendarTestClock {
  final WidgetTester tester;
  DateTime _origin;
  DateTime _timerOrigin;

  _CalendarTestClock(this.tester, this._origin) : _timerOrigin = tester.binding.clock.now();

  DateTime get now => _origin.add(tester.binding.clock.now().difference(_timerOrigin));

  Future<void> pumpUntil(DateTime target) async {
    final Duration elapsed = target.difference(now);
    expect(elapsed.isNegative, isFalse, reason: 'Calendar test cannot pump backwards');
    await tester.pump(elapsed);
    await tester.pump();
  }

  /// Simulate time passing while the process is suspended: no timer callbacks
  /// or frame rebuilds run until the application receives its resume event.
  void jumpWhileSuspended(DateTime target) {
    _origin = target;
    _timerOrigin = tester.binding.clock.now();
  }
}

Future<void> _runCalendarTest(
  WidgetTester tester, {
  required DateTime start,
  required List<WorkEntry> initialEntries,
  required Future<void> Function(_CalendarTestClock time, WorkEntries entries) body,
}) async {
  final MemoryStorage storage = MemoryStorage();
  PersistentStorageService.setImplementation(storage);
  addTearDown(storage.close);
  final _CalendarTestClock time = _CalendarTestClock(tester, start);
  tester.view.physicalSize = const Size(390, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await withClock(Clock(() => time.now), () async {
    final WorkEntries entries = WorkEntries(initialEntries);
    final KeyValues settings = KeyValues(<String, dynamic>{});
    try {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WorkEntries>.value(value: entries),
            ChangeNotifierProvider<KeyValues>.value(value: settings),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomePage(appTitle: 'Test'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await body(time, entries);
    } finally {
      // Also clean up when an assertion fails, so a pending midnight timer
      // does not obscure the actual regression with a teardown failure.
      await tester.pumpWidget(const SizedBox.shrink());
      entries.dispose();
      settings.dispose();
    }
  });
}

void main() {
  setUpAll(() => initializeDateFormatting('en'));

  testWidgets('today changes at midnight and the trigger rearms for the following day', (
    WidgetTester tester,
  ) async {
    await _runCalendarTest(
      tester,
      start: DateTime(2026, 10, 20, 23, 59, 50),
      initialEntries: <WorkEntry>[
        _entry(1, DateTime(2026, 10, 20), 10),
        _entry(2, DateTime(2026, 10, 21), 20),
        _entry(3, DateTime(2026, 10, 22), 30),
      ],
      body: (_CalendarTestClock time, WorkEntries entries) async {
        expect(find.text('Today: 10 min'), findsOneWidget);
        await time.pumpUntil(DateTime(2026, 10, 21).subtract(const Duration(milliseconds: 1)));
        expect(find.text('Today: 10 min'), findsOneWidget);
        await time.pumpUntil(DateTime(2026, 10, 21));
        expect(find.text('Today: 20 min'), findsOneWidget);
        await time.pumpUntil(DateTime(2026, 10, 22));
        expect(find.text('Today: 30 min'), findsOneWidget);
      },
    );
  });

  testWidgets('Sunday to Monday refreshes the week as well as today', (WidgetTester tester) async {
    await _runCalendarTest(
      tester,
      start: DateTime(2026, 10, 25, 23, 59, 50),
      initialEntries: <WorkEntry>[
        _entry(1, DateTime(2026, 10, 25), 10),
        _entry(2, DateTime(2026, 10, 26), 20),
      ],
      body: (_CalendarTestClock time, WorkEntries entries) async {
        expect(find.text('Current week: 10 min'), findsOneWidget);
        await time.pumpUntil(DateTime(2026, 10, 26));
        expect(find.text('Today: 20 min'), findsOneWidget);
        expect(find.text('Current week: 20 min'), findsOneWidget);
        expect(find.text('Current month: 30 min'), findsOneWidget);
      },
    );
  });

  testWidgets('New Year refreshes today and month while preserving the same ISO week', (
    WidgetTester tester,
  ) async {
    await _runCalendarTest(
      tester,
      start: DateTime(2026, 12, 31, 23, 59, 50),
      initialEntries: <WorkEntry>[
        _entry(1, DateTime(2026, 12, 31), 10),
        _entry(2, DateTime(2027, 1, 1), 20),
      ],
      body: (_CalendarTestClock time, WorkEntries entries) async {
        expect(find.text('Current month: 10 min'), findsOneWidget);
        expect(find.text('Current week: 30 min'), findsOneWidget);
        await time.pumpUntil(DateTime(2027, 1, 1));
        expect(find.text('Today: 20 min'), findsOneWidget);
        expect(find.text('Current month: 20 min'), findsOneWidget);
        expect(find.text('Current week: 30 min'), findsOneWidget);
      },
    );
  });

  // Run with TZ=Europe/Zurich to cover actual 23- and 25-hour days.
  for (final DateTime day in <DateTime>[DateTime(2026, 3, 29), DateTime(2026, 10, 25)]) {
    testWidgets('midnight trigger follows local dates across the DST transition on $day', (
      WidgetTester tester,
    ) async {
      final DateTime nextDay = DateTime(day.year, day.month, day.day + 1);
      final DateTime followingDay = DateTime(day.year, day.month, day.day + 2);
      await _runCalendarTest(
        tester,
        start: DateTime(day.year, day.month, day.day - 1, 23, 59, 50),
        initialEntries: <WorkEntry>[
          _entry(1, DateTime(day.year, day.month, day.day - 1), 5),
          _entry(2, day, 10),
          _entry(3, nextDay, 20),
          _entry(4, followingDay, 30),
        ],
        body: (_CalendarTestClock time, WorkEntries entries) async {
          expect(find.text('Today: 5 min'), findsOneWidget);
          await time.pumpUntil(day);
          expect(find.text('Today: 10 min'), findsOneWidget);
          await time.pumpUntil(nextDay.subtract(const Duration(milliseconds: 1)));
          expect(find.text('Today: 10 min'), findsOneWidget);
          await time.pumpUntil(nextDay);
          expect(find.text('Today: 20 min'), findsOneWidget);
          await time.pumpUntil(followingDay);
          expect(find.text('Today: 30 min'), findsOneWidget);
        },
      );
    });
  }

  testWidgets('resuming after suspended timers refreshes totals and schedules the next midnight', (
    WidgetTester tester,
  ) async {
    await _runCalendarTest(
      tester,
      start: DateTime(2026, 12, 31, 23, 59, 50),
      initialEntries: <WorkEntry>[
        _entry(1, DateTime(2026, 12, 31), 10),
        _entry(2, DateTime(2027, 1, 1), 20),
        _entry(3, DateTime(2027, 1, 2), 30),
      ],
      body: (_CalendarTestClock time, WorkEntries entries) async {
        expect(find.text('Today: 10 min'), findsOneWidget);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        time.jumpWhileSuspended(DateTime(2027, 1, 1, 12));
        expect(find.text('Today: 10 min'), findsOneWidget);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await tester.pumpAndSettle();
        expect(find.text('Today: 20 min'), findsOneWidget);
        expect(find.text('Current month: 50 min'), findsOneWidget);
        await time.pumpUntil(DateTime(2027, 1, 2));
        expect(find.text('Today: 30 min'), findsOneWidget);
      },
    );
  });

  testWidgets('entry notifications still refresh the extracted totals', (
    WidgetTester tester,
  ) async {
    await _runCalendarTest(
      tester,
      start: DateTime(2026, 10, 20, 12),
      initialEntries: <WorkEntry>[_entry(1, DateTime(2026, 10, 20), 10)],
      body: (_CalendarTestClock time, WorkEntries entries) async {
        expect(find.text('Today: 10 min'), findsOneWidget);
        final WorkEntry added = _entry(2, DateTime(2026, 10, 20), 20);
        entries.add(added);
        await tester.pumpAndSettle();
        expect(find.text('Today: 30 min'), findsOneWidget);
        entries.moveToTrashBin(added);
        await tester.pumpAndSettle();
        expect(find.text('Today: 10 min'), findsOneWidget);
      },
    );
  });

  testWidgets('removing the widget cleans up its timer and resume listener', (
    WidgetTester tester,
  ) async {
    await _runCalendarTest(
      tester,
      start: DateTime(2026, 10, 20, 23, 59, 50),
      initialEntries: <WorkEntry>[_entry(1, DateTime(2026, 10, 20), 10)],
      body: (_CalendarTestClock time, WorkEntries entries) async {
        await tester.pumpWidget(const SizedBox.shrink());
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        time.jumpWhileSuspended(DateTime(2026, 10, 21, 12));
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await tester.pump();
        await time.pumpUntil(DateTime(2026, 10, 23));
        expect(tester.takeException(), isNull);
      },
    );
  });
}
