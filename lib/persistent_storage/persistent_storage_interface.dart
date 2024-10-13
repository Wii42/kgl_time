import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/data_model/work_category.dart';

import '../data_model/isar_storable.dart';

abstract class PersistentStorage {
  /// Initializes the persistent storage service.
  ///
  /// Must be called before any other method, otherwise they will throw an exception.
  Future<void> initialize();

  Table<WorkEntry> get workEntries;
  Table<WorkCategory> get workCategories;

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
