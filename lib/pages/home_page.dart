import 'dart:async';

import 'package:animated_list_plus/transitions.dart';
import 'package:clock/clock.dart';
import 'package:go_router/go_router.dart';
import 'package:kgl_time/always_filling_scroll_view.dart';
import 'package:kgl_time/app_route.dart';
import 'package:kgl_time/data_model/work_entries.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/date_week.dart';
import 'package:kgl_time/format_duration.dart';
import 'package:kgl_time/helpers.dart';
import 'package:kgl_time/kgl_time_app.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/work_entry_time_tracker.dart';
import 'package:kgl_time/work_entry_widgets/work_entry_preview.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../width_constrained_list_view.dart';
import 'kgl_page.dart';

class HomePage extends KglPage {
  const HomePage({super.key, required super.appTitle});

  @override
  Widget body(BuildContext context) {
    AppLocalizations? loc = AppLocalizations.of(context);
    return Consumer<WorkEntries>(
      builder: (BuildContext context, workEntries, Widget? _) {
        return AlwaysFillingScrollView(
          maxWidth: KglTimeApp.maxPageWidth + 32,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton(
                  onPressed: () => context.push(AppRoute.newEntry.path),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            loc?.createNewEntry ?? '<createNewEntry>',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.apply(color: Colors.white),
                          ),
                        ),
                        Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                WorkEntryTimeTracker(),
                const SizedBox(height: 32),
                if (workEntries.entries.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(loc?.recentEntries ?? '<recentEntries>'),
                      AnimatedWidthConstrainedListView<WorkEntry>(
                        items: workEntries.entries.take(3).toList(),
                        //padding: const EdgeInsets.symmetric(vertical: 16),
                        itemBuilder: (context, animation, entry, index) => SizeFadeTransition(
                          animation: animation,
                          axis: Axis.vertical,
                          child: WorkEntryPreview(workEntry: entry, key: ValueKey(entry.id)),
                        ),
                        areItemsTheSame: (WorkEntry oldItem, WorkEntry newItem) {
                          return oldItem.id == newItem.id;
                        },
                        shrinkWrap: true,
                        addHorizontalPadding: false,
                        primary: false,
                      ),
                    ],
                  )
                else
                  Center(child: Text(loc?.noExistingEntries ?? '<noEntries>')),
                const SizedBox(height: 32),
                _WorkDurationOfCurrentCalendarUnits(workEntries: workEntries.entries),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WorkDurationOfCurrentCalendarUnits extends StatefulWidget {
  final List<WorkEntry> workEntries;

  const new({required this.workEntries});

  @override
  State<_WorkDurationOfCurrentCalendarUnits> createState() =>
      _WorkDurationOfCurrentCalendarUnitsState();
}

class _WorkDurationOfCurrentCalendarUnitsState extends State<_WorkDurationOfCurrentCalendarUnits> {
  Timer? _midnightTimer;
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: _refresh,
      onPause: () => _midnightTimer?.cancel(),
    );
    _scheduleNextMidnight();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? loc = AppLocalizations.of(context);
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          '${loc?.today}: ${formatDuration(totalToday(widget.workEntries))}',
          style: textTheme.bodyLarge,
        ),
        Text(
          '${loc?.currentWeek}: ${formatDuration(totalThisWeek(widget.workEntries))}',
          style: textTheme.bodyLarge,
        ),
        Text(
          '${loc?.currentMonth}: ${formatDuration(totalThisMonth(widget.workEntries))}',
          style: textTheme.bodyLarge,
        ),
      ],
    );
  }

  static Duration totalToday(List<WorkEntry> workEntries) {
    final DateTime today = clock.now();
    return totalWorkDuration(
      workEntries.where((WorkEntry entry) => entry.date.isSameDate(today)).toList(),
    );
  }

  static Duration totalThisWeek(List<WorkEntry> workEntries) {
    DateWeek thisWeek = DateWeek.current();
    List<WorkEntry> thisWeekEntries = workEntries
        .where((entry) => thisWeek.contains(entry.date))
        .toList();
    return totalWorkDuration(thisWeekEntries);
  }

  static Duration totalThisMonth(List<WorkEntry> workEntries) {
    int currentMonth = clock.now().month;
    int currentYear = clock.now().year;
    List<WorkEntry> thisMonthEntries = workEntries
        .where((entry) => entry.date.month == currentMonth && entry.date.year == currentYear)
        .toList();
    return totalWorkDuration(thisMonthEntries);
  }

  static Duration totalWorkDuration(List<WorkEntry> workEntries) {
    return workEntries.fold(
      Duration.zero,
      (previousValue, element) => previousValue + element.workDuration,
    );
  }

  void _scheduleNextMidnight() {
    _midnightTimer?.cancel();

    final DateTime now = clock.now();
    final DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1);

    _midnightTimer = Timer(
      nextMidnight.difference(now),
      _refresh,
    );
  }

  void _refresh() {
    if (!mounted) return;

    setState(() {});
    _scheduleNextMidnight();
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    _lifecycleListener.dispose();
    super.dispose();
  }
}
