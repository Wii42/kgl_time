import 'dart:developer';

import 'package:intl/date_symbol_data_local.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/format_duration.dart';
import 'package:kgl_time/l10n/app_locales.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/main.dart' show schemaVersion;
import 'package:kgl_time/persistent_storage/persistent_storage_interface.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

typedef InitialAppData = ({
  PackageInfo appInfo,
  List<WorkEntry> entries,
  List<WorkCategory> categories,
  Map<String, dynamic> keyValues,
});

List<WorkCategory> createInitialCategories(AppLocalizations loc) => [
  WorkCategory(
    loc.defaultCategoryPlanning,
    listIndex: 0,
    lastEdit: DateTime.timestamp(),
    uuid: WorkEntry.generateUuid(),
  ),
  WorkCategory(
    loc.defaultCategoryMeetings,
    listIndex: 1,
    lastEdit: DateTime.timestamp(),
    uuid: WorkEntry.generateUuid(),
  ),
  WorkCategory(
    loc.defaultCategoryAdministration,
    listIndex: 2,
    lastEdit: DateTime.timestamp(),
    uuid: WorkEntry.generateUuid(),
  ),
];

Future<InitialAppData> initializeApp({required PersistentStorage storage}) async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  await PersistentStorageService.initializeImplementation(storage);
  final PersistentStorageService storageService = PersistentStorageService.instance;
  final List<WorkEntry> initialEntries = await storageService.workEntries.loadEntries();
  final List<WorkCategory> initialCategories = await storageService.workCategories.loadEntries();

  final Map<String, dynamic> initialKeyValueStorage = await storageService.keyValueStorage.getAll();
  final bool isFirstRun = initialKeyValueStorage['isFirstRun'] ?? true;
  if (isFirstRun) {
    final Locale locale = basicLocaleListResolution(
      WidgetsBinding.instance.platformDispatcher.locales,
      supportedAppLocales,
    );
    final AppLocalizations loc = await AppLocalizations.delegate.load(locale);
    final List<WorkCategory> categories = createInitialCategories(loc);
    await storageService.workCategories.saveEntries(categories);
    initialCategories.addAll(categories);
    // Set isFirstRun to false in storage for future runs, but the in memory value is not updated,
    // so that other part of the app still get the notification that it is the first run.
    await storageService.keyValueStorage.set('isFirstRun', false);
    initialKeyValueStorage['isFirstRun'] = true;
  }
  await initializeDateFormatting(); // initialize the date formatting for German
  await _checkSchemaVersion([SchemaMigration1to2()]);

  return (
    appInfo: packageInfo,
    entries: initialEntries,
    categories: initialCategories,
    keyValues: initialKeyValueStorage,
  );
}

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
        newEntry.lastEdit = DateTime.timestamp();
        await storage.workEntries.updateEntry(newEntry, entry);
      }
    }
    List<WorkCategory> categories = await storage.workCategories.loadEntries();
    for (WorkCategory category in categories) {
      bool hasChanged = false;
      if (category.uuid.isEmpty) {
        hasChanged = true;
        category.uuid = WorkEntry.generateUuid();
      }
      if (category.lastEdit == dateTimeEpoch() || category.lastEdit == null) {
        hasChanged = true;
        category.lastEdit = DateTime.timestamp();
      }
      if (hasChanged) {
        category.lastEdit = DateTime.timestamp();
        await storage.workCategories.updateEntry(category, category);
      }
    }
  }
}
