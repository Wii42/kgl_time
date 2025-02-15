import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/pages/all_entries_page.dart';
import 'package:kgl_time/pages/categories_page.dart';
import 'package:kgl_time/pages/home_page.dart';
import 'package:kgl_time/pages/new_entry_page.dart';
import 'package:kgl_time/pages/settings_page.dart';

import 'data_model/work_entry.dart';

class AppRoute {
  final String path;
  final Widget Function(BuildContext, GoRouterState, String appTitle) body;

  const AppRoute({required this.path, required this.body});

  GoRoute goRoute(
      {List<RouteBase> subRoutes = const [], required String appTitle}) {
    return GoRoute(
        path: path,
        builder: (context, state) => body(context, state, appTitle),
        routes: subRoutes);
  }

  static final AppRoute newEntry = AppRoute(
      path: '/newEntry',
      body: (context, state, appTitle) {
        WorkEntry? existingEntry;
        if (state.extra is WorkEntry) {
          existingEntry = state.extra as WorkEntry;
        }
        return NewEntryPage(appTitle: appTitle, existingEntry: existingEntry);
      });

  static final AppRoute settings = AppRoute(
      path: '/settings',
      body: (context, state, appTitle) => SettingsPage(appTitle: appTitle));

  static final List<AppRoute> routes = [
    newEntry,
    settings,
    ...NavBarAppRoute.navBarItems
  ];
}

class NavBarAppRoute extends AppRoute {
  final String Function(AppLocalizations?) title;
  final IconData icon;

  const NavBarAppRoute(
      {required super.path,
      required super.body,
      required this.title,
      required this.icon});

  NavigationDestination navigationDestination(AppLocalizations? loc) {
    return NavigationDestination(icon: Icon(icon), label: title(loc));
  }

  StatefulShellBranch statefulShellBranch(
          {List<RouteBase> subRoutes = const [], required String appTitle}) =>
      StatefulShellBranch(
          routes: [goRoute(subRoutes: subRoutes, appTitle: appTitle)]);

  static final NavBarAppRoute home = NavBarAppRoute(
      path: '/',
      body: (context, state, appTitle) => HomePage(appTitle: appTitle),
      title: (loc) => loc?.home ?? "<Home>",
      icon: Icons.home);

  static final allEntries = NavBarAppRoute(
      path: '/allEntries',
      body: (context, state, appTitle) => AllEntriesPage(appTitle: appTitle),
      title: (loc) => loc?.allEntries ?? "<allEntries>",
      icon: Icons.list);

  static final categories = NavBarAppRoute(
      path: '/categories',
      body: (context, state, appTitle) => CategoriesPage(appTitle: appTitle),
      title: (loc) => loc?.categories ?? "<categories>",
      icon: Icons.category);

  static final List<NavBarAppRoute> navBarItems = [
    home,
    allEntries,
    categories
  ];
}
