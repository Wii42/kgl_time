import 'dart:async';

import 'package:kgl_time/data_model/work_category.dart';

import 'memory_storage.dart';

/// Lets restore tests hold or fail category persistence independently of entry writes.
class ControlledBackupStorage extends MemoryStorage {
  final ControlledCategoryTable _categories = ControlledCategoryTable();

  @override
  ControlledCategoryTable get workCategories => _categories;
}

class ControlledCategoryTable extends MemoryTable<WorkCategory> {
  Completer<void>? writeBarrier;
  bool failWrites = false;

  @override
  Future<void> saveEntries(List<WorkCategory> entries) {
    if (failWrites) throw StateError('Injected category write failure');
    final Completer<void>? barrier = writeBarrier;
    if (barrier == null) return super.saveEntries(entries);
    final List<WorkCategory> snapshot = List<WorkCategory>.of(entries);
    return barrier.future.then((_) => super.saveEntries(snapshot));
  }
}
