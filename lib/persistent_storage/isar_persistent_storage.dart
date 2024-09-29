import 'dart:io';

import 'package:isar/isar.dart';
import 'package:kgl_time/work_entry.dart';
import 'package:path_provider/path_provider.dart';

import 'persistent_storage_interface.dart';

class IsarPersistentStorage implements PersistentStorage {
  late final Isar isar;
  late final Directory dir;
  @override
  Future<void> addEntry(WorkEntry entry) async {
    await isar.workEntrys.put(entry);
    return;
  }

  @override
  Future<void> close() async {
    await isar.close();
    return;
  }

  @override
  Future<void> deleteAllEntries() {
    return isar.clear();
  }

  @override
  Future<void> deleteEntry(WorkEntry entry) async {
    await isar.workEntrys.delete(entry.id);
  }

  @override
  Future<void> initialize() async {
    dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([WorkEntrySchema], directory: dir.path);
  }

  @override
  Future<List<WorkEntry>> loadEntries() {
    return isar.workEntrys.where().findAll();
  }

  @override
  Future<void> saveEntries(List<WorkEntry> entries) {
    return isar.workEntrys.putAll(entries);
  }

  @override
  Future<void> updateEntry(WorkEntry newEntry, WorkEntry oldEntry) async {
    if (oldEntry.id != newEntry.id) {
      isar.workEntrys.delete(oldEntry.id);
    }
    await isar.workEntrys.put(newEntry);
    return;
  }
}