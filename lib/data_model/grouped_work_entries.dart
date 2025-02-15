import 'package:week_number/iso.dart';

import '../enums/calendar_unit.dart';
import 'work_entry.dart';

/// WorkEntries which are in a specific calendar unit, e.g. week or month
class GroupedWorkEntries {
  final List<WorkEntry> entries;
  final CalendarUnit calendarUnit;
  final int calendarUnitValue; // e.g. week number or month number
  final int year;

  const GroupedWorkEntries(
      {required this.entries,
      required this.calendarUnit,
      required this.calendarUnitValue,
      required this.year});

  Duration totalWorkDuration() {
    return entries.fold(Duration.zero,
        (previousValue, element) => previousValue + element.workDuration);
  }

  static List<GroupedWorkEntries> groupEntriesByCalendarUnit(
      List<WorkEntry> entries, CalendarUnit calendarUnit) {
    Map<(int, int), List<WorkEntry>> entriesByCalendarUnit = {};
    for (WorkEntry entry in entries) {
      int calendarUnitNumber = switch (calendarUnit) {
        CalendarUnit.week => entry.date.weekNumber,
        CalendarUnit.month => entry.date.month,
      };
      entriesByCalendarUnit.putIfAbsent(
          (calendarUnitNumber, entry.date.year), () => []).add(entry);
    }
    return entriesByCalendarUnit.entries
        .map((entry) => GroupedWorkEntries(
            entries: entry.value,
            calendarUnit: calendarUnit,
            calendarUnitValue: entry.key.$1,
            year: entry.key.$2))
        .toList();
  }
}
