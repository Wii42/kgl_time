import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kgl_time/animated_branch_container.dart';
import 'package:kgl_time/app_route.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/kgl_time_app.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';
import 'package:kgl_time/width_constrained_list_view.dart';
import 'package:material_navigation/material_navigation.dart' as navigation;
import 'package:material_ui/material_ui.dart';

import 'support/memory_storage.dart';

Future<GoRouter> pumpApp(WidgetTester tester) async {
  final MemoryStorage storage = MemoryStorage();
  PersistentStorageService.setImplementation(storage);
  addTearDown(storage.close);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    KglTimeApp(
      appTitle: 'Test',
      initialEntries: [
        for (int index = 0; index < 40; index++)
          WorkEntry.fromDuration(
            duration: const Duration(minutes: 30),
            date: DateTime(2026, 10, 30 - index),
            description: 'Entry $index',
          )..id = index + 1,
      ],
    ),
  );
  await tester.pumpAndSettle();
  return tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig! as GoRouter;
}

void main() {
  setUpAll(() => initializeDateFormatting('en'));

  for (final bool useSwipe in <bool>[false, true]) {
    testWidgets('returning to a tab reveals its app bar (swipe: $useSwipe)', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpApp(tester);
      tester.view.physicalSize = const Size(390, 700);
      router.go(NavBarAppRoute.allEntries.path);
      await tester.pumpAndSettle();
      final Finder list = find.byType(AnimatedWidthConstrainedListView);
      final ScrollPosition position = tester
          .state<ScrollableState>(
            find.descendant(of: list, matching: find.byType(Scrollable)),
          )
          .position;
      final ScrollPosition header = tester
          .widget<NestedScrollView>(
            find.byType(NestedScrollView),
          )
          .controller!
          .position;
      await tester.drag(list, const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(header.pixels, greaterThan(header.minScrollExtent));
      final double offset = position.pixels;
      expect(offset, greaterThan(100));

      if (useSwipe) {
        await tester.drag(list, const Offset(-250, 0));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(AnimatedBranchContainer), const Offset(250, 0));
      } else {
        await tester.tap(
          find.descendant(
            of: find.byType(navigation.NavigationBar),
            matching: find.text('Categories'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(navigation.NavigationBar),
            matching: find.text('All Entries'),
          ),
        );
      }
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, NavBarAppRoute.allEntries.path);
      expect(header.pixels, header.minScrollExtent);
      expect(
        find
            .descendant(
              of: find.byType(SliverAppBar),
              matching: find.byIcon(Icons.settings),
            )
            .hitTestable(),
        findsOneWidget,
      );
      expect(position.pixels, closeTo(offset, 0.01));

      // Revealing the bar does not pin it; subsequent scrolling can hide it again.
      await tester.drag(list, const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(header.pixels, greaterThan(header.minScrollExtent));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('back navigation reveals the app bar without resetting content', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await pumpApp(tester);
    tester.view.physicalSize = const Size(390, 700);
    router.go(NavBarAppRoute.allEntries.path);
    await tester.pumpAndSettle();
    final Finder list = find.byType(AnimatedWidthConstrainedListView);
    final ScrollPosition position = tester
        .state<ScrollableState>(
          find.descendant(of: list, matching: find.byType(Scrollable)),
        )
        .position;
    final ScrollPosition header = tester
        .widget<NestedScrollView>(
          find.byType(NestedScrollView),
        )
        .controller!
        .position;
    await tester.drag(list, const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(header.pixels, greaterThan(header.minScrollExtent));
    final double offset = position.pixels;

    router.push<void>(AppRoute.exportImport.path);
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();
    expect(header.pixels, header.minScrollExtent);
    expect(
      find
          .descendant(
            of: find.byType(SliverAppBar),
            matching: find.byIcon(Icons.settings),
          )
          .hitTestable(),
      findsOneWidget,
    );
    expect(position.pixels, closeTo(offset, 0.01));
    expect(tester.takeException(), isNull);
  });

  for (final (Offset delta, bool switchesTab) in <(Offset, bool)>[
    (const Offset(-240, -80), true), // 18.4 degrees: within the allowed angle.
    (const Offset(-240, -96), false), // 21.8 degrees: scroll instead.
    (const Offset(240, -96), false),
    (const Offset(-150, -240), false),
  ]) {
    testWidgets('drag $delta switches tabs: $switchesTab', (WidgetTester tester) async {
      final GoRouter router = await pumpApp(tester);
      router.go(NavBarAppRoute.allEntries.path);
      await tester.pumpAndSettle();
      final Finder list = find.byType(AnimatedWidthConstrainedListView);
      final ScrollPosition position = tester
          .state<ScrollableState>(
            find.descendant(of: list, matching: find.byType(Scrollable)),
          )
          .position;

      // Small increments establish the actual angle before either recognizer wins.
      await tester.timedDrag(list, delta, const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        switchesTab ? NavBarAppRoute.categories.path : NavBarAppRoute.allEntries.path,
      );
      if (!switchesTab) expect(position.pixels, greaterThan(0));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('swipes switch adjacent tabs without wrapping or reacting to short drags', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await pumpApp(tester);
    final Finder body = find.byType(AnimatedBranchContainer);
    String currentPath() => router.routeInformationProvider.value.uri.path;

    await tester.drag(body, const Offset(250, 0));
    await tester.pumpAndSettle();
    expect(currentPath(), NavBarAppRoute.home.path);

    await tester.timedDrag(body, const Offset(-40, 0), const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(currentPath(), NavBarAppRoute.home.path);

    await tester.drag(body, const Offset(-250, 0));
    await tester.pumpAndSettle();
    expect(currentPath(), NavBarAppRoute.allEntries.path);
    await tester.drag(body, const Offset(-250, 0));
    await tester.pumpAndSettle();
    expect(currentPath(), NavBarAppRoute.categories.path);
    await tester.drag(body, const Offset(-250, 0));
    await tester.pumpAndSettle();
    expect(currentPath(), NavBarAppRoute.categories.path);

    await tester.drag(body, const Offset(250, 0));
    await tester.pumpAndSettle();
    expect(currentPath(), NavBarAppRoute.allEntries.path);
    await tester.drag(body, const Offset(250, 0));
    await tester.pumpAndSettle();
    expect(currentPath(), NavBarAppRoute.home.path);
    expect(tester.takeException(), isNull);
  });

  testWidgets('vertical scrolling stays within the tab and swiping preserves its scroll state', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await pumpApp(tester);
    router.go(NavBarAppRoute.allEntries.path);
    await tester.pumpAndSettle();
    final Finder list = find.byType(AnimatedWidthConstrainedListView);
    final ScrollPosition position = tester
        .state<ScrollableState>(
          find.descendant(of: list, matching: find.byType(Scrollable)),
        )
        .position;

    await tester.drag(list, const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, NavBarAppRoute.allEntries.path);
    expect(position.pixels, greaterThan(100));
    final double offset = position.pixels;

    await tester.drag(list, const Offset(-250, 0));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, NavBarAppRoute.categories.path);
    await tester.drag(find.byType(AnimatedBranchContainer), const Offset(250, 0));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, NavBarAppRoute.allEntries.path);
    expect(position.pixels, closeTo(offset, 0.01));
    expect(tester.takeException(), isNull);
  });
}
