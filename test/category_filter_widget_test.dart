import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kgl_time/category_filter_widget.dart';
import 'package:kgl_time/data_model/work_categories.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/data_model/work_entries.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';
import 'package:kgl_time/work_entry_widgets/work_entry_details.dart';
import 'package:provider/provider.dart';

import 'support/memory_storage.dart';

void main() {
  late MemoryStorage storage;
  late WorkCategory categoryA;
  late WorkCategory categoryB;
  late WorkCategories categories;
  late WorkEntries entries;

  setUpAll(() => initializeDateFormatting('en'));

  setUp(() {
    storage = MemoryStorage();
    PersistentStorageService.setImplementation(storage);
    categoryA = WorkCategory('Category A', listIndex: 0)..id = 1;
    categoryB = WorkCategory('Category B', listIndex: 1)..id = 2;
    categories = WorkCategories([categoryA, categoryB]);
    entries = WorkEntries([
      WorkEntry.fromDuration(
        duration: const Duration(minutes: 10),
        date: DateTime(2026, 10, 23),
        description: 'Only A',
        categories: [categoryA.toEmbedded()],
      )..id = 1,
      WorkEntry.fromDuration(
        duration: const Duration(minutes: 20),
        date: DateTime(2026, 10, 22),
        description: 'Only B',
        categories: [categoryB.toEmbedded()],
      )..id = 2,
      WorkEntry.fromDuration(
        duration: const Duration(minutes: 30),
        date: DateTime(2026, 10, 21),
        description: 'Both A and B',
        categories: [categoryA.toEmbedded(), categoryB.toEmbedded()],
      )..id = 3,
      WorkEntry.fromDuration(
        duration: const Duration(minutes: 40),
        date: DateTime(2026, 10, 20),
        description: 'Neither A nor B',
      )..id = 4,
    ]);
  });

  tearDown(() async {
    categories.dispose();
    entries.dispose();
    await storage.close();
  });

  Future<void> launch(WidgetTester tester) async {
    // Keep every fixture row in the viewport so absence cannot be caused by
    // lazy list rendering rather than filtering.
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<WorkCategories>.value(value: categories),
          ChangeNotifierProvider<WorkEntries>.value(value: entries),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            // Match CategoriesPage: category notifications rebuild the filter
            // configuration while preserving its State and user selections.
            body: Consumer<WorkCategories>(
              builder: (BuildContext context, WorkCategories model, Widget? _) =>
                  CategoryFilterWidget(categories: model),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder chip(String label) => find.widgetWithText(ChoiceChip, label);

  void expectSelected(WidgetTester tester, String label, bool selected) {
    expect(tester.widget<ChoiceChip>(chip(label)).selected, selected);
  }

  Future<void> toggle(WidgetTester tester, String label) async {
    await tester.tap(chip(label));
    // Removed rows remain mounted during the list's exit animation.
    await tester.pumpAndSettle();
  }

  void expectVisible(WidgetTester tester, Set<int> expectedIds) {
    final Iterable<WorkEntryDetails> rows = tester.widgetList<WorkEntryDetails>(
      find.byType(WorkEntryDetails),
    );
    expect(
      rows.map((WorkEntryDetails row) => row.workEntry.id),
      unorderedEquals(expectedIds),
    );
    for (final WorkEntry entry in entries.entries) {
      expect(
        find.text('Description: ${entry.description}'),
        expectedIds.contains(entry.id) ? findsOneWidget : findsNothing,
      );
    }
    expect(
      find.text('No matching entries found'),
      expectedIds.isEmpty ? findsOneWidget : findsNothing,
    );
    // An uncategorized entry never matches the selected-category filter,
    // including when every category or no category is selected.
    expect(find.text('Description: Neither A nor B'), findsNothing);
  }

  for (final (bool a, bool b, Set<int> visible) in [
    (true, true, {1, 2, 3}),
    (true, false, {1, 3}),
    (false, true, {2, 3}),
    (false, false, <int>{}),
  ]) {
    testWidgets('selected A=$a, B=$b updates chips and matching rows', (
      WidgetTester tester,
    ) async {
      await launch(tester);
      expectSelected(tester, 'Category A', true);
      expectSelected(tester, 'Category B', true);
      expectVisible(tester, {1, 2, 3});
      if (!a) await toggle(tester, 'Category A');
      if (!b) await toggle(tester, 'Category B');
      expectSelected(tester, 'Category A', a);
      expectSelected(tester, 'Category B', b);
      expectVisible(tester, visible);
    });
  }

  testWidgets(
    'reenabling categories restores rows without duplicating matches',
    (WidgetTester tester) async {
      await launch(tester);
      await toggle(tester, 'Category A');
      await toggle(tester, 'Category B');
      expectVisible(tester, {});

      await toggle(tester, 'Category A');
      expectSelected(tester, 'Category A', true);
      expectSelected(tester, 'Category B', false);
      expectVisible(tester, {1, 3});

      await toggle(tester, 'Category B');
      expectSelected(tester, 'Category A', true);
      expectSelected(tester, 'Category B', true);
      expectVisible(tester, {1, 2, 3});
    },
  );

  testWidgets(
    'new category is selected without resetting existing selections',
    (WidgetTester tester) async {
      await launch(tester);
      await toggle(tester, 'Category A');
      final WorkCategory categoryC = WorkCategory('Category C', listIndex: 2)..id = 3;
      entries.add(
        WorkEntry.fromDuration(
          duration: const Duration(minutes: 15),
          date: DateTime(2026, 10, 24),
          description: 'Only C',
          categories: [categoryC.toEmbedded()],
        )..id = 5,
      );
      categories.add(categoryC);
      await tester.pumpAndSettle();

      expectSelected(tester, 'Category A', false);
      expectSelected(tester, 'Category B', true);
      expectSelected(tester, 'Category C', true);
      expectVisible(tester, {2, 3, 5});
      await toggle(tester, 'Category C');
      expectVisible(tester, {2, 3});
    },
  );

  testWidgets('renaming a disabled category preserves its selection by ID', (
    WidgetTester tester,
  ) async {
    await launch(tester);
    await toggle(tester, 'Category A');
    categories.updateEntry(
      categoryA,
      WorkCategory('Renamed A', listIndex: 0)..id = categoryA.id,
    );
    await tester.pumpAndSettle();

    expect(chip('Category A'), findsNothing);
    expectSelected(tester, 'Renamed A', false);
    expectSelected(tester, 'Category B', true);
    expectVisible(tester, {2, 3});
    await toggle(tester, 'Renamed A');
    expectVisible(tester, {1, 2, 3});
  });

  testWidgets('removing a selected category preserves other deselections', (
    WidgetTester tester,
  ) async {
    await launch(tester);
    await toggle(tester, 'Category A');
    categories.remove(categoryB);
    await tester.pumpAndSettle();

    expect(chip('Category B'), findsNothing);
    expectSelected(tester, 'Category A', false);
    expectVisible(tester, {});
    await toggle(tester, 'Category A');
    expectVisible(tester, {1, 3});
  });

  for (final (int from, int to) in [(0, 1), (1, 0)]) {
    testWidgets(
      'reordering categories from $from to $to preserves selections',
      (WidgetTester tester) async {
        await launch(tester);
        await toggle(tester, 'Category A');

        categories.reorder(from, to);
        await tester.pumpAndSettle();

        final List<ChoiceChip> chips = tester
            .widgetList<ChoiceChip>(find.byType(ChoiceChip))
            .toList();
        expect(chips.map((ChoiceChip chip) => (chip.label as Text).data), [
          'Category B',
          'Category A',
        ]);
        expect(
          tester.getTopLeft(chip('Category B')).dx,
          lessThan(tester.getTopLeft(chip('Category A')).dx),
        );
        expectSelected(tester, 'Category A', false);
        expectSelected(tester, 'Category B', true);
        expectVisible(tester, {2, 3});

        // The reordered chips must still change the selection for the right ID.
        await toggle(tester, 'Category A');
        expectVisible(tester, {1, 2, 3});
        await toggle(tester, 'Category B');
        expectSelected(tester, 'Category A', true);
        expectSelected(tester, 'Category B', false);
        expectVisible(tester, {1, 3});
      },
    );
  }

  testWidgets(
    'editing entry categories removes and restores the matching row',
    (WidgetTester tester) async {
      await launch(tester);
      await toggle(tester, 'Category B');
      final WorkEntry original = entries.entries.singleWhere(
        (WorkEntry entry) => entry.id == 1,
      );
      final WorkEntry reassigned = WorkEntry.fromDuration(
        duration: original.workDuration,
        date: original.date,
        description: 'Reassigned to B',
        categories: [categoryB.toEmbedded()],
      )..id = original.id;

      entries.updateEntry(original, reassigned);
      await tester.pumpAndSettle();
      expectSelected(tester, 'Category A', true);
      expectSelected(tester, 'Category B', false);
      expectVisible(tester, {3});
      expect(find.text('Description: Only A'), findsNothing);

      entries.updateEntry(reassigned, original);
      await tester.pumpAndSettle();
      expectVisible(tester, {1, 3});
      expect(find.text('Description: Reassigned to B'), findsNothing);
      expectSelected(tester, 'Category A', true);
      expectSelected(tester, 'Category B', false);
    },
  );

  testWidgets(
    'new entries follow the active filter without resetting selections',
    (WidgetTester tester) async {
      await launch(tester);
      await toggle(tester, 'Category B');

      entries.add(
        WorkEntry.fromDuration(
          duration: const Duration(minutes: 5),
          date: DateTime(2026, 10, 24),
          description: 'New B',
          categories: [categoryB.toEmbedded()],
        )..id = 5,
      );
      await tester.pumpAndSettle();
      expectVisible(tester, {1, 3});

      entries.add(
        WorkEntry.fromDuration(
          duration: const Duration(minutes: 5),
          date: DateTime(2026, 10, 25),
          description: 'New A',
          categories: [categoryA.toEmbedded()],
        )..id = 6,
      );
      await tester.pumpAndSettle();
      expectVisible(tester, {1, 3, 6});

      entries.add(
        WorkEntry.fromDuration(
          duration: const Duration(minutes: 5),
          date: DateTime(2026, 10, 26),
          description: 'New uncategorized',
        )..id = 7,
      );
      await tester.pumpAndSettle();
      expectVisible(tester, {1, 3, 6});
      expectSelected(tester, 'Category A', true);
      expectSelected(tester, 'Category B', false);
    },
  );

  testWidgets(
    'trashing and restoring entries updates the list and empty state',
    (WidgetTester tester) async {
      await launch(tester);
      await toggle(tester, 'Category B');
      final WorkEntry onlyA = entries.entries.singleWhere(
        (WorkEntry entry) => entry.id == 1,
      );
      final WorkEntry both = entries.entries.singleWhere(
        (WorkEntry entry) => entry.id == 3,
      );

      entries.moveToTrashBin(onlyA);
      await tester.pumpAndSettle();
      expectVisible(tester, {3});
      expect(find.text('Description: Only A'), findsNothing);

      entries.moveToTrashBin(both);
      await tester.pumpAndSettle();
      expectVisible(tester, {});
      expectSelected(tester, 'Category A', true);
      expectSelected(tester, 'Category B', false);

      entries.restoreFromTrashBin(
        entries.entriesInTrash.singleWhere(
          (WorkEntry entry) => entry.id == onlyA.id,
        ),
      );
      await tester.pumpAndSettle();
      expectVisible(tester, {1});
      expectSelected(tester, 'Category A', true);
      expectSelected(tester, 'Category B', false);
    },
  );

  testWidgets(
    'editing an entry date updates row order while keeping the filter',
    (WidgetTester tester) async {
      await launch(tester);
      await toggle(tester, 'Category B');
      final WorkEntry original = entries.entries.singleWhere(
        (WorkEntry entry) => entry.id == 3,
      );
      entries.updateEntry(
        original,
        WorkEntry.fromDuration(
          duration: original.workDuration,
          date: DateTime(2026, 10, 24),
          description: original.description,
          categories: original.categories,
        )..id = original.id,
      );
      await tester.pumpAndSettle();

      expectVisible(tester, {1, 3});
      expect(
        tester
            .widgetList<WorkEntryDetails>(find.byType(WorkEntryDetails))
            .map((WorkEntryDetails row) => row.workEntry.id),
        [3, 1],
      );
      expect(
        tester.getTopLeft(find.byKey(const ValueKey<int>(3))).dy,
        lessThan(tester.getTopLeft(find.byKey(const ValueKey<int>(1))).dy),
      );
      expectSelected(tester, 'Category A', true);
      expectSelected(tester, 'Category B', false);
    },
  );
}
