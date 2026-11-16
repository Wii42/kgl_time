import 'dart:convert';
import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kgl_time/data_model/key_value.dart';
import 'package:kgl_time/data_model/key_values.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/export_import/work_data.dart';
import 'package:kgl_time/persistent_storage/isar_persistent_storage.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_interface.dart';

import '../support/backup_fixture.dart';
import '../support/memory_storage.dart';

void main() {
  for (final bool useIsar in <bool>[false, true]) {
    group('${useIsar ? 'Isar' : 'Memory'} replaceWorkData', () {
      late PersistentStorage storage;
      Directory? directory;

      if (useIsar) setUpAll(_initializeIsarCore);

      setUp(() async {
        if (useIsar) {
          directory = await Directory.systemTemp.createTemp('kgl_storage_test_');
          storage = await _openIsarStorage(directory!);
        } else {
          storage = MemoryStorage();
        }
        await storage.workEntries.saveEntries(<WorkEntry>[
          WorkEntry(workDurationInSeconds: 60, date: DateTime.utc(2020))..id = 1,
        ]);
        await storage.workCategories.saveEntries(<WorkCategory>[
          WorkCategory('Original', listIndex: 0)..id = 1,
        ]);
        await storage.keyValueStorage.set<String>('themeMode', 'dark');
        await storage.keyValueStorage.set<bool>('isFirstRun', false);
      });

      tearDown(() async {
        await storage.close();
        await directory?.delete(recursive: true);
        directory = null;
      });

      test('commits both collections with IDs, trash and edit metadata intact', () async {
        final WorkData backup = WorkData.fromJson(backupFixture());
        final bool success = await storage.replaceWorkData(
          entries: backup.workEntries,
          categories: backup.workCategories,
        );
        expect(success, isTrue);

        if (useIsar) {
          await storage.close();
          storage = await _openIsarStorage(directory!);
        }
        expect(
          (await storage.workEntries.loadEntries()).map(_entryData),
          unorderedEquals(backup.workEntries.map(_entryData)),
        );
        expect(
          (await storage.workCategories.loadEntries()).map(
            (WorkCategory category) => category.toJson(),
          ),
          unorderedEquals(backup.workCategories.map((WorkCategory category) => category.toJson())),
        );
        expect(await storage.keyValueStorage.getAll<dynamic>(), <String, dynamic>{
          'themeMode': 'dark',
          'isFirstRun': false,
        });
      });

      test('empty replacement clears both collections and retains settings', () async {
        expect(await storage.replaceWorkData(entries: const [], categories: const []), isTrue);
        expect(await storage.workEntries.loadEntries(), isEmpty);
        expect(await storage.workCategories.loadEntries(), isEmpty);
        expect(await storage.keyValueStorage.get<String>('themeMode'), 'dark');
        expect(await storage.keyValueStorage.get<bool>('isFirstRun'), isFalse);
      });

      test('category insertion failure rolls back entries and categories', () async {
        final DateTime start = DateTime.utc(2026, 11, 15, 8);
        await storage.keyValueStorage.set<DateTime>(KeyValues.timeTrackerStartKey, start);
        await storage.keyValueStorage.set<String>(KeyValues.timeTrackerCategoriesKey, '1');
        final List<Map<String, dynamic>> previousEntries = (await storage.workEntries.loadEntries())
            .map(_entryData)
            .toList();
        final List<Map<String, dynamic>> previousCategories =
            (await storage.workCategories.loadEntries())
                .map((WorkCategory category) => category.toJson())
                .toList();
        final WorkEntry replacement = WorkEntry(
          workDurationInSeconds: 120,
          date: DateTime.utc(2026),
        )..id = 42;

        await expectLater(
          storage.replaceWorkData(
            entries: <WorkEntry>[replacement],
            categories: <WorkCategory>[_FailingCategory()],
            keysToRemove: const <String>[
              KeyValues.timeTrackerStartKey,
              KeyValues.timeTrackerCategoriesKey,
            ],
          ),
          throwsStateError,
        );
        expect((await storage.workEntries.loadEntries()).map(_entryData), previousEntries);
        expect(
          (await storage.workCategories.loadEntries()).map(
            (WorkCategory category) => category.toJson(),
          ),
          previousCategories,
        );
        expect(await storage.keyValueStorage.get<String>('themeMode'), 'dark');
        expect(
          (await storage.keyValueStorage.get<DateTime>(KeyValues.timeTrackerStartKey))?.toUtc(),
          start,
        );
        expect(await storage.keyValueStorage.get<String>(KeyValues.timeTrackerCategoriesKey), '1');
      });

      test('replacement removes requested tracker keys while preserving other settings', () async {
        await storage.keyValueStorage.set<DateTime>(
          KeyValues.timeTrackerStartKey,
          DateTime.utc(2026),
        );
        await storage.keyValueStorage.set<String>(KeyValues.timeTrackerCategoriesKey, '1');
        final WorkData backup = WorkData.fromJson(backupFixture());
        expect(
          await storage.replaceWorkData(
            entries: backup.workEntries,
            categories: backup.workCategories,
            keysToRemove: const <String>[
              KeyValues.timeTrackerStartKey,
              KeyValues.timeTrackerCategoriesKey,
            ],
          ),
          isTrue,
        );
        expect(await storage.keyValueStorage.get<DateTime>(KeyValues.timeTrackerStartKey), isNull);
        expect(
          await storage.keyValueStorage.get<String>(KeyValues.timeTrackerCategoriesKey),
          isNull,
        );
        expect(await storage.keyValueStorage.get<String>('themeMode'), 'dark');
        expect(await storage.keyValueStorage.get<bool>('isFirstRun'), isFalse);
      });

      test('new records receive IDs beyond the restored IDs', () async {
        final WorkData backup = WorkData.fromJson(backupFixture());
        await storage.replaceWorkData(
          entries: backup.workEntries,
          categories: backup.workCategories,
        );
        final WorkEntry addedEntry = WorkEntry(workDurationInSeconds: 60, date: DateTime.utc(2026));
        final WorkCategory addedCategory = WorkCategory('New category', listIndex: 2);
        await storage.workEntries.addEntry(addedEntry);
        await storage.workCategories.addEntry(addedCategory);
        expect(addedEntry.id, greaterThan(43));
        expect(addedCategory.id, greaterThan(8));
        expect(await storage.workEntries.loadEntries(), hasLength(3));
        expect(await storage.workCategories.loadEntries(), hasLength(3));
      });
    });
  }
}

