import 'dart:async';

import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/data_model/work_entry.dart';

import 'memory_storage.dart';

/// Lets restore tests hold or fail category persistence independently of entry writes.
class ControlledBackupStorage extends MemoryStorage {
  final ControlledCategoryTable _categories = ControlledCategoryTable();
  bool acceptReplacement = true;
  int replacementCalls = 0;

  @override
  ControlledCategoryTable get workCategories => _categories;

  @override
  Future<bool> replaceWorkData({
    required List<WorkEntry> entries,
    required List<WorkCategory> categories,
    List<String> keysToRemove = const <String>[],
  }) async {
    replacementCalls++;
    final Completer<void>? barrier = workCategories.writeBarrier;
    if (barrier != null) await barrier.future;
    if (workCategories.failWrites) throw StateError('Injected category write failure');
    if (!acceptReplacement) return false;
    return super.replaceWorkData(
      entries: entries,
      categories: categories,
      keysToRemove: keysToRemove,
    );
  }
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
