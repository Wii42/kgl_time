import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kgl_time/app/app_route.dart';
import 'package:kgl_time/app/kgl_time_app.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/pages/new_entry_page.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';
import 'package:kgl_time/widgets/work_entries/trashed_work_entry.dart';
import 'package:kgl_time/widgets/work_entries/work_entry_details.dart';
import 'package:material_ui/material_ui.dart';

import 'support/memory_storage.dart';

void main() {
  setUpAll(() => initializeDateFormatting('en'));

  testWidgets('entry buttons edit, cancel deletion, move to trash, and restore the same record', (
    WidgetTester tester,
  ) async {
    final MemoryStorage storage = MemoryStorage();
    PersistentStorageService.setImplementation(storage);
    addTearDown(storage.close);
    tester.platformDispatcher.localesTestValue = <Locale>[const Locale('en')];
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final WorkCategory category = WorkCategory('Planning', listIndex: 0)..id = 7;
    final WorkEntry entry = WorkEntry.fromDuration(
      date: DateTime(2026, 10, 23),
      duration: const Duration(minutes: 30),
      description: 'Before editing',
      categories: <EmbeddedWorkCategory>[category.toEmbedded()],
    )..id = 42;
    await storage.workEntries.saveEntries(<WorkEntry>[entry]);
    await storage.workCategories.saveEntries(<WorkCategory>[category]);
    await tester.pumpWidget(
      KglTimeApp(
        appTitle: 'Test',
        initialEntries: <WorkEntry>[entry],
        initialCategories: <WorkCategory>[category],
      ),
    );
    await tester.pumpAndSettle();
    final GoRouter router =
        tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig! as GoRouter;
    router.go(NavBarAppRoute.allEntries.path);
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(WorkEntryDetails),
        matching: find.widgetWithIcon(IconButton, Icons.edit_outlined),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(NewEntryPage), findsOneWidget);
    final AppLocalizations loc = AppLocalizations.of(tester.element(find.byType(NewEntryPage)))!;
    await tester.enterText(find.byType(TextFormField).at(1), '45');
    await tester.enterText(find.byType(TextFormField).at(2), 'After editing');
    await tester.tap(find.widgetWithText(FilledButton, loc.save));
    await tester.pumpAndSettle();
    final WorkEntry edited = (await storage.workEntries.loadEntries()).single;
    expect(edited.id, 42);
    expect(edited.workDuration, const Duration(minutes: 45));
    expect(edited.description, 'After editing');
    expect(edited.categories.single.id, 7);
    expect(find.text('Description: After editing'), findsOneWidget);

    final Finder delete = find.descendant(
      of: find.byType(WorkEntryDetails),
      matching: find.widgetWithIcon(IconButton, Icons.delete_outline_outlined),
    );
    await tester.tap(delete);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, loc.cancel));
    await tester.pumpAndSettle();
    expect((await storage.workEntries.loadEntries()).single.isInTrash, isFalse);
    expect(find.byType(WorkEntryDetails), findsOneWidget);
    await tester.tap(delete);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, loc.delete));
    await tester.pumpAndSettle();
    expect(find.byType(WorkEntryDetails), findsNothing);
    expect((await storage.workEntries.loadEntries()).single.isInTrash, isTrue);

    router.push<void>(AppRoute.entriesTrashBin.path);
    await tester.pumpAndSettle();
    final Finder restore = find.descendant(
      of: find.byType(TrashedWorkEntry),
      matching: find.widgetWithText(TextButton, loc.restoreEntry),
    );
    await tester.tap(restore);
    await tester.pumpAndSettle();
    expect(find.text(loc.trashBinEmpty), findsOneWidget);
    final WorkEntry restored = (await storage.workEntries.loadEntries()).single;
    expect(restored.id, edited.id);
    expect(restored.isInTrash, isFalse);
    expect(restored.workDuration, edited.workDuration);
    expect(restored.description, edited.description);
    expect(restored.categories.single.id, 7);
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('Description: After editing'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
