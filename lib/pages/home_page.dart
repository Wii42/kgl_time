import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kgl_time/data_model/work_entries.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/date_week.dart';
import 'package:kgl_time/format_duration.dart';
import 'package:kgl_time/kgl_time_app.dart';
import 'package:kgl_time/work_entry_time_tracker.dart';
import 'package:kgl_time/work_entry_widgets/work_entry_preview.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'kgl_page.dart';

class HomePage extends KglPage {
  const HomePage({super.key, required super.appTitle});

  @override
  Widget body(BuildContext context) {
    AppLocalizations? loc = AppLocalizations.of(context);
    TextTheme textTheme = Theme.of(context).textTheme;
    return Consumer<WorkEntries>(
      builder: (BuildContext context, workEntries, Widget? _) {
        return KglPage.alwaysFillingScrollView(
          maxWidth: KglTimeApp.maxPageWidth,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton(
                  onPressed: () => context.go('/newEntry'),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(loc?.createNewEntry ?? '<createNewEntry>',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              softWrap: true,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.apply(color: Colors.white)),
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
                      for (WorkEntry entry in workEntries.entries.take(3))
                        WorkEntryPreview(workEntry: entry),
                      ElevatedButton(
                          onPressed: () => context.go('/allEntries'),
                          child: Text(loc?.showAllEntries ?? '')),
                    ],
                  )
                else
                  Center(child: Text(loc?.noExistingEntries ?? '<noEntries>')),
                const SizedBox(height: 32),
                Column(
                  children: [
                    Text(
                      '${loc?.currentWeek}: ${formatDuration(totalThisWeek(workEntries.entries))}',
                      style: textTheme.bodyLarge,
                    ),
                    Text(
                        '${loc?.currentMonth}: ${formatDuration(totalThisMonth(workEntries.entries))}',
                        style: textTheme.bodyLarge),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Duration totalThisWeek(List<WorkEntry> workEntries) {
    DateWeek thisWeek = DateWeek.current();
    List<WorkEntry> thisWeekEntries =
        workEntries.where((entry) => thisWeek.contains(entry.date)).toList();
    return totalWorkDuration(thisWeekEntries);
  }

  Duration totalThisMonth(List<WorkEntry> workEntries) {
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;
    List<WorkEntry> thisMonthEntries = workEntries
        .where((entry) =>
            entry.date.month == currentMonth && entry.date.year == currentYear)
        .toList();
    return totalWorkDuration(thisMonthEntries);
  }

  Duration totalWorkDuration(List<WorkEntry> workEntries) {
    return workEntries.fold(Duration.zero,
        (previousValue, element) => previousValue + element.workDuration);
  }
}
