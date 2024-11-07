import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:kgl_time/data_model/key_values.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/pages/settings_page.dart';
import 'package:kgl_time/helpers.dart';
import 'package:provider/provider.dart';

import 'data_model/work_categories.dart';
import 'data_model/work_entries.dart';
import 'data_model/work_entry.dart';
import 'pages/all_entries_page.dart';
import 'pages/home_page.dart';
import 'pages/new_entry_page.dart';

class KglTimeApp extends StatelessWidget {
  final String appTitle;

  static const Color primaryColor = Color(0xff0067b1);
  static const Color appBarColor = Color(0xff4a8e3b);
  static const Color actionColor = Color(0xffc62828);
  static const double maxPageWidth = 800;

  final List<WorkEntry> initialEntries;
  final List<WorkCategory> initialCategories;
  final Map<String, dynamic> initialKeyValueStorage;

  const KglTimeApp(
      {super.key,
      required this.appTitle,
      this.initialEntries = const [],
      this.initialCategories = const [],
      this.initialKeyValueStorage = const {}});

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
              GoRoute(
                  path: 'settings',
                  builder: (context, state) =>
                      SettingsPage(appTitle: appTitle)),
            ]),
      ],
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WorkEntries>(
          create: (context) => WorkEntries(initialEntries),
        ),
        ChangeNotifierProvider<WorkCategories>(
          create: (context) => WorkCategories(initialCategories),
        ),
        ChangeNotifierProvider<KeyValues>(
          create: (context) => KeyValues(initialKeyValueStorage),
        ),
      ],
      builder: (context, _) => MaterialApp.router(
        locale: const Locale('de'),
        debugShowCheckedModeBanner: false,
        title: appTitle,
        themeMode: parseThemeMode(
                context.watch<KeyValues>().get<String>('themeMode')) ??
            ThemeMode.system,
        theme: theme(brightness: Brightness.light),
        darkTheme: theme(brightness: Brightness.dark),
        routerConfig: router,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: [
          const Locale('de', 'CH'), // English
          // Add other locales here if needed
        ],
      ),
    );
  }

  ThemeData theme({required Brightness brightness}) {
    return ThemeData(
      colorScheme:
          ColorScheme.fromSeed(seedColor: primaryColor, brightness: brightness),
      useMaterial3: true,
      brightness: brightness,
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
              backgroundColor: primaryColor, foregroundColor: Colors.white)),
    ).copyWith(
        appBarTheme: AppBarTheme(
            backgroundColor: appBarColor, foregroundColor: Colors.white));
  }
}
