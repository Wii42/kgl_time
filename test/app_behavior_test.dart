import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kgl_time/app_route.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/kgl_time_app.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/pages/new_entry_page.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';
import 'package:kgl_time/select_category_dialog.dart';
import 'package:material_ui/material_ui.dart';

import 'support/memory_storage.dart';
import 'support/test_clock.dart';

void main() {
  late MemoryStorage storage;
  setUpAll(() => initializeDateFormatting('en'));
  setUp(() {
    storage = MemoryStorage();
    PersistentStorageService.setImplementation(storage);
  });

  Future<void> launch(
    WidgetTester tester, {
    Map<String, dynamic> initialSettings = const {},
    List<WorkCategory> categories = const [],
  }) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      KglTimeApp(
        appTitle: 'Test',
        initialKeyValueStorage: initialSettings,
        initialCategories: categories,
      ),
    );
    await tester.pumpAndSettle();
  }

  GoRouter router(WidgetTester tester) =>
      tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig! as GoRouter;

  Future<AppLocalizations> openForm(WidgetTester tester) async {
    await launch(tester);
    router(tester).push(AppRoute.newEntry.path);
    await tester.pumpAndSettle();
    return AppLocalizations.of(tester.element(find.byType(NewEntryPage)))!;
  }

  void fillDuration(WidgetTester tester, String hours, String minutes) {
    final fields = tester.widgetList<TextFormField>(find.byType(TextFormField)).toList();
    // Set controllers directly so validator tests can also exercise values
    // normally blocked by the digits-only keyboard formatter.
    fields[0].controller!.text = hours;
    fields[1].controller!.text = minutes;
  }

  testWidgetsWithAdvancingClock('empty minutes prevent submission', (tester) async {
    final loc = await openForm(tester);
    await tester.tap(find.text(loc.save));
    await tester.pumpAndSettle();
    expect(find.text(loc.noInputError), findsOneWidget);
    expect(await storage.workEntries.loadEntries(), isEmpty);
    expect(find.byType(NewEntryPage), findsOneWidget);
  });

  for (final values in [('', '45'), ('1', '30'), ('0', '0')]) {
    testWidgetsWithAdvancingClock('saves ${values.$1} hours and ${values.$2} minutes once', (
      tester,
    ) async {
      final beforeOpen = clock.now();
      final loc = await openForm(tester);
      fillDuration(tester, values.$1, values.$2);
      await tester.enterText(find.byType(TextFormField).at(2), 'Preparation');
      final beforeSave = clock.now();
      await tester.tap(find.text(loc.save));
      await tester.pumpAndSettle();
      final afterSave = clock.now();
      final entries = await storage.workEntries.loadEntries();
      expect(entries, hasLength(1));
      expect(
        entries.single.workDuration,
        Duration(
          hours: int.tryParse(values.$1) ?? 0,
          minutes: int.parse(values.$2),
        ),
      );
      expect(
        entries.single.date,
        timeBetween(beforeOpen, beforeSave),
      );
      expect(
        entries.single.lastEdit,
        timeBetween(beforeSave, afterSave),
      );
      expect(entries.single.description, 'Preparation');
      expect(entries.single.createType, CreateWorkEntryType.manualDuration);
      expect(find.byType(NewEntryPage), findsNothing);
    });
  }

  for (final values in [
    ('-1', '30'),
    ('0', '-1'),
    ('999999999999999999999999999999', '0'),
    ('0', '999999999999999999999999999999'),
    ('0', '4294967297'),
    ('0', '71582789'),
    ('1193047', '0'),
    ('1193046', '29'),
  ]) {
    testWidgetsWithAdvancingClock('rejects invalid duration $values without saving', (
      tester,
    ) async {
      final loc = await openForm(tester);
      fillDuration(tester, values.$1, values.$2);
      await tester.tap(find.text(loc.save));
      await tester.pumpAndSettle();
      expect(await storage.workEntries.loadEntries(), isEmpty);
      expect(find.byType(NewEntryPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final values in [
    ('invalid', '30', 'parse', null),
    ('1', 'invalid', null, 'parse'),
    ('-1', '30', 'invalid', null),
    ('1', '-1', null, 'invalid'),
    ('4294967297', '30', 'large', 'sum'),
    ('1', '4294967297', 'sum', 'large'),
    ('1193047', '30', 'large', 'sum'),
    ('1', '71582789', 'sum', 'large'),
    ('1193046', '29', 'sum', 'sum'),
  ]) {
    testWidgetsWithAdvancingClock('duration errors belong to the correct field for $values', (
      tester,
    ) async {
      final loc = await openForm(tester);
      fillDuration(tester, values.$1, values.$2);
      tester.state<FormState>(find.byType(Form)).validate();
      await tester.pump();
      final messages = {
        'parse': loc.inputTooLargeOrNanException,
        'invalid': loc.inputInvalidException,
        'large': loc.inputTooLargeException,
        'sum': loc.inputSumTooLargeException,
      };
      expect(
        tester.state<FormFieldState<String>>(find.byType(TextFormField).at(0)).errorText,
        messages[values.$3],
      );
      expect(
        tester.state<FormFieldState<String>>(find.byType(TextFormField).at(1)).errorText,
        messages[values.$4],
      );
    });
  }

  testWidgetsWithAdvancingClock('accepts the largest whole-minute duration below the limit', (
    tester,
  ) async {
    await openForm(tester);
    fillDuration(tester, '1193046', '28');
    expect(tester.state<FormState>(find.byType(Form)).validate(), isTrue);
    await tester.pump();
  });

  testWidgetsWithAdvancingClock('router and unsaved form survive root rebuild and reassembly', (
    tester,
  ) async {
    await openForm(tester);
    final originalRouter = router(tester);
    await tester.enterText(find.byType(TextFormField).at(2), 'Unsaved draft');
    await tester.pumpWidget(const KglTimeApp(appTitle: 'Updated title'));
    await tester.pumpAndSettle();
    final reassembly = tester.binding.reassembleApplication();
    await tester.pump();
    await reassembly;
    expect(router(tester), same(originalRouter));
    expect(find.byType(NewEntryPage), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField).at(2)).controller!.text,
      'Unsaved draft',
    );
    expect(await storage.workEntries.loadEntries(), isEmpty);
  });

  testWidgetsWithAdvancingClock('starting tracker persists its start without creating an entry', (
    tester,
  ) async {
    await launch(tester);
    final beforeStart = clock.now();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    final start = await storage.keyValueStorage.get<DateTime>(
      'timeTrackerStart',
    );
    expect(start, timeBetween(beforeStart, clock.now()));
    expect(await storage.workEntries.loadEntries(), isEmpty);
    expect(find.text('Stop'), findsOneWidget);
  });

  testWidgetsWithAdvancingClock('tracker resumes from stored settings and stops exactly once', (
    tester,
  ) async {
    final start = clock.now().subtract(const Duration(minutes: 95));
    final category = WorkCategory('Office', listIndex: 0, uuid: '', lastEdit: null)..id = 7;
    await storage.keyValueStorage.set('timeTrackerStart', start);
    await storage.keyValueStorage.set(SelectCategoryDialog.storageKey, '7');
    final savedSettings = await storage.keyValueStorage.getAll<dynamic>();
    // Recreate all app state from persisted settings, as at startup.
    await launch(
      tester,
      initialSettings: savedSettings,
      categories: [category],
    );
    expect(find.text('Stop'), findsOneWidget);
    final beforeStop = clock.now();
    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle();
    final afterStop = clock.now();
    final entries = await storage.workEntries.loadEntries();
    expect(entries, hasLength(1));
    final entry = entries.single;
    expect(entry.startTime, start);
    expect(
      entry.workDuration.inSeconds,
      entry.endTime!.difference(start).inSeconds,
    );
    expect(entry.endTime, timeBetween(beforeStop, afterStop));
    expect(
      entry.lastEdit,
      timeBetween(entry.endTime!, afterStop),
    );
    expect(
      entry.workDuration.inSeconds,
      inInclusiveRange(
        beforeStop.difference(start).inSeconds,
        afterStop.difference(start).inSeconds,
      ),
    );
    expect(entry.categories.single.id, category.id);
    expect(entry.createType, CreateWorkEntryType.timeTracker);
    expect(
      await storage.keyValueStorage.get<DateTime>('timeTrackerStart'),
      isNull,
    );
    expect(
      await storage.keyValueStorage.get<String>(
        SelectCategoryDialog.storageKey,
      ),
      isNull,
    );
    expect(find.text('Start'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(await storage.workEntries.loadEntries(), hasLength(1));
  });
}
