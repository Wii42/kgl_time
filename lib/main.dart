import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kgl_time/work_entries.dart';
import 'package:kgl_time/work_entry.dart';
import 'package:provider/provider.dart';

import 'all_entries_page.dart';
import 'home_page.dart';
import 'new_entry_page.dart';

List<WorkEntry> mockWorkEntries = [
  WorkEntry(
    id: 1,
    workDuration: const Duration(hours: 1),
    date: DateTime.now(),
    description: 'Test',
    categories: [WorkCategory.phoneCall],
  ),
  WorkEntry(
    id: 2,
    workDuration: const Duration(minutes: 30),
    date: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
    description: 'Test2',
    categories: [WorkCategory.category2],
  ),
  WorkEntry(
    id: 3,
    workDuration: const Duration(hours: 1, minutes: 30),
    date: DateTime.now().subtract(const Duration(days: 7)),
    description: 'old entry',
    categories: [WorkCategory.category4, WorkCategory.category5],
  ),
];

void main() async {
  await initializeDateFormatting(
      'de', '_'); // initialize the date formatting for German
  runApp(MyApp(appTitle: 'KGL Time', initialEntries: mockWorkEntries));
}

class MyApp extends StatelessWidget {
  final String appTitle;

  final Color primaryColor = const Color(0xff2a5c9f);
  final Color appBarColor = const Color(0xff5a9859);

  final List<WorkEntry> initialEntries;

  const MyApp(
      {super.key, required this.appTitle, this.initialEntries = const []});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
            path: '/',
            builder: (context, state) => HomePage(
                  appTitle: appTitle,
                ),
            routes: [
              GoRoute(
                  path: 'allEntries',
                  builder: (context, state) =>
                      AllEntriesPage(appTitle: appTitle)),
              GoRoute(
                  path: 'newEntry',
                  builder: (context, state) {
                    WorkEntry? existingEntry;
                    if (state.extra is WorkEntry) {
                      existingEntry = state.extra as WorkEntry;
                    }
                    return NewEntryPage(
                        appTitle: appTitle, existingEntry: existingEntry);
                  }),
            ]),
      ],
    );
    return ChangeNotifierProvider<WorkEntries>(
      create: (context) => WorkEntries(initialEntries),
      child: MaterialApp.router(
        locale: const Locale('de'),
        title: appTitle,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
            useMaterial3: true,
            ).copyWith(appBarTheme: AppBarTheme(backgroundColor: appBarColor, foregroundColor: Colors.white)),
        routerConfig: router,
      ),
    );
  }
}
