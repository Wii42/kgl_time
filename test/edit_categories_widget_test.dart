import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/data_model/work_categories.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/data_model/work_entries.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';
import 'package:kgl_time/widgets/categories/edit_categories_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'support/memory_storage.dart';

void main() {
  late MemoryStorage storage;
  late WorkCategories categories;

  setUp(() async {
    storage = MemoryStorage();
    PersistentStorageService.setImplementation(storage);
    final entries = List.generate(
      4,
      (i) => WorkCategory('Category ${i + 1}', listIndex: i)..id = i + 1,
    );
    await storage.workCategories.saveEntries(entries);
    categories = WorkCategories(entries);
  });

  tearDown(() async {
    categories.dispose();
    await storage.close();
  });

  Future<void> launch(WidgetTester tester, {WorkEntries? workEntries}) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<WorkCategories>.value(value: categories),
          if (workEntries != null) ChangeNotifierProvider<WorkEntries>.value(value: workEntries),
        ],
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.linux),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: EditCategoriesWidget()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> drag(WidgetTester tester, int id, int targetId) async {
    final target = find.widgetWithText(ListTile, 'Category $targetId');
    // Flutter places the default handle beside the ListTile in a Stack.
    final handle = find
        .byIcon(Icons.drag_handle)
        .at(
          categories.entries.indexWhere((entry) => entry.id == id),
        );
    final start = tester.getCenter(handle);
    final targetRect = tester.getRect(target);
    // Cross the target's midpoint rather than stopping on the drop threshold.
    final end = Offset(
      start.dx,
      id == targetId
          ? start.dy
          : targetRect.center.dy > start.dy
          ? targetRect.bottom - 4
          : targetRect.top + 4,
    );
    final gesture = await tester.startGesture(start);
    await tester.pump(const Duration(milliseconds: 100));
    // Move through the intervening rows so gap animations track a real drag.
    for (var step = 1; step <= 12; step++) {
      await gesture.moveTo(Offset.lerp(start, end, step / 12)!);
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
    await gesture.up();
    await tester.pumpAndSettle();
  }

  Future<void> expectOrder(WidgetTester tester, List<int> ids) async {
    expect(categories.entries.map((e) => e.id), ids);
    expect(categories.entries.map((e) => e.listIndex), [0, 1, 2, 3]);
    final visualOrder = List.of(ids)
      ..sort(
        (a, b) => tester
            .getTopLeft(find.text('Category $a'))
            .dy
            .compareTo(
              tester.getTopLeft(find.text('Category $b')).dy,
            ),
      );
    expect(visualOrder, ids);
    final reloaded = WorkCategories(await storage.workCategories.loadEntries());
    addTearDown(reloaded.dispose);
    expect(reloaded.entries.map((e) => e.id), ids);
    expect(reloaded.entries.map((e) => e.listIndex), [0, 1, 2, 3]);
    expect(tester.takeException(), isNull);
  }

  for (final move in [
    (1, 4, [2, 3, 4, 1]),
    (4, 1, [4, 1, 2, 3]),
  ]) {
    testWidgets('drag category ${move.$1} to ${move.$2} preserves visible and stored order', (
      tester,
    ) async {
      await launch(tester);
      await drag(tester, move.$1, move.$2);
      await expectOrder(tester, move.$3);
    });
  }

  testWidgets('repeated drags use the current order after each rebuild', (tester) async {
    await launch(tester);
    await drag(tester, 1, 4);
    await expectOrder(tester, [2, 3, 4, 1]);
    await drag(tester, 1, 2);
    await expectOrder(tester, [1, 2, 3, 4]);
    await drag(tester, 2, 3);
    await expectOrder(tester, [1, 3, 2, 4]);
  });

  testWidgets('category actions validate, add, rename, and delete without losing entry data', (
    WidgetTester tester,
  ) async {
    final WorkEntry entry = WorkEntry.fromDuration(
      duration: const Duration(minutes: 45),
      date: DateTime(2026, 10, 23),
      description: 'Keep this work',
      categories: <EmbeddedWorkCategory>[categories.entries.first.toEmbedded()],
    )..id = 42;
    await storage.workEntries.saveEntries(<WorkEntry>[entry]);
    final WorkEntries workEntries = WorkEntries(<WorkEntry>[entry]);
    addTearDown(workEntries.dispose);
    await launch(tester, workEntries: workEntries);
    final AppLocalizations loc = AppLocalizations.of(
      tester.element(find.byType(EditCategoriesWidget)),
    )!;

    await tester.tap(find.widgetWithText(ElevatedButton, loc.addNewCategory));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, loc.add));
    await tester.pumpAndSettle();
    expect(find.text(loc.emptyCategoryNameError), findsOneWidget);
    expect(await storage.workCategories.loadEntries(), hasLength(4));
    await tester.enterText(find.byType(TextFormField), 'New category');
    await tester.tap(find.widgetWithText(ElevatedButton, loc.add));
    await tester.pumpAndSettle();
    expect(find.text('New category'), findsOneWidget);
    expect((await storage.workCategories.loadEntries()).last.listIndex, 4);

    final Finder originalRow = find.widgetWithText(ListTile, 'Category 1');
    await tester.tap(
      find.descendant(
        of: originalRow,
        matching: find.widgetWithIcon(IconButton, Icons.edit_outlined),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Renamed category');
    await tester.tap(find.widgetWithText(ElevatedButton, loc.save));
    await tester.pumpAndSettle();
    expect(find.text('Renamed category'), findsOneWidget);
    expect(
      (await storage.workCategories.loadEntries())
          .singleWhere((WorkCategory category) => category.id == 1)
          .displayName,
      'Renamed category',
    );
    final WorkEntry renamed = (await storage.workEntries.loadEntries()).single;
    expect(renamed.id, 42);
    expect(renamed.categories.single.id, 1);
    expect(renamed.categories.single.displayName, 'Renamed category');
    expect(renamed.description, 'Keep this work');
    expect(renamed.workDuration, const Duration(minutes: 45));

    final Finder delete = find.descendant(
      of: find.widgetWithText(ListTile, 'Renamed category'),
      matching: find.widgetWithIcon(IconButton, Icons.delete_outline_outlined),
    );
    await tester.tap(delete);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, loc.cancel));
    await tester.pumpAndSettle();
    expect(await storage.workCategories.loadEntries(), hasLength(5));
    await tester.tap(delete);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, loc.delete));
    await tester.pumpAndSettle();
    expect(find.text('Renamed category'), findsNothing);
    expect(await storage.workCategories.loadEntries(), hasLength(4));
    final WorkEntry afterDelete = (await storage.workEntries.loadEntries()).single;
    expect(afterDelete.id, 42);
    expect(afterDelete.categories.single.displayName, 'Renamed category');
    expect(afterDelete.workDuration, const Duration(minutes: 45));
    expect(tester.takeException(), isNull);
  });
}
