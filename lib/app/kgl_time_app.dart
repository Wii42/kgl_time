import 'package:go_router/go_router.dart';
import 'package:kgl_time/app/app_route.dart';
import 'package:kgl_time/data_model/key_values.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/theme/color_theme_extension.dart';
import 'package:kgl_time/utils/helpers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../data_model/work_categories.dart';
import '../data_model/work_entries.dart';
import '../data_model/work_entry.dart';
import '../l10n/app_locales.dart';
import '../persistent_storage/persistent_storage_service.dart';
import '../whats_new/whats_new_controller.dart';
import '../whats_new/whats_new_gate.dart';
import 'animated_branch_container.dart';
import 'app_view.dart';

class KglTimeApp extends StatefulWidget {
  final String appTitle;

  /// Installed version loaded by initializeApp; omitted in isolated widget previews.
  final String? appVersion;

  final List<WorkEntry> initialEntries;
  final List<WorkCategory> initialCategories;
  final Map<String, dynamic> initialKeyValueStorage;

  const KglTimeApp({
    super.key,
    required this.appTitle,
    this.appVersion,
    this.initialEntries = const [],
    this.initialCategories = const [],
    this.initialKeyValueStorage = const {},
  });

  @override
  State<KglTimeApp> createState() => _KglTimeAppState();
}

class _KglTimeAppState extends State<KglTimeApp> {
  final GlobalKey<NavigatorState> routerKey = GlobalKey(debugLabel: "globalRouter");

  late final GoRouter router;
  late final WhatsNewController whatsNewController = WhatsNewController(
    storage: PersistentStorageService.instance.keyValueStorage,
    isFirstRun: widget.initialKeyValueStorage['isFirstRun'] as bool? ?? true,
  );

  @override
  void initState() {
    super.initState();
    router = GoRouter(
      navigatorKey: routerKey,
      routes: [
        StatefulShellRoute(
          builder: (context, state, navigationShell) {
            return AppView(navigationShell: navigationShell);
          },
          navigatorContainerBuilder: (context, navigationShell, children) {
            return AnimatedBranchContainer(
              currentIndex: navigationShell.currentIndex,
              children: children,
            );
          },
          branches: [
            NavBarAppRoute.home.statefulShellBranch(appTitle: widget.appTitle),
            NavBarAppRoute.allEntries.statefulShellBranch(appTitle: widget.appTitle),
            NavBarAppRoute.categories.statefulShellBranch(appTitle: widget.appTitle),
          ],
        ),
        AppRoute.settings.goRoute(appTitle: widget.appTitle),
        AppRoute.newEntry.goRoute(appTitle: widget.appTitle),
        AppRoute.editCategories.goRoute(appTitle: widget.appTitle),
        AppRoute.entriesTrashBin.goRoute(appTitle: widget.appTitle),
        AppRoute.exportImport.goRoute(appTitle: widget.appTitle),
      ],
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
        themeMode:
            parseThemeMode(context.watch<KeyValues>().get<String>('themeMode')) ?? ThemeMode.system,
        theme: theme(brightness: Brightness.light),
        darkTheme: theme(brightness: Brightness.dark),
        routerConfig: router,
        builder: (BuildContext context, Widget? child) => widget.appVersion == null
            ? child!
            : WhatsNewGate(
                controller: whatsNewController,
                currentVersion: widget.appVersion!,
                navigatorKey: routerKey,
                child: child!,
              ),
        localizationsDelegates: [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: supportedAppLocales,
      ),
    );
  }

  @override
  void dispose() {
    router.dispose();
    super.dispose();
  }

  ThemeData theme({required Brightness brightness}) {
    final Color primaryColor = Color(0xff0067b1);
    final Color actionColor = Color(0xffc62828);
    final Color appBarColor = Color(0xff4a8e3b);

    final FilledButtonThemeData filledButtonTheme = FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );

    final AppBarTheme appBarTheme = AppBarTheme(
      backgroundColor: appBarColor,
      foregroundColor: Colors.white,
    );

    ThemeData theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
      ),
      useMaterial3: true,
      brightness: brightness,
      filledButtonTheme: filledButtonTheme,
      appBarTheme: appBarTheme,
      extensions: [
        ColorThemeExtension(
          primaryColor: primaryColor,
          actionColor: actionColor,
        ),
      ],
    );
    return theme;
  }
}
