import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kgl_time/format_duration.dart';
import 'package:kgl_time/kgl_page.dart';
import 'package:kgl_time/work_entries.dart';
import 'package:kgl_time/work_entry.dart';
import 'package:kgl_time/work_entry_details.dart';
import 'package:provider/provider.dart';
import 'package:week_number/iso.dart';

class AllEntriesPage extends KglPage {
  @override
  final String pageTitle = 'Alle Einträge';
  const AllEntriesPage({super.key, required super.appTitle});

  @override
  Widget body(BuildContext context) => Consumer<WorkEntries>(
      builder: (context, workEntries, _) =>
          _AllEntriesStatefulPage(workEntries: workEntries));
}

class _AllEntriesStatefulPage extends StatefulWidget {
  final WorkEntries workEntries;
  const _AllEntriesStatefulPage({super.key, required this.workEntries});

  @override
  _AllEntriesStatefulPageState createState() => _AllEntriesStatefulPageState();
}

class _AllEntriesStatefulPageState extends State<_AllEntriesStatefulPage> {
  CalendarUnit _selectedCalendarUnit = CalendarUnit.week;

  late List<GroupedWorkEntries> _groupedEntries;

  @override
  void initState() {
    super.initState();
    _updateGroupedEntries();
  }

  @override
  void didUpdateWidget(covariant _AllEntriesStatefulPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateGroupedEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SegmentedButton<CalendarUnit>(
                segments: [
                  ButtonSegment(
                      value: CalendarUnit.week, label: Text('Nach Woche')),
                  ButtonSegment(
                      value: CalendarUnit.month, label: Text('Nach Monat'))
                ],
                selected: {
                  _selectedCalendarUnit
                },
                onSelectionChanged: (Set<CalendarUnit> selected) {
                  assert(selected.length == 1);
                  setState(() {
                    _selectedCalendarUnit = selected.single;
                    _updateGroupedEntries();
                  });
                }),
          ),
        ),
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Padding(
                padding: const EdgeInsets.all(
                    16)), // To avoid collision with the SegmentedButton
            for (GroupedWorkEntries entryGroup in _groupedEntries) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${formatCalendarUnitValue(entryGroup.calendarUnitValue, entryGroup.calendarUnit)} ${entryGroup.year}'),
                  Text(formatDuration(entryGroup.totalWorkDuration())),
                ],
              ),
              for (WorkEntry entry in entryGroup.entries)
                WorkEntryDetails(workEntry: entry),
              SizedBox(height: 16),
            ],
          ],
        ),
      ].reversed.toList(),
    );
  }

  void _updateGroupedEntries() {
    _groupedEntries = GroupedWorkEntries.groupEntriesByCalendarUnit(
        widget.workEntries.entries, _selectedCalendarUnit);
    print(
        "Grouped ${widget.workEntries.entries.length} in ${_groupedEntries.length} groups by $_selectedCalendarUnit");
  }

  String formatCalendarUnitValue(
      int calendarUnitValue, CalendarUnit calendarUnit) {
    switch (calendarUnit) {
      case CalendarUnit.week:
        return 'Kalenderwoche $calendarUnitValue,';
      case CalendarUnit.month:
        return DateFormat('MMMM').format(DateTime(0, calendarUnitValue));
    }
  }
}

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

enum CalendarUnit {
  week,
  month,
}
