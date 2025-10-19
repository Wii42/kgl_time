import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:kgl_time/app_route.dart';
import 'package:kgl_time/data_model/key_values.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/helpers.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import 'app_view.dart';
import 'data_model/work_categories.dart';
import 'data_model/work_entries.dart';
import 'data_model/work_entry.dart';

class KglTimeApp extends StatefulWidget {
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

  @override
  State<KglTimeApp> createState() => _KglTimeAppState();
}

class _KglTimeAppState extends State<KglTimeApp> {
  final GlobalKey<NavigatorState> routerKey =
      GlobalKey(debugLabel: "globalRouter");

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      navigatorKey: routerKey,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return AppView(navigationShell: navigationShell);
          },
          branches: [
            NavBarAppRoute.home.statefulShellBranch(appTitle: widget.appTitle),
            NavBarAppRoute.allEntries
                .statefulShellBranch(appTitle: widget.appTitle),
            NavBarAppRoute.categories
                .statefulShellBranch(appTitle: widget.appTitle),
          ],
        ),
        AppRoute.settings.goRoute(appTitle: widget.appTitle),
        AppRoute.newEntry.goRoute(appTitle: widget.appTitle),
        AppRoute.editCategories.goRoute(appTitle: widget.appTitle),
        AppRoute.entriesTrashBin.goRoute(appTitle: widget.appTitle),
      ],
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WorkEntries>(
          create: (context) => WorkEntries(widget.initialEntries),
        ),
        ChangeNotifierProvider<WorkCategories>(
          create: (context) => WorkCategories(widget.initialCategories),
        ),
        ChangeNotifierProvider<KeyValues>(
          create: (context) => KeyValues(widget.initialKeyValueStorage),
        ),
      ],
      builder: (context, _) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: widget.appTitle,
        themeMode: parseThemeMode(
                context.watch<KeyValues>().get<String>('themeMode')) ??
            ThemeMode.system,
        theme: theme(brightness: Brightness.light),
        darkTheme: theme(brightness: Brightness.dark),
        routerConfig: router,
        localizationsDelegates: [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        //locale: kDebugMode ? Locale('de', 'CH') : null,
        supportedLocales: [
          Locale('en'),
          Locale('de'),
          Locale('de', 'CH'),
          Locale('de', 'AT'),
        ],
      ),
    );
  }

  ThemeData theme({required Brightness brightness}) {
    ThemeData theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: KglTimeApp.primaryColor, brightness: brightness),
      useMaterial3: true,
      brightness: brightness,
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
              backgroundColor: KglTimeApp.primaryColor,
              foregroundColor: Colors.white)),
    ).copyWith(
      appBarTheme: AppBarTheme(
          backgroundColor: KglTimeApp.appBarColor,
          foregroundColor: Colors.white),
    );
    return theme;
  }
}
