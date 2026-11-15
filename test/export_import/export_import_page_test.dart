import 'dart:async';
import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/data_model/key_values.dart';
import 'package:kgl_time/data_model/value.dart';
import 'package:kgl_time/data_model/work_categories.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/data_model/work_entries.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/export_import/export_entries_card.dart';
import 'package:kgl_time/export_import/import_replace_confirmation_dialog.dart';
import 'package:kgl_time/export_import/undo_import_confirmation_dialog.dart';
import 'package:kgl_time/export_import/work_data.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/pages/export_import_page.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../support/backup_fixture.dart';
import '../support/controlled_backup_storage.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_file_dialog');
  late ControlledBackupStorage storage;
  late WorkEntries entries;
  late WorkCategories categories;
  late KeyValues settings;
  final List<Map<Object?, Object?>> saves = <Map<Object?, Object?>>[];
  final DateTime trackerStart = DateTime.utc(2026, 11, 15, 8);
  const String importTrackerWarning =
      'Importing this backup will cancel the current time tracker without saving the tracked time.';
  const String undoTrackerWarning =
      'Undoing this import will cancel the current time tracker without saving the tracked time.';

  void startTracker() {
    settings.set<DateTime>(KeyValues.timeTrackerStartKey, trackerStart);
    settings.set<String>(KeyValues.timeTrackerCategoriesKey, '7');
  }

  Future<void> expectTrackerRunning() async {
    expect(settings.get<DateTime>(KeyValues.timeTrackerStartKey), trackerStart);
    expect(settings.get<String>(KeyValues.timeTrackerCategoriesKey), '7');
    expect(
      await storage.keyValueStorage.get<DateTime>(KeyValues.timeTrackerStartKey),
      trackerStart,
    );
    expect(await storage.keyValueStorage.get<String>(KeyValues.timeTrackerCategoriesKey), '7');
  }

  Future<void> expectTrackerStopped() async {
    expect(settings.get<DateTime>(KeyValues.timeTrackerStartKey), isNull);
    expect(settings.get<String>(KeyValues.timeTrackerCategoriesKey), isNull);
    expect(await storage.keyValueStorage.get<DateTime>(KeyValues.timeTrackerStartKey), isNull);
    expect(await storage.keyValueStorage.get<String>(KeyValues.timeTrackerCategoriesKey), isNull);
  }

  setUp(() async {
    storage = ControlledBackupStorage();
    PersistentStorageService.setImplementation(storage);
    final WorkData initial = WorkData.fromJson(backupFixture());
    await storage.workEntries.saveEntries(initial.workEntries);
    await storage.workCategories.saveEntries(initial.workCategories);
    entries = withClock(Clock.fixed(initial.exportedAt), () => WorkEntries(initial.workEntries));
    categories = WorkCategories(initial.workCategories);
    settings = KeyValues(<String, dynamic>{});
    saves.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall call) async {
        expect(call.method, 'saveFile');
        saves.add(call.arguments as Map<Object?, Object?>);
        return '/saved/backup.json';
      },
    );
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      null,
    );
    debugDefaultTargetPlatformOverride = null;
    entries.dispose();
    categories.dispose();
    settings.dispose();
    await storage.close();
  });

  Future<void> launch(WidgetTester tester, {Locale locale = const Locale('en')}) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<WorkEntries>.value(value: entries),
          ChangeNotifierProvider<WorkCategories>.value(value: categories),
          ChangeNotifierProvider<KeyValues>.value(value: settings),
        ],
        child: MaterialApp(
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            ...GlobalMaterialLocalizations.delegates,
            AppLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          home: const ExportImportPage(appTitle: 'KGL Time'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openConfirmation(WidgetTester tester, WorkData data) async {
    unawaited(
      showDialog<void>(
        context: tester.element(find.byType(ExportImportPage)),
        builder: (BuildContext context) => ImportReplaceConfirmationDialog(loadedData: data),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> confirm(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(TextButton, 'Import backup and replace existing entries'));
    await tester.pumpAndSettle();
  }

  Future<void> importAndEdit(WidgetTester tester, {bool editCategory = false}) async {
    await launch(tester);
    final WorkData backup = WorkData.fromJson(backupFixture());
    backup.workEntries.first.description = 'Imported description';
    await openConfirmation(tester, backup);
    await confirm(tester);
    if (editCategory) {
      final WorkCategory original = categories.entries.first;
      categories.updateEntry(
        original,
        WorkCategory('Later category', listIndex: original.listIndex)..id = original.id,
      );
    } else {
      final WorkEntry original = entries.entries.single;
      entries.updateEntry(
        original,
        original.copyWith(description: const Value<String?>('Later edit')),
      );
    }
    await tester.pumpAndSettle();
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.byType(UndoImportConfirmationDialog), findsOneWidget);
  }

  Future<Map<String, dynamic>> saveBackup(WidgetTester tester) async {
    final Finder card = find.ancestor(
      of: find.text('Export backup of work entries'),
      matching: find.byType(ExportEntriesCard),
    );
    final Finder button = find.descendant(
      of: card,
      matching: find.widgetWithText(TextButton, 'Save locally'),
    );
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    final Map<Object?, Object?> saved = saves.last;
    expect(saved['fileName'], endsWith('.json'));
    final Uint8List bytes = saved['data']! as Uint8List;
    return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
  }

  for (final (Locale locale, String entryLabel, String categoryLabel) in <(Locale, String, String)>[
    (const Locale('en'), 'entries', 'categories'),
    (const Locale('de'), 'Einträge', 'Kategorien'),
  ]) {
    for (final (int entryCount, int categoryCount) in <(int, int)>[(1, 3), (3, 1), (0, 3)]) {
      testWidgets(
        'backup preview shows $entryCount entries and $categoryCount categories in ${locale.languageCode}',
        (WidgetTester tester) async {
          await launch(tester, locale: locale);
          final WorkData backup = WorkData(
            workEntries: List<WorkEntry>.generate(
              entryCount,
              (int index) => WorkEntry(
                workDurationInSeconds: 60,
                date: DateTime.utc(2026, 11, 15),
              )..id = index + 1,
            ),
            workCategories: List<WorkCategory>.generate(
              categoryCount,
              (int index) => WorkCategory(
                'Category $index',
                listIndex: index,
              )..id = index + 1,
            ),
            backupFormatVersion: 1,
            exportedAt: DateTime.utc(2026, 11, 15),
          );
          await openConfirmation(tester, backup);
          expect(
            find.text('$entryCount $entryLabel, $categoryCount $categoryLabel'),
            findsOneWidget,
          );
          expect(backup.workEntries, hasLength(entryCount));
          expect(backup.workCategories, hasLength(categoryCount));
        },
      );
    }
  }

  testWidgets('saved JSON includes active entries, trash and ordered categories', (
    WidgetTester tester,
  ) async {
    await launch(tester);
    final Map<String, dynamic> saved = await saveBackup(tester);
    final Map<String, dynamic> expected = backupFixture();
    expect(saved['workEntries'], unorderedEquals(expected['workEntries'] as List<dynamic>));
    expect(saved['workCategories'], expected['workCategories']);
  });

  testWidgets('export after restore uses the replaced dataset without reopening the page', (
    WidgetTester tester,
  ) async {
    await launch(tester);
    final Map<String, dynamic> json = backupFixture();
    json['workEntries'] = <dynamic>[];
    json['workCategories'] = <dynamic>[];
    await openConfirmation(tester, WorkData.fromJson(json));
    await confirm(tester);
    expect(entries.entriesIncludingTrash, isEmpty);
    final Map<String, dynamic> saved = await saveBackup(tester);
    expect(saved['workEntries'], isEmpty);
    expect(saved['workCategories'], isEmpty);
  });

  testWidgets('export reflects category edits while the page stays open', (
    WidgetTester tester,
  ) async {
    await launch(tester);
    final WorkCategory original = categories.entries.first;
    final WorkCategory renamed = WorkCategory('Renamed', icon: original.icon, listIndex: 0)
      ..id = original.id;
    categories.updateEntry(original, renamed);
    await tester.pumpAndSettle();
    final Map<String, dynamic> saved = await saveBackup(tester);
    final List<dynamic> savedCategories = saved['workCategories'] as List<dynamic>;
    expect((savedCategories.first as Map<String, dynamic>)['displayName'], 'Renamed');
  });

  testWidgets('cancelling restore leaves stored entries and categories intact', (
    WidgetTester tester,
  ) async {
    await launch(tester);
    final WorkData empty = WorkData(
      workEntries: const [],
      workCategories: const [],
      backupFormatVersion: 1,
      exportedAt: DateTime.utc(2026, 11, 14),
    );
    await openConfirmation(tester, empty);
    expect(find.text(importTrackerWarning), findsNothing);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(entries.entriesIncludingTrash, hasLength(2));
    expect(categories.entries, hasLength(2));
    expect(await storage.workEntries.loadEntries(), hasLength(2));
    expect(await storage.workCategories.loadEntries(), hasLength(2));
    expect(find.text('Import successful'), findsNothing);
  });

  testWidgets('restore does not show success before category persistence finishes', (
    WidgetTester tester,
  ) async {
    startTracker();
    await launch(tester);
    await openConfirmation(tester, WorkData.fromJson(backupFixture()));
    final Completer<void> barrier = Completer<void>();
    storage.workCategories.writeBarrier = barrier;
    try {
      await confirm(tester);
      expect(find.text('Import successful'), findsNothing);
      await expectTrackerRunning();
      expect(find.byType(ImportReplaceConfirmationDialog), findsOneWidget);
      expect(
        tester
            .widget<TextButton>(
              find.widgetWithText(TextButton, 'Import backup and replace existing entries'),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Cancel')).onPressed,
        isNull,
      );
      expect(storage.replacementCalls, 1);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.byType(ImportReplaceConfirmationDialog), findsOneWidget);
    } finally {
      barrier.complete();
      await tester.pumpAndSettle();
    }
    expect(find.byType(ImportReplaceConfirmationDialog), findsNothing);
    expect(find.text('Import successful'), findsOneWidget);
    await expectTrackerStopped();
  });

  testWidgets('repeated confirmation starts only one replacement', (WidgetTester tester) async {
    await launch(tester);
    await openConfirmation(tester, WorkData.fromJson(backupFixture()));
    final Completer<void> barrier = Completer<void>();
    storage.workCategories.writeBarrier = barrier;
    final VoidCallback onPressed = tester
        .widget<TextButton>(
          find.widgetWithText(TextButton, 'Import backup and replace existing entries'),
        )
        .onPressed!;
    try {
      onPressed();
      onPressed();
      await tester.pumpAndSettle();
      expect(storage.replacementCalls, 1);
    } finally {
      barrier.complete();
      await tester.pumpAndSettle();
    }
  });

  for (final bool throwsError in <bool>[true, false]) {
    testWidgets('failed replacement stays open and allows retry (exception: $throwsError)', (
      WidgetTester tester,
    ) async {
      startTracker();
      await launch(tester);
      final WorkData empty = WorkData(
        workEntries: const [],
        workCategories: const [],
        backupFormatVersion: 1,
        exportedAt: DateTime.utc(2026, 11, 14),
      );
      await openConfirmation(tester, empty);
      storage.workCategories.failWrites = throwsError;
      storage.acceptReplacement = throwsError;
      await confirm(tester);
      expect(find.byType(ImportReplaceConfirmationDialog), findsOneWidget);
      expect(find.text('Import failed'), findsOneWidget);
      expect(find.text('Import successful'), findsNothing);
      await expectTrackerRunning();
      expect(entries.entriesIncludingTrash, hasLength(2));
      expect(categories.entries, hasLength(2));
      expect(await storage.workEntries.loadEntries(), hasLength(2));
      expect(await storage.workCategories.loadEntries(), hasLength(2));
      expect(
        tester
            .widget<TextButton>(
              find.widgetWithText(TextButton, 'Import backup and replace existing entries'),
            )
            .onPressed,
        isNotNull,
      );
      storage.workCategories.failWrites = false;
      storage.acceptReplacement = true;
      await confirm(tester);
      expect(find.byType(ImportReplaceConfirmationDialog), findsNothing);
      expect(entries.entriesIncludingTrash, isEmpty);
      expect(categories.entries, isEmpty);
      expect(storage.replacementCalls, 2);
      await expectTrackerStopped();
    });
  }

  testWidgets('undo from the success message restores the prior dataset atomically', (
    WidgetTester tester,
  ) async {
    await launch(tester);
    final WorkData empty = WorkData(
      workEntries: const [],
      workCategories: const [],
      backupFormatVersion: 1,
      exportedAt: DateTime.utc(2026, 11, 14),
    );
    await openConfirmation(tester, empty);
    await confirm(tester);
    expect(entries.entriesIncludingTrash, isEmpty);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.byType(UndoImportConfirmationDialog), findsNothing);
    expect(entries.entriesIncludingTrash, hasLength(2));
    expect(categories.entries, hasLength(2));
    expect(await storage.workEntries.loadEntries(), hasLength(2));
    expect(await storage.workCategories.loadEntries(), hasLength(2));
    expect(storage.replacementCalls, 2);
    expect(find.text('Backup import undone'), findsOneWidget);
    expect(tester.widget<SnackBar>(find.byType(SnackBar)).action, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('undo failure is reported and preserves the imported dataset', (
    WidgetTester tester,
  ) async {
    await launch(tester);
    final WorkData empty = WorkData(
      workEntries: const [],
      workCategories: const [],
      backupFormatVersion: 1,
      exportedAt: DateTime.utc(2026, 11, 14),
    );
    await openConfirmation(tester, empty);
    await confirm(tester);
    storage.acceptReplacement = false;
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Failed to undo the backup import'), findsOneWidget);
    expect(find.text('Backup import undone'), findsNothing);
    expect(entries.entriesIncludingTrash, isEmpty);
    expect(categories.entries, isEmpty);
    expect(await storage.workEntries.loadEntries(), isEmpty);
    expect(await storage.workCategories.loadEntries(), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelling undo after edits preserves the changed dataset', (
    WidgetTester tester,
  ) async {
    await importAndEdit(tester);
    expect(find.text('Undo backup import?'), findsOneWidget);
    expect(
      find.text(
        'This will restore the data from before the import. Changes made since the import will be lost.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(UndoImportConfirmationDialog), findsNothing);
    expect(entries.entries.single.description, 'Later edit');
    expect(
      (await storage.workEntries.loadEntries())
          .singleWhere((WorkEntry entry) => entry.id == 42)
          .description,
      'Later edit',
    );
    expect(storage.replacementCalls, 1);
    expect(find.text('Backup import undone'), findsNothing);
  });

  testWidgets('confirmed undo of category edits stays open and blocks dismissal until committed', (
    WidgetTester tester,
  ) async {
    await importAndEdit(tester, editCategory: true);
    startTracker();
    await tester.pumpAndSettle();
    expect(find.text(undoTrackerWarning), findsOneWidget);
    // The captured snapshot remains available after the snackbar's lifetime.
    await tester.pump(const Duration(seconds: 40));
    await tester.pumpAndSettle();
    final Completer<void> barrier = Completer<void>();
    storage.workCategories.writeBarrier = barrier;
    try {
      await tester.tap(find.widgetWithText(TextButton, 'Undo'));
      await tester.pumpAndSettle();
      expect(find.byType(UndoImportConfirmationDialog), findsOneWidget);
      expect(tester.widget<TextButton>(find.widgetWithText(TextButton, 'Undo')).onPressed, isNull);
      expect(
        tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Cancel')).onPressed,
        isNull,
      );
      expect(categories.entries.first.displayName, 'Later category');
      expect(entries.entries.single.description, 'Imported description');
      expect(storage.replacementCalls, 2);
      expect(find.text('Backup import undone'), findsNothing);
      await expectTrackerRunning();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(UndoImportConfirmationDialog), findsOneWidget);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.byType(UndoImportConfirmationDialog), findsOneWidget);
    } finally {
      barrier.complete();
      await tester.pumpAndSettle();
    }
    expect(find.byType(UndoImportConfirmationDialog), findsNothing);
    expect(categories.entries.first.displayName, 'Planning');
    expect(
      entries.entries.single.description,
      (backupFixture()['workEntries'] as List<Map<String, dynamic>>).first['description'],
    );
    expect((await storage.workCategories.loadEntries()).first.displayName, 'Planning');
    expect(find.text('Backup import undone'), findsOneWidget);
    expect(tester.widget<SnackBar>(find.byType(SnackBar)).action, isNull);
    await expectTrackerStopped();
    expect(tester.takeException(), isNull);
  });

  for (final bool throwsError in <bool>[true, false]) {
    testWidgets(
      'failed confirmed undo preserves edits and allows retry (exception: $throwsError)',
      (WidgetTester tester) async {
        await importAndEdit(tester);
        startTracker();
        storage.workCategories.failWrites = throwsError;
        storage.acceptReplacement = throwsError;
        await tester.tap(find.widgetWithText(TextButton, 'Undo'));
        await tester.pumpAndSettle();
        expect(find.byType(UndoImportConfirmationDialog), findsOneWidget);
        expect(find.text('Failed to undo the backup import'), findsOneWidget);
        expect(find.text('Backup import undone'), findsNothing);
        await expectTrackerRunning();
        expect(entries.entries.single.description, 'Later edit');
        expect(
          (await storage.workEntries.loadEntries())
              .singleWhere((WorkEntry entry) => entry.id == 42)
              .description,
          'Later edit',
        );
        expect(
          tester.widget<TextButton>(find.widgetWithText(TextButton, 'Undo')).onPressed,
          isNotNull,
        );
        storage.workCategories.failWrites = false;
        storage.acceptReplacement = true;
        await tester.tap(find.widgetWithText(TextButton, 'Undo'));
        await tester.pumpAndSettle();
        expect(find.byType(UndoImportConfirmationDialog), findsNothing);
        expect(
          entries.entries.single.description,
          (backupFixture()['workEntries'] as List<Map<String, dynamic>>).first['description'],
        );
        expect(storage.replacementCalls, 3);
        await expectTrackerStopped();
        expect(find.text('Backup import undone'), findsOneWidget);
        expect(tester.widget<SnackBar>(find.byType(SnackBar)).action, isNull);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('unsupported backup formats cannot be confirmed', (WidgetTester tester) async {
    await launch(tester);
    final WorkData unsupported = WorkData(
      workEntries: const [],
      workCategories: const [],
      backupFormatVersion: 2,
      exportedAt: DateTime.utc(2026, 11, 14),
    );
    await openConfirmation(tester, unsupported);
    final Finder button = find.widgetWithText(
      TextButton,
      'Import backup and replace existing entries',
    );
    if (button.evaluate().isNotEmpty) {
      expect(tester.widget<TextButton>(button).onPressed, isNull);
    }
    expect(await storage.workEntries.loadEntries(), hasLength(2));
  });

  testWidgets('successful import cancels tracking instead of rebinding its categories', (
    WidgetTester tester,
  ) async {
    startTracker();
    await launch(tester);
    final Map<String, dynamic> json = backupFixture();
    final List<Map<String, dynamic>> importedCategories =
        json['workCategories'] as List<Map<String, dynamic>>;
    importedCategories.first['displayName'] = 'Unrelated imported category';
    await openConfirmation(tester, WorkData.fromJson(json));
    expect(find.text(importTrackerWarning), findsOneWidget);
    await confirm(tester);
    await expectTrackerStopped();
    expect(entries.entriesIncludingTrash, hasLength(2));
    expect(await storage.workEntries.loadEntries(), hasLength(2));
    expect(categories.entries.first.displayName, 'Unrelated imported category');
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    await expectTrackerStopped();
    expect(entries.entriesIncludingTrash, hasLength(2));
  });

  for (final (Locale locale, String warning) in <(Locale, String)>[
    (const Locale('en'), importTrackerWarning),
    (
      const Locale('de'),
      'Beim Importieren dieses Backups wird die laufende Zeiterfassung abgebrochen, ohne die erfasste Zeit zu speichern.',
    ),
  ]) {
    testWidgets(
      'import warns about running tracking and cancellation preserves it in ${locale.languageCode}',
      (WidgetTester tester) async {
        startTracker();
        await launch(tester, locale: locale);
        await openConfirmation(tester, WorkData.fromJson(backupFixture()));
        expect(find.text(warning), findsOneWidget);
        final AppLocalizations loc = AppLocalizations.of(
          tester.element(find.byType(ImportReplaceConfirmationDialog)),
        )!;
        await tester.tap(find.widgetWithText(ElevatedButton, loc.cancel));
        await tester.pumpAndSettle();
        await expectTrackerRunning();
        expect(storage.replacementCalls, 0);
      },
    );
  }

  for (final bool accept in <bool>[false, true]) {
    testWidgets('a tracker started after import requires undo confirmation (accept: $accept)', (
      WidgetTester tester,
    ) async {
      await launch(tester);
      await openConfirmation(tester, WorkData.fromJson(backupFixture()));
      await confirm(tester);
      startTracker();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.byType(UndoImportConfirmationDialog), findsOneWidget);
      expect(find.text(undoTrackerWarning), findsOneWidget);
      expect(
        find.text(
          'This will restore the data from before the import. Changes made since the import will be lost.',
        ),
        findsNothing,
      );
      await expectTrackerRunning();
      if (accept) {
        await tester.tap(find.widgetWithText(TextButton, 'Undo'));
      } else {
        await tester.tap(find.widgetWithText(ElevatedButton, 'Cancel'));
      }
      await tester.pumpAndSettle();
      if (accept) {
        await expectTrackerStopped();
        expect(storage.replacementCalls, 2);
      } else {
        await expectTrackerRunning();
        expect(storage.replacementCalls, 1);
      }
      expect(entries.entriesIncludingTrash, hasLength(2));
      expect(await storage.workEntries.loadEntries(), hasLength(2));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'undo warns about a new running tracker in German and cancellation keeps it running',
    (WidgetTester tester) async {
      await launch(tester, locale: const Locale('de'));
      await openConfirmation(tester, WorkData.fromJson(backupFixture()));
      final AppLocalizations loc = AppLocalizations.of(
        tester.element(find.byType(ImportReplaceConfirmationDialog)),
      )!;
      await tester.tap(find.widgetWithText(TextButton, loc.importBacupAndReplaceExistingEntries));
      await tester.pumpAndSettle();
      startTracker();
      await tester.pumpAndSettle();
      await tester.tap(find.text(loc.undo));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Beim Rückgängigmachen dieses Imports wird die laufende Zeiterfassung abgebrochen, ohne die erfasste Zeit zu speichern.',
        ),
        findsOneWidget,
      );
      expect(find.text(loc.undoImportChangesWarning), findsNothing);
      await tester.tap(find.widgetWithText(ElevatedButton, loc.cancel));
      await tester.pumpAndSettle();
      await expectTrackerRunning();
      expect(storage.replacementCalls, 1);
    },
  );
}
