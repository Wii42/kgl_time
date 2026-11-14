import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/data_model/work_categories.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';

import '../support/memory_storage.dart';

void main() {
  late MemoryStorage storage;

  setUp(() {
    storage = MemoryStorage();
    PersistentStorageService.setImplementation(storage);
  });

  tearDown(() async => storage.close());

  test('reordering advances the modification timestamps of categories whose positions change', () {
    final DateTime oldTime = DateTime.utc(2020);
    final WorkCategories categories = WorkCategories([
      WorkCategory('A', uuid: 'a', lastEdit: oldTime, listIndex: 0)..id = 1,
      WorkCategory('B', uuid: 'b', lastEdit: oldTime, listIndex: 1)..id = 2,
    ]);
    addTearDown(categories.dispose);

    categories.reorder(0, 1);

    expect(categories.entries.map((WorkCategory category) => category.uuid), ['b', 'a']);
    for (final WorkCategory category in categories.entries) {
      expect(category.lastEdit, isNotNull);
      expect(
        category.lastEdit!.isAfter(oldTime),
        isTrue,
        reason: 'Category ${category.uuid} changed position and needs updated change metadata',
      );
    }
  });
}
