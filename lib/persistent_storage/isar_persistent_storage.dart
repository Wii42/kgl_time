import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:path_provider/path_provider.dart';

import '../data_model/isar_storable.dart';
import '../data_model/key_value.dart';
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
    isar = await Isar.open(
        [WorkEntrySchema, WorkCategorySchema, KeyValueSchema],
        directory: dir.path);
    workEntries = IsarTable<WorkEntry>(isar, isar.workEntries);
    workCategories = IsarTable<WorkCategory>(isar, isar.workCategories);
    keyValueStorage = IsarKeyValue(isar);
  }

  @override
  late final Table<WorkCategory> workCategories;
  @override
  late final Table<WorkEntry> workEntries;
  @override
  late final KeyValueStorage keyValueStorage;
}

class IsarTable<T extends IsarStorable> implements Table<T> {
  final Isar isar;
  final IsarCollection<T> collection;

  IsarTable(this.isar, this.collection);

  @override
  Future<void> addEntry(T entry) async {
    return isar.writeTxn(() async {
      await collection.put(entry);
    });
  }

  @override
  Future<void> deleteAllEntries() {
    return isar.writeTxn(() async {
      await collection.clear();
    });
  }

  @override
  Future<void> deleteEntry(T entry) async {
    return isar.writeTxn(() async {
      await collection.delete(entry.id);
    });
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
      if (oldEntry.id != newEntry.id) {
        collection.delete(oldEntry.id);
      }
      await collection.put(newEntry);
    });
    return;
  }
}

/// KeyValueStorage implementation using Isar
///
/// Adapted from [isar_key_value](https://github.com/MohiuddinM/isar_key_value) <br>
/// Original file:
/// [lib/src/isar_key_value.dart at commit c868add](https://github.com/MohiuddinM/isar_key_value/blob/c868add1741511205cee356483154564cbcea3ee/lib/src/isar_key_value.dart)
///
/// Licensed under the MIT License. See the full license below.
///
/// ```
/// MIT License
///
/// Copyright (c) 2023 muha.dev
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.
/// ```
class IsarKeyValue extends KeyValueStorage {
  final Isar isar;

  IsarKeyValue(this.isar);

  @override
  Future<int> set<T>(String key, T value) async {
    final item = KeyValue()..key = key;
    item.value = value;
    return isar.writeTxn(() => isar.keyValues.put(item));
  }

  @override
  Future<T?> get<T>(String key) async {
    final item = await isar.txn(() => isar.keyValues.getByKey(key));
    return item?.value;
  }

  @override
  Future<T?> getById<T>(int id) async {
    final item = await isar.txn(() => isar.keyValues.get(id));
    return item?.value;
  }

  @override
  Future<bool> remove(String key) async {
    return isar.writeTxn(() => isar.keyValues.deleteByKey(key));
  }

  @override
  Future<bool> removeById(int id) async {
    return isar.writeTxn(() => isar.keyValues.delete(id));
  }

  @override
  Future<void> clear() async {
    return isar.writeTxn(() => isar.clear());
  }

  @override
  Future<Map<String, T>> getAll<T>() async {
    final items = await isar.txn(() => isar.keyValues.where().findAll());
    return {for (var item in items) item.key: item.value as T};
  }
}
