import 'package:kgl_time/work_entry.dart';

abstract class PersistentStorage {
  /// Initializes the persistent storage service.
  Future<void> initialize();

  /// Gets all work entries from the persistent storage.
  Future<List<WorkEntry>> loadEntries();

  /// Saves the given work entries to the persistent storage.
  Future<void> saveEntries(List<WorkEntry> entries);

  /// Adds a new work entry to the persistent storage.
  Future<void> addEntry(WorkEntry entry);

  /// Updates an existing work entry in the persistent storage.
  Future<void> updateEntry(WorkEntry newEntry, WorkEntry oldEntry);

  /// Deletes the given work entry from the persistent storage.
  Future<void> deleteEntry(WorkEntry entry);

  /// Deletes all work entries from the persistent storage.
  Future<void> deleteAllEntries();

  /// Closes the persistent storage service.
  ///
  /// PersistentStorageService should not be used after calling this method,
  /// without calling [initialize] again.
  Future<void> close();
}
