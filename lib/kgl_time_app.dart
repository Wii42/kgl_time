import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'data_model/work_entries.dart';
import 'data_model/work_entry.dart';
import 'pages/all_entries_page.dart';
import 'pages/home_page.dart';
import 'pages/new_entry_page.dart';

class KglTimeApp extends StatelessWidget {
  final String appTitle;

  final Color primaryColor = const Color(0xff2a5c9f);
  final Color appBarColor = const Color(0xff5a9859);

  final List<WorkEntry> initialEntries;

  const KglTimeApp(
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
        ).copyWith(
            appBarTheme: AppBarTheme(
                backgroundColor: appBarColor, foregroundColor: Colors.white)),
        routerConfig: router,
      ),
    );
  }
}