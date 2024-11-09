import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_interface.dart';

import '../data_model/isar_storable.dart';

class TempStorage implements PersistentStorage {
  @override
  Future<void> close() => Future.value();

  @override
  Future<void> initialize() => Future.value();

  @override
  KeyValueStorage keyValueStorage = KeyValueTempStorage();

  @override
  Table<WorkCategory> workCategories = TempTable<WorkCategory>();

  @override
  Table<WorkEntry> workEntries = TempTable<WorkEntry>();
}

class KeyValueTempStorage implements KeyValueStorage {
  final Map<String, dynamic> _storage = {};

  @override
  Future<void> clear() {
    _storage.clear();
    return Future.value();
  }

  @override
  Future<T?> get<T>(String key) {
    return Future.value(_storage[key] as T?);
  }

  @override
  Future<Map<String, T>> getAll<T>() {
    return Future.value(_storage as Map<String, T>);
  }

  @override
  Future<T?> getById<T>(int id) {
    return Future.value(_storage.values.indexed
        .firstWhere((element) => element.$1 == id) as T?);
  }

  @override
  Future<bool> remove(String key) {
    return Future.value(_storage.remove(key) != null);
  }

  @override
  Future<bool> removeById(int id) async {
    dynamic value = await getById(id);
    if (value == null) return false;
    return _storage.remove(value) != null;
  }

  @override
  Future<int> set<T>(String key, T value) {
    _storage[key] = value;
    return Future.value(
        _storage.keys.indexed.firstWhere((element) => element.$2 == key).$1);
  }
}

class TempTable<T extends IsarStorable> extends Table<T> {
  final List<T> _table = [];
  @override
  Future<void> addEntry(T entry) {
    _table.add(entry);
    return Future.value();
  }

  @override
  Future<void> deleteAllEntries() {
    _table.clear();
    return Future.value();
  }

  @override
  Future<void> deleteEntry(T entry) {
    _table.remove(entry);
    return Future.value();
  }

  @override
  Future<List<T>> loadEntries() {
    return Future.value(_table);
  }

  @override
  Future<void> saveEntries(List<T> entries) {
    _table.addAll(entries);
    return Future.value();
  }

  @override
  Future<void> updateEntry(T newEntry, T oldEntry) {
    _table.remove(oldEntry);
    _table.add(newEntry);
    return Future.value();
  }
}
