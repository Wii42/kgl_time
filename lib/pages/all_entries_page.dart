import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kgl_time/data_model/grouped_work_entries.dart';
import 'package:kgl_time/data_model/work_entries.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/enums/calendar_unit.dart';
import 'package:kgl_time/format_duration.dart';
import 'package:kgl_time/work_entry_widgets/work_entry_details.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../kgl_time_app.dart';
import 'kgl_page.dart';

class AllEntriesPage extends KglPage {
  @override
  String? pageTitle(AppLocalizations? loc) => loc?.allEntries;
  const AllEntriesPage({super.key, required super.appTitle});

  @override
  Widget body(BuildContext context) => Consumer<WorkEntries>(
      builder: (context, workEntries, _) =>
          _AllEntriesStatefulPage(workEntries: workEntries, key: key));
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

  /// // GlobalKey to track the button size
  final GlobalKey _buttonKey = GlobalKey();
  double _buttonHeight = 0; // Variable to store the height of the button

  @override
  void initState() {
    super.initState();
    _updateGroupedEntries();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getButtonHeight();
    });
  }

  @override
  void didUpdateWidget(covariant _AllEntriesStatefulPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateGroupedEntries();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? loc = AppLocalizations.of(context);
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            key: _buttonKey, // Assign the key to the button
            padding: const EdgeInsets.all(12.0),
            child: SegmentedButton<CalendarUnit>(
              segments: [
                ButtonSegment(
                    value: CalendarUnit.week,
                    label: Text(loc?.groupByWeek ?? '<byWeek>')),
                ButtonSegment(
                    value: CalendarUnit.month,
                    label: Text(loc?.groupByMonth ?? '<byMonth>')),
              ],
              selected: {_selectedCalendarUnit},
              onSelectionChanged: (Set<CalendarUnit> selected) {
                assert(selected.length == 1);
                setState(() {
                  _selectedCalendarUnit = selected.single;
                  _updateGroupedEntries();
                });
              },
              style: solidUnselectedBackgroundStyle(context),
            ),
          ),
        ),
        LayoutBuilder(builder: (context, constraints) {
          return ListView(
              padding: const EdgeInsets.all(16),
              children: _constrainWidth([
                SizedBox(
                  height: max(_buttonHeight - 8, 0),
                ), // To avoid collision with the SegmentedButton
                for (GroupedWorkEntries entryGroup in _groupedEntries) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${formatCalendarUnitValue(entryGroup.calendarUnitValue, entryGroup.calendarUnit, loc: loc)} ${entryGroup.year}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(formatDuration(entryGroup.totalWorkDuration())),
                    ],
                  ),
                  for (WorkEntry entry in entryGroup.entries)
                    WorkEntryDetails(workEntry: entry),
                  SizedBox(height: 16),
                ],
              ], constraints.maxWidth - 32) // Subtract padding,
              );
        }),
      ].reversed.toList(),
    );
  }

  /// Sets the background color of the button if not selected to [color] if provided or the default background color
  ButtonStyle solidUnselectedBackgroundStyle(BuildContext context,
      {Color? color}) {
    return ButtonStyle(backgroundColor:
        WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return Theme.of(context)
            .segmentedButtonTheme
            .style
            ?.backgroundColor
            ?.resolve(states); // use default
      }
      return color ?? Theme.of(context).canvasColor;
    }));
  }

  void _updateGroupedEntries() {
    _groupedEntries = GroupedWorkEntries.groupEntriesByCalendarUnit(
        widget.workEntries.entries, _selectedCalendarUnit);
  }

  String formatCalendarUnitValue(
      int calendarUnitValue, CalendarUnit calendarUnit,
      {required AppLocalizations? loc}) {
    switch (calendarUnit) {
      case CalendarUnit.week:
        return '${loc?.calendarWeek} $calendarUnitValue,';
      case CalendarUnit.month:
        return DateFormat('MMMM', loc?.localeName).format(DateTime(0, calendarUnitValue));
    }
  }

  void _getButtonHeight() {
    // Use the key to get the RenderBox of the button and measure its height
    final RenderBox renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox;
    final double height = renderBox.size.height;

    setState(() {
      _buttonHeight = height; // Update the button height
    });
  }

  List<Widget> _constrainWidth(
      List<Widget> children, double maxAvailableWidth) {
    return children
        .map((child) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: min(KglTimeApp.maxPageWidth, maxAvailableWidth),
                  ),
                  child: child,
                ),
              ],
            ))
        .toList();
  }
}
