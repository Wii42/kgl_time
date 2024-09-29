import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kgl_time/format_duration.dart';
import 'package:kgl_time/work_entries.dart';
import 'package:kgl_time/work_entry.dart';
import 'package:kgl_time/work_entry_preview.dart';
import 'package:provider/provider.dart';

import 'date_week.dart';
import 'kgl_page.dart';

class HomePage extends KglPage {
  const HomePage({super.key, required super.appTitle});

  @override
  Widget body(BuildContext context) {
    return Consumer<WorkEntries>(
      builder: (BuildContext context, workEntries, Widget? _) {
        //Future.delayed(Duration(seconds: 2), () {
        //  workEntries.add(WorkEntry(
        //    id: '4',
        //    workDuration: const Duration(hours: 2),
        //    date: DateTime.now().subtract(const Duration(days: 2)),
        //    description: 'Test3',
        //    categories: [WorkCategory.phoneCall],
        //  ));
        //});
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FilledButton(
              onPressed: () {context.go('/newEntry');},
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Neuen Eintrag erfassen',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.apply(color: Colors.white)),
                    Icon(Icons.add),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text('Letzte Einträge'),
            for (WorkEntry entry in workEntries.entries.take(5))
              WorkEntryPreview(workEntry: entry),
            ElevatedButton(
                onPressed: () {context.go('/allEntries');}, child: Text('Alle Einträge anzeigen')),
            const SizedBox(height: 32),
            Center(
              child: Text(
                  'Aktuelle Woche: ${formatDuration(totalThisWeek(workEntries.entries))}'),
            ),
            Center(
                child: Text(
                    'Aktueller Monat: ${formatDuration(totalThisMonth(workEntries.entries))}')),
          ],
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