Map<String, dynamic> _entryData(WorkEntry entry) {
  final Map<String, dynamic> data = entry.toJson();
  // Isar returns local DateTimes; compare instants rather than timezone flags.
  for (final String field in <String>[
    'date',
    'startTime',
    'endTime',
    'lastEdit',
    'wasMovedToTrashAt',
  ]) {
    final String? value = data[field] as String?;
    if (value != null) data[field] = DateTime.parse(value).toUtc().toIso8601String();
  }
  data['categories'] = entry.categories
      .map((EmbeddedWorkCategory category) => category.toJson())
      .toList();
  return data;
}

Future<void> _initializeIsarCore() async {
  final File configuration = File('.dart_tool/package_config.json');
  final Map<String, dynamic> packages =
      jsonDecode(await configuration.readAsString()) as Map<String, dynamic>;
  final Map<String, dynamic> nativePackage = (packages['packages'] as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .singleWhere(
        (Map<String, dynamic> package) => package['name'] == 'isar_community_flutter_libs',
      );
  final Uri packageDirectory = configuration.absolute.uri.resolve('${nativePackage['rootUri']}/');
  final String relativeLibrary = switch (Platform.operatingSystem) {
    'linux' => 'linux/libisar.so',
    'windows' => 'windows/libisar.dll',
    'macos' => 'macos/libisar.dylib',
    _ => throw UnsupportedError('Native storage tests require a desktop platform'),
  };
  await Isar.initializeIsarCore(
    libraries: <Abi, String>{Abi.current(): packageDirectory.resolve(relativeLibrary).toFilePath()},
  );
}

Future<IsarPersistentStorage> _openIsarStorage(Directory directory) async {
  final Isar isar = await Isar.open(
    <CollectionSchema<dynamic>>[WorkEntrySchema, WorkCategorySchema, KeyValueSchema],
    directory: directory.path,
    name: 'replace_work_data_test',
    inspector: false,
    relaxedDurability: false,
  );
  return IsarPersistentStorage()
    ..isar = isar
    ..workEntries = IsarTable<WorkEntry>(isar, isar.workEntries)
    ..workCategories = IsarTable<WorkCategory>(isar, isar.workCategories)
    ..keyValueStorage = IsarKeyValue(isar);
}

class _FailingCategory extends WorkCategory {
  _FailingCategory() : super('Fails during insertion');

  @override
  int get id => throw StateError('Injected category ID read failure');
}
