import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';

final testClockStart = DateTime.utc(2026, 10, 31, 12);

Matcher timeBetween(DateTime earliest, DateTime latest) => isA<DateTime>()
    .having((time) => time.compareTo(earliest), 'comparison to earliest', greaterThanOrEqualTo(0))
    .having((time) => time.compareTo(latest), 'comparison to latest', lessThanOrEqualTo(0));

/// Fix the starting date while advancing at real elapsed speed.
Future<void> _withAdvancingClock(FutureOr<void> Function() body) async {
  final stopwatch = Stopwatch()..start();
  final testClock = Clock(() => testClockStart.add(stopwatch.elapsed));
  try {
    await withClock(testClock, body);
  } finally {
    stopwatch.stop();
  }
}

/// Each test gets its own stopwatch, starting when the callback executes.
void testWithAdvancingClock(String description, FutureOr<void> Function() body) {
  test(description, () => _withAdvancingClock(body));
}

/// The clock advances in real time, independently of simulated pump durations.
void testWidgetsWithAdvancingClock(String description, WidgetTesterCallback body) {
  testWidgets(
    description,
    (tester) => _withAdvancingClock(() => body(tester)),
  );
}
