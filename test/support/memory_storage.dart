import 'package:kgl_time/data_model/isar_storable.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_interface.dart';

/// Test storage with no platform plugins or filesystem access.
class MemoryStorage implements PersistentStorage {
  @override
  final workEntries = MemoryTable<WorkEntry>();
  @override
  final workCategories = MemoryTable<WorkCategory>();
  @override
  final keyValueStorage = MemoryKeyValues();

  @override
  Future<void> initialize() async {}
  @override
  Future<void> close() async {}
}

class MemoryTable<T extends IsarStorable> implements Table<T> {
  final List<T> _entries = [];
  int _nextId = 1;

  @override
  Future<List<T>> loadEntries() async => List.of(_entries);
  @override
  Future<void> addEntry(T entry) async {
    // Fixtures can have explicit IDs; newly created entries use Isar.autoIncrement.
    if (entry.id < 0) {
      if (entry is WorkEntry) {
        entry.id = _nextId++;
      } else if (entry is WorkCategory) {
        entry.id = _nextId++;
      } else {
        throw UnsupportedError('No test ID allocator for ${entry.runtimeType}');
      }
    }
    if (entry.id >= _nextId) _nextId = entry.id + 1;
    _entries.removeWhere((e) => e.id == entry.id);
    _entries.add(entry);
  }

  @override
  Future<void> saveEntries(List<T> entries) async {
    for (final entry in entries) {
      await addEntry(entry);
    }
  }

  @override
  Future<void> updateEntry(T newEntry, T oldEntry) async {
    _entries.removeWhere((e) => e.id == oldEntry.id);
    await addEntry(newEntry);
  }

  @override
  Future<void> deleteEntry(T entry) async {
    _entries.removeWhere((e) => e.id == entry.id);
  }

  @override
  Future<void> deleteAllEntries() async => _entries.clear();
}

class MemoryKeyValues extends KeyValueStorage {
  final Map<String, dynamic> _values = {};
  final Map<String, int> _ids = {};
  int _nextId = 1;

  @override
  Future<int> set<T>(String key, T value) async {
    _values[key] = value;
    return _ids.putIfAbsent(key, () => _nextId++);
  }

  @override
  Future<T?> get<T>(String key) async => _values[key] as T?;
  @override
  Future<T?> getById<T>(int id) async {
    for (final entry in _ids.entries) {
      if (entry.value == id) return _values[entry.key] as T?;
    }
    return null;
  }

  @override
  Future<bool> remove(String key) async {
    final existed = _values.containsKey(key);
    _values.remove(key);
    _ids.remove(key);
    return existed;
  }

  @override
  Future<bool> removeById(int id) async {
    for (final entry in _ids.entries) {
      if (entry.value == id) return remove(entry.key);
    }
    return false;
  }

  @override
  Future<void> clear() async {
    _values.clear();
    _ids.clear();
  }

  @override
  Future<Map<String, T>> getAll<T>() async => _values.cast<String, T>();
}
