import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/data_model/grouped_work_entries.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/enums/calendar_unit.dart';

WorkEntry entry(DateTime date, int minutes) => WorkEntry.fromDuration(
  date: date,
  duration: Duration(minutes: minutes),
);

void main() {
  for (final unit in CalendarUnit.values) {
    test('empty $unit groups and totals', () {
      expect(GroupedWorkEntries.groupEntriesByCalendarUnit([], unit), isEmpty);
      expect(
        GroupedWorkEntries(
          entries: [],
          calendarUnit: unit,
          calendarUnitValue: 1,
          year: 2026,
        ).totalWorkDuration(),
        Duration.zero,
      );
    });
  }

  test('monthly groups separate months and years and sum every entry', () {
    final entries = [
      entry(DateTime(2025, 1, 31), 30),
      entry(DateTime(2026, 1, 1), 60),
      entry(DateTime(2026, 1, 31), 45),
      entry(DateTime(2026, 2, 1), 15),
    ];
    final groups = GroupedWorkEntries.groupEntriesByCalendarUnit(
      entries,
      CalendarUnit.month,
    );
    expect(groups, hasLength(3));
    expect(
      {
        for (final g in groups)
          (g.year, g.calendarUnitValue): g.totalWorkDuration().inMinutes,
      },
      {(2025, 1): 30, (2026, 1): 105, (2026, 2): 15},
    );
    expect(groups.expand((g) => g.entries), unorderedEquals(entries));
  });

  test('Sunday and Monday belong to different weeks', () {
    final groups = GroupedWorkEntries.groupEntriesByCalendarUnit([
      entry(DateTime(2026, 10, 25), 30),
      entry(DateTime(2026, 10, 26), 60),
    ], CalendarUnit.week);
    expect(groups, hasLength(2));
    expect(groups.map((g) => g.totalWorkDuration().inMinutes), [30, 60]);
  });

  test('ISO week 53 stays together across New Year', () {
    final groups = GroupedWorkEntries.groupEntriesByCalendarUnit([
      entry(DateTime(2020, 12, 31), 30),
      entry(DateTime(2021, 1, 1), 45),
      entry(DateTime(2021, 1, 4), 60),
    ], CalendarUnit.week);
    expect(
      {
        for (final g in groups)
          (g.year, g.calendarUnitValue): g.totalWorkDuration().inMinutes,
      },
      {(2020, 53): 75, (2021, 1): 60},
    );
  });

  test('late December can belong to week 1 of the following ISO year', () {
    final groups = GroupedWorkEntries.groupEntriesByCalendarUnit([
      entry(DateTime(2024, 1, 1), 10),
      entry(DateTime(2024, 12, 30), 20),
      entry(DateTime(2025, 1, 1), 30),
    ], CalendarUnit.week);
    expect(
      {
        for (final g in groups)
          (g.year, g.calendarUnitValue): g.totalWorkDuration().inMinutes,
      },
      {(2024, 1): 10, (2025, 1): 50},
    );
  });
}
