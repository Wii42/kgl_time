import 'dart:io';

import 'package:isar/isar.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:path_provider/path_provider.dart';

import '../data_model/isar_storable.dart';
import 'persistent_storage_interface.dart';

class IsarPersistentStorage implements PersistentStorage {
  late final Isar isar;
  late final Directory dir;

  @override
  Future<void> close() async {
    await isar.close();
    return;
  }

  @override
  Future<void> initialize() async {
    dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([WorkEntrySchema, WorkCategorySchema], directory: dir.path);
    workEntries = IsarTable<WorkEntry>(isar, isar.workEntries);
    workCategories = IsarTable<WorkCategory>(isar, isar.workCategories);
  }

  @override
  late final Table<WorkCategory> workCategories;
  @override
  late final Table<WorkEntry> workEntries;
}

class IsarTable<T extends IsarStorable> implements Table<T> {
  late final Isar isar;
  late final Directory dir;
  late final IsarCollection<T> collection;

  IsarTable(this.isar, this.collection);

  @override
  Future<void> addEntry(T entry) async {
    await isar.writeTxn(() async {
      await collection.put(entry);
    });
    return;
  }

  @override
  Future<void> deleteAllEntries() {
    return isar.writeTxn(() async {
      await collection.clear();
    });
  }

  @override
  Future<void> deleteEntry(T entry) async {
    await isar.writeTxn(() async {
      await collection.delete(entry.id);
    });
    return;
  }

  @override
  Future<List<T>> loadEntries() {
    return isar.txn(() async {
      return collection.where().findAll();
    });
  }

  @override
  Future<void> saveEntries(List<T> entries) {
    return isar.writeTxn(() async {
      await collection.putAll(entries);
    });
  }

  @override
  Future<void> updateEntry(T newEntry, T oldEntry) async {
    await isar.writeTxn(() async {
      await collection.put(newEntry);
    });
    return;
  }
}
