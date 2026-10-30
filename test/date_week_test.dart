import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/date_week.dart';

void main() {
  test('week runs from Monday midnight up to but excluding next Monday', () {
    final week = DateWeek.from(DateTime(2026, 2, 11, 15, 30));
    expect(week.start, DateTime(2026, 2, 9));
    expect(week.end, DateTime(2026, 2, 16));
    expect(week.contains(week.start), isTrue);
    expect(
      week.contains(week.start.subtract(const Duration(microseconds: 1))),
      isFalse,
    );
    expect(
      week.contains(week.end.subtract(const Duration(microseconds: 1))),
      isTrue,
    );
    expect(week.contains(week.end), isFalse);
  });

  test('week navigation crosses year boundaries and is reversible', () {
    final week = DateWeek.from(DateTime(2021, 1, 1));
    expect(week.start, DateTime(2020, 12, 28));
    expect(week.next().start, DateTime(2021, 1, 4));
    expect(week.next().previous().start, week.start);
    expect(week.previous().next().end, week.end);
  });

  // Run with TZ=Europe/Zurich to exercise actual offset changes.
  for (final dates in [
    [DateTime(2026, 3, 29, 15), DateTime(2026, 3, 23), DateTime(2026, 3, 30)],
    [
      DateTime(2026, 10, 25, 15),
      DateTime(2026, 10, 19),
      DateTime(2026, 10, 26),
    ],
  ]) {
    test('calendar boundaries stay at midnight around ${dates.first}', () {
      final week = DateWeek.from(dates[0]);
      expect(week.start, dates[1]);
      expect(week.end, dates[2]);
      expect(week.next().start, dates[2]);
      expect(week.next().previous().start, dates[1]);
      expect(week.previous().next().end, dates[2]);
      expect(week.contains(dates[2]), isFalse);
    });
  }
}
