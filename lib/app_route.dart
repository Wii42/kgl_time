import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/pages/all_entries_page.dart';
import 'package:kgl_time/pages/categories_page.dart';
import 'package:kgl_time/pages/edit_categories_page.dart';
import 'package:kgl_time/pages/entries_trash_bin_page.dart';
import 'package:kgl_time/pages/home_page.dart';
import 'package:kgl_time/pages/new_entry_page.dart';
import 'package:kgl_time/pages/settings_page.dart';

import 'data_model/work_entry.dart';

class AppRoute {
  final String path;
  final String name;
  final Widget Function(BuildContext, GoRouterState, String appTitle) body;

  const AppRoute({required this.path, required this.body, required this.name});

  GoRoute goRoute(
      {List<RouteBase> subRoutes = const [], required String appTitle}) {
    return GoRoute(
        path: path,
        builder: (context, state) => body(context, state, appTitle),
        routes: subRoutes);
  }

  static final AppRoute newEntry = AppRoute(
      name: 'newEntry',
      path: '/newEntry',
      body: (context, state, appTitle) {
        WorkEntry? existingEntry;
        if (state.extra is WorkEntry) {
          existingEntry = state.extra as WorkEntry;
        }
        return NewEntryPage(appTitle: appTitle, existingEntry: existingEntry);
      });

  static final AppRoute settings = AppRoute(
      name: 'settings',
      path: '/settings',
      body: (context, state, appTitle) => SettingsPage(appTitle: appTitle));

  static final List<AppRoute> routes = [
    newEntry,
    settings,
    ...NavBarAppRoute.navBarItems
  ];

  static final AppRoute editCategories = AppRoute(
      name: 'editCategories',
      path: '/editCategories',
      body: (context, state, appTitle) =>
          EditCategoriesPage(appTitle: appTitle));

  static final AppRoute entriesTrashBin = AppRoute(
      name: 'entriesTrashBin',
      path: '/entriesTrashBin',
      body: (context, state, appTitle) =>
          EntriesTrashBinPage(appTitle: appTitle));
}

class NavBarAppRoute extends AppRoute {
  final String Function(AppLocalizations?) title;
  final IconData icon;

  const NavBarAppRoute(
      {required super.path,
      required super.body,
      required super.name,
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
      name: 'home',
      path: '/',
      body: (context, state, appTitle) => HomePage(appTitle: appTitle),
      title: (loc) => loc?.home ?? "<Home>",
      icon: Icons.home);

  static final allEntries = NavBarAppRoute(
      name: 'allEntries',
      path: '/allEntries',
      body: (context, state, appTitle) => AllEntriesPage(appTitle: appTitle),
      title: (loc) => loc?.allEntries ?? "<allEntries>",
      icon: Icons.list);

  static final categories = NavBarAppRoute(
      name: 'categories',
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
