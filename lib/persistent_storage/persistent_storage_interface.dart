import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/data_model/work_entry.dart';

import '../data_model/isar_storable.dart';

abstract class PersistentStorage {
  /// Initializes the persistent storage service.
  ///
  /// Must be called before any other method, otherwise they will throw an exception.
  Future<void> initialize();

  Table<WorkEntry> get workEntries;

  Table<WorkCategory> get workCategories;

  KeyValueStorage get keyValueStorage;

  /// Closes the persistent storage service.
  ///
  /// PersistentStorageService should not be used after calling this method,
  /// without calling [initialize] again.
  Future<void> close();
}

abstract class Table<T extends IsarStorable> {
  /// Gets all entries from the persistent storage.
  Future<List<T>> loadEntries();

  /// Saves the given entries to the persistent storage.
  Future<void> saveEntries(List<T> entries);

  /// Adds a new entry to the persistent storage.
  Future<void> addEntry(T entry);

  /// Updates an existing work entry in the persistent storage.
  Future<void> updateEntry(T newEntry, T oldEntry);

  /// Deletes the given work entry from the persistent storage.
  Future<void> deleteEntry(T entry);

  /// Deletes all work entries from the persistent storage.
  Future<void> deleteAllEntries();
}

/// A key value storage interface
///
/// Supports storing and retrieving values by a key.
/// Following values are supported:
/// - String
/// - int
/// - double
/// - bool
/// - DateTime
abstract class KeyValueStorage {
  /// Sets [value] to [key]
  ///
  /// If the [key] already exists then the previous [value] is replaced
  /// Return the index of the new entry, that can be used to access this value
  /// in addition to the [key]
  Future<int> set<T>(String key, T value);

  /// Gets the value associated with [key]
  ///
  /// Returns null if none is found
  /// Throws a type error of the value is not of type [T]
  Future<T?> get<T>(String key);

  /// Gets the value associated with [id]
  ///
  /// Returns null if none is found
  /// Throws a type error of the value is not of type [T]
  Future<T?> getById<T>(int id);

  /// Removes a value associated with [key]
  ///
  /// Returns true if a value is removed
  /// Returns false if value is not removed
  Future<bool> remove(String key);

  /// Removes a value associated with [id]
  ///
  /// Returns true if a value is removed
  /// Returns false if value is not removed
  Future<bool> removeById(int id);

  /// Removes a all keys and values from this instance and the underlying
  /// isar database
  Future<void> clear();

  /// Gets all key value pairs
  ///
  /// Throws a type error if one of the values is not of type [T]
  Future<Map<String, T>> getAll<T>();
}
