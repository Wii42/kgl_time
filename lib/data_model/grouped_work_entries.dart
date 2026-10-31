import 'package:week_number/iso.dart';

import '../enums/calendar_unit.dart';
import 'work_entry.dart';

/// WorkEntries which are in a specific calendar day, week, or month.
class GroupedWorkEntries {
  final List<WorkEntry> entries;
  final CalendarUnit calendarUnit;
  final int calendarUnitValue; // Day of year, ISO week number, or month number.
  final int year; // ISO week-year for weeks, calendar year for days and months.

  const GroupedWorkEntries({
    required this.entries,
    required this.calendarUnit,
    required this.calendarUnitValue,
    required this.year,
  });

  Duration totalWorkDuration() {
    return entries.fold(
      Duration.zero,
      (previousValue, element) => previousValue + element.workDuration,
    );
  }

  static List<GroupedWorkEntries> groupEntriesByCalendarUnit(
    List<WorkEntry> entries,
    CalendarUnit calendarUnit,
  ) {
    Map<(int, int), List<WorkEntry>> entriesByCalendarUnit = {};
    for (WorkEntry entry in entries) {
      int calendarUnitNumber = switch (calendarUnit) {
        // UTC calendar dates give a stable day of year across DST changes.
        CalendarUnit.day =>
          DateTime.utc(
                entry.date.year,
                entry.date.month,
                entry.date.day,
              ).difference(DateTime.utc(entry.date.year)).inDays +
              1,
        CalendarUnit.week => entry.date.weekNumber,
        CalendarUnit.month => entry.date.month,
      };
      // An ISO week belongs to the year containing its Thursday.
      int year = switch (calendarUnit) {
        CalendarUnit.day => entry.date.year,
        CalendarUnit.week => yearOfIsoWeek(entry),
        CalendarUnit.month => entry.date.year,
      };
      entriesByCalendarUnit.putIfAbsent((calendarUnitNumber, year), () => []).add(entry);
    }
    return entriesByCalendarUnit.entries
        .map(
          (entry) => GroupedWorkEntries(
            entries: entry.value,
            calendarUnit: calendarUnit,
            calendarUnitValue: entry.key.$1,
            year: entry.key.$2,
          ),
        )
        .toList();
  }

  static int yearOfIsoWeek(WorkEntry entry) {
    return DateTime(
      entry.date.year,
      entry.date.month,
      entry.date.day + DateTime.thursday - entry.date.weekday,
    ).year;
  }
}
