import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/app/app_initialization.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'support/memory_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MemoryStorage storage;

  setUp(() async {
    storage = MemoryStorage();
    PersistentStorageService.setImplementation(storage);
    PackageInfo.setMockInitialValues(
      appName: 'Test',
      packageName: 'test',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    await storage.keyValueStorage.set<bool>('isFirstRun', false);
    await storage.keyValueStorage.set<int>('schemaVersion', 1);
    await storage.workCategories.saveEntries([
      WorkCategory('Office', uuid: '', lastEdit: null, listIndex: 0)..id = 7,
    ]);
    // Legacy entries and their embedded categories do not yet have UUIDs.
    await storage.workEntries.saveEntries([
      for (final int id in <int>[42, 43])
        WorkEntry(
          uuid: '',
          workDurationInSeconds: 1800,
          date: DateTime.utc(2020),
          lastEdit: DateTime.utc(2020),
          categories: [EmbeddedWorkCategory(displayName: 'Office', id: 7)],
          wasMovedToTrashAt: id == 43 ? DateTime.utc(2020, 1, 2) : null,
        )..id = id,
    ]);
  });

  tearDown(() async => storage.close());

  test('startup returns the persisted migrated entry UUIDs', () async {
    final InitialAppData data = await initializeApp(storage: storage);
    final List<WorkEntry> savedEntries = await storage.workEntries.loadEntries();

    expect(data.entries, hasLength(2));
    expect(savedEntries, hasLength(2));
    for (final WorkEntry saved in savedEntries) {
      expect(saved.uuid, isNotEmpty);
      final WorkEntry initial = data.entries.singleWhere(
        (WorkEntry entry) => entry.id == saved.id,
      );
      expect(initial.uuid, saved.uuid, reason: 'Entry ${saved.id} must use its migrated UUID');
    }
  });

  test(
    'migration links embedded categories to their category UUID in active and trashed entries',
    () async {
      await SchemaMigration1to2().migrate(PersistentStorageService.instance);
      final WorkCategory category = (await storage.workCategories.loadEntries()).single;
      final List<WorkEntry> entries = await storage.workEntries.loadEntries();

      expect(category.uuid, isNotEmpty);
      expect(entries, hasLength(2));
      expect(entries.any((WorkEntry entry) => entry.isInTrash), isTrue);
      for (final WorkEntry entry in entries) {
        expect(
          entry.categories.single.uuid,
          category.uuid,
          reason: 'Entry ${entry.id} must reference the migrated Office category',
        );
      }
    },
  );
}
