import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/format_duration.dart';
import 'package:kgl_time/persistent_storage/isar_persistent_storage.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';

import 'data_model/work_category.dart';
import 'kgl_time_app.dart';

const String appVersion = '0.3.1';

const int schemaVersion = 2;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PersistentStorageService.initializeImplementation(
    IsarPersistentStorage(),
  );
  await _checkSchemaVersion([SchemaMigration1to2()]);
  List<WorkEntry> initialEntries = await PersistentStorageService
      .instance
      .workEntries
      .loadEntries();
  List<WorkCategory> initialCategories = await PersistentStorageService
      .instance
      .workCategories
      .loadEntries();

  Map<String, dynamic> initialKeyValueStorage = await PersistentStorageService
      .instance
      .keyValueStorage
      .getAll();
  bool isFirstRun = initialKeyValueStorage['isFirstRun'] ?? true;
  if (isFirstRun) {
    await PersistentStorageService.instance.workCategories.saveEntries(
      mockWorkCategories,
    );
    initialCategories.addAll(mockWorkCategories);
    await PersistentStorageService.instance.keyValueStorage.set(
      'isFirstRun',
      false,
    );
  }
  await initializeDateFormatting(); // initialize the date formatting for German
  runApp(
    KglTimeApp(
      appTitle: 'KGL Time',
      initialEntries: initialEntries,
      initialCategories: initialCategories,
      initialKeyValueStorage: initialKeyValueStorage,
    ),
  );
}

List<WorkCategory> get mockWorkCategories => [
  WorkCategory(
    'Telefonanruf',
    uuid: WorkEntry.generateUuid(),
    lastEdit: DateTime.timestamp(),
  ),
  WorkCategory(
    'Kategorie 2',
    uuid: WorkEntry.generateUuid(),
    lastEdit: DateTime.timestamp(),
  ),
  WorkCategory(
    'Kategorie 3',
    uuid: WorkEntry.generateUuid(),
    lastEdit: DateTime.timestamp(),
  ),
  WorkCategory(
    'Kategorie 4',
    uuid: WorkEntry.generateUuid(),
    lastEdit: DateTime.timestamp(),
  ),
  WorkCategory(
    'Kategorie 5',
    uuid: WorkEntry.generateUuid(),
    lastEdit: DateTime.timestamp(),
  ),
];

List<WorkEntry> get mockWorkEntries => [
  WorkEntry.fromDuration(
    duration: const Duration(hours: 1),
    date: DateTime.now(),
    description: 'Test',
    categories: [mockWorkCategories[0].toEmbedded()],
  ),
  WorkEntry.fromDuration(
    duration: const Duration(minutes: 30),
    date: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
    description: 'Test2',
    categories: [mockWorkCategories[1].toEmbedded()],
  ),
  WorkEntry.fromDuration(
    duration: const Duration(hours: 1, minutes: 30),
    date: DateTime.now().subtract(const Duration(days: 7)),
    description: 'old entry',
    categories: [
      mockWorkCategories[3].toEmbedded(),
      mockWorkCategories[4].toEmbedded(),
    ],
  ),
];

/// Checks the stored schema version and executes all applicable [migrations]
/// if the stored version is different from the current [schemaVersion].
Future<void> _checkSchemaVersion(List<SchemaMigration> migrations) async {
  final storage = PersistentStorageService.instance;
  final kvStorage = storage.keyValueStorage;
  int storedSchemaVersion = await kvStorage.get<int>('schemaVersion') ?? 0;
  if (storedSchemaVersion != schemaVersion) {
    List<SchemaMigration> applicableMigrations =
        migrations
            .where(
              (migration) =>
                  migration.fromSchemaVersion >= storedSchemaVersion &&
                  migration.toSchemaVersion <= schemaVersion,
            )
            .toList()
          ..sort();
    for (SchemaMigration migration in applicableMigrations) {
      await migration.migrate(storage);
    }
    //onSchemaVersionChanged(storedSchemaVersion, schemaVersion);
    await kvStorage.set<int>('schemaVersion', schemaVersion);
  }
}

abstract class SchemaMigration implements Comparable<SchemaMigration> {
  int get fromSchemaVersion;
  int get toSchemaVersion;
  SchemaMigration() {
    assert(fromSchemaVersion + 1 == toSchemaVersion);
  }
  Future<void> migrate(PersistentStorageService storageService);

  @override
  int compareTo(SchemaMigration other) {
    return fromSchemaVersion.compareTo(other.fromSchemaVersion);
  }
}

class SchemaMigration1to2 extends SchemaMigration {
  @override
  int get fromSchemaVersion => 1;

  @override
  int get toSchemaVersion => 2;

  // Migrate work entries to have uuids and lastEdit set
  @override
  Future<void> migrate(PersistentStorageService storage) async {
    log('Migrating schema from $fromSchemaVersion to $toSchemaVersion');
    List<WorkEntry> entries = await storage.workEntries.loadEntries();
    for (WorkEntry entry in entries) {
      bool hasChanged = false;
      WorkEntry newEntry = entry.copyWith();
      if (entry.uuid.isEmpty) {
        hasChanged = true;
        newEntry = newEntry.copyWith(uuid: WorkEntry.generateUuid());
      }
      if (entry.lastEdit == dateTimeEpoch()) {
        hasChanged = true;
        newEntry.lastEdit = entry.startTime ?? entry.endTime ?? entry.date;
      }
      if (hasChanged) {
        newEntry.lastEdit = DateTime.now().toUtc();
        await storage.workEntries.updateEntry(newEntry, entry);
      }
    }
  }
}
