import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kgl_time/data_model/work_categories.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/data_model/work_entries.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/export_import/export_service.dart';
import 'package:kgl_time/l10n/generated/app_localizations_en.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';

import '../support/memory_storage.dart';

void main() {
  late MemoryStorage storage;
  setUpAll(() => initializeDateFormatting('en'));
  setUp(() {
    storage = MemoryStorage();
    PersistentStorageService.setImplementation(storage);
  });
  tearDown(() async => storage.close());

  test('trash and restore preserve the ID and work data in storage', () async {
    final category = EmbeddedWorkCategory(displayName: 'Office', id: 7);
    final original = WorkEntry.fromStartAndEndTime(
      startTime: DateTime(2026, 10, 23, 8),
      endTime: DateTime(2026, 10, 23, 9, 30),
      description: 'Planning',
      categories: [category],
      lastEdit: DateTime(2026, 10, 23, 10),
      tickedOff: true,
      createType: CreateWorkEntryType.timeTracker,
      wasEdited: true,
    )..id = 42;
    await storage.workEntries.addEntry(original);
    final model = WorkEntries([original]);
    addTearDown(model.dispose);
    var notifications = 0;
    model.addListener(() => notifications++);
    model.moveToTrashBin(original);

    expect(model.entries, isEmpty);
    final trashed = model.entriesInTrash.single;
    expect(trashed.id, 42);
    expect(trashed.wasMovedToTrashAt, isNotNull);
    expect(trashed.tickedOff, isFalse);
    model.restoreFromTrashBin(trashed);

    expect(model.entriesInTrash, isEmpty);
    final restored = model.entries.single;
    expect(restored.id, original.id);
    expect(restored.workDuration, original.workDuration);
    expect(restored.date, original.date);
    expect(restored.startTime, original.startTime);
    expect(restored.endTime, original.endTime);
    expect(restored.description, original.description);
    expect(restored.categories, original.categories);
    expect(restored.lastEdit, original.lastEdit);
    expect(restored.createType, original.createType);
    expect(restored.wasEdited, original.wasEdited);
    expect(notifications, greaterThanOrEqualTo(2));
    expect((await storage.workEntries.loadEntries()).single.id, 42);
    expect((await storage.workEntries.loadEntries()).single.isInTrash, isFalse);
  });

  test(
    'startup deletes expired trash but preserves recent trash and active data',
    () async {
      final now = DateTime.now();
      WorkEntry make(int id, DateTime? trashedAt) => WorkEntry.fromDuration(
        duration: const Duration(minutes: 30),
        date: DateTime(2020),
        wasMovedToTrashAt: trashedAt,
      )..id = id;
      final active = make(1, null);
      final expired = make(2, now.subtract(const Duration(days: 31)));
      final recent = make(3, now.subtract(const Duration(days: 29)));
      await storage.workEntries.saveEntries([active, expired, recent]);

      final model = WorkEntries([active, expired, recent]);
      addTearDown(model.dispose);
      expect(model.entries, [active]);
      expect(model.entriesInTrash, [recent]);
      expect(
        (await storage.workEntries.loadEntries()).map((e) => e.id),
        unorderedEquals([1, 3]),
      );
    },
  );

  test('export selection excludes trash and includes restored entries', () {
    final active = WorkEntry.fromDuration(
      duration: const Duration(minutes: 10),
      date: DateTime(2026, 10, 23),
      description: 'Active',
    )..id = 1;
    final trash = WorkEntry.fromDuration(
      duration: const Duration(minutes: 20),
      date: DateTime(2026, 10, 23),
      description: 'Trashed',
      wasMovedToTrashAt: DateTime.now(),
    )..id = 2;
    final model = WorkEntries([active, trash]);
    addTearDown(model.dispose);
    List<dynamic> descriptions() => csv
        .decode(
          const ExportService().entriesToCsv(
            model.entries,
            AppLocalizationsEn(),
          ),
        )
        .skip(1)
        .map((row) => row[2])
        .toList();
    expect(descriptions(), ['Active']);
    model.restoreFromTrashBin(trash);
    expect(descriptions(), unorderedEquals(['Active', 'Trashed']));
  });

  test('entries are sorted newest first after adding and editing', () {
    WorkEntry make(int id, int day) => WorkEntry.fromDuration(
      duration: const Duration(minutes: 10),
      date: DateTime(2026, 10, day),
    )..id = id;
    final old = make(1, 20);
    final recent = make(2, 22);
    final model = WorkEntries([old, recent]);
    addTearDown(model.dispose);
    model.add(make(3, 21));
    expect(model.entries.map((e) => e.id), [2, 3, 1]);
    model.updateEntry(old, make(1, 23));
    expect(model.entries.map((e) => e.id), [1, 2, 3]);
  });

  group('category ordering', () {
    Future<WorkCategories> categories() async {
      final entries = List.generate(
        4,
        (i) => WorkCategory('Category $i', listIndex: i)..id = i + 1,
      );
      await storage.workCategories.saveEntries(entries);
      final model = WorkCategories(entries.reversed.toList());
      addTearDown(model.dispose);
      return model;
    }

    for (final move in [
      (0, 3, [2, 3, 4, 1]),
      (3, 0, [4, 1, 2, 3]),
      (1, 2, [1, 3, 2, 4]),
      (2, 1, [1, 3, 2, 4]),
      (1, 1, [1, 2, 3, 4]),
    ]) {
      test(
        'move ${move.$1} to final index ${move.$2} survives model reload',
        () async {
          final model = await categories();
          model.reorder(move.$1, move.$2);
          // Model writes are asynchronous and currently return void.
          await Future<void>.delayed(Duration.zero);
          expect(model.entries.map((e) => e.id), move.$3);
          expect(model.entries.map((e) => e.listIndex), [0, 1, 2, 3]);
          final reloaded = WorkCategories(
            await storage.workCategories.loadEntries(),
          );
          addTearDown(reloaded.dispose);
          expect(reloaded.entries.map((e) => e.id), move.$3);
        },
      );
    }

    test('inserting a category updates order and persisted indices', () async {
      final model = await categories();
      model.add(WorkCategory('Inserted')..id = 5, index: 1);
      await Future<void>.delayed(Duration.zero);
      expect(model.entries.map((e) => e.id), [1, 5, 2, 3, 4]);
      final reloaded = WorkCategories(
        await storage.workCategories.loadEntries(),
      );
      addTearDown(reloaded.dispose);
      expect(reloaded.entries.map((e) => e.id), [1, 5, 2, 3, 4]);
      expect(reloaded.entries.map((e) => e.listIndex), [0, 1, 2, 3, 4]);
    });
  });
}
