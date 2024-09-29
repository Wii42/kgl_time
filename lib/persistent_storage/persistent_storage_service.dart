import 'package:kgl_time/persistent_storage/persistent_storage_interface.dart';
import 'package:kgl_time/work_entry.dart';

/// A service that provides access to a persistent storage for work entries.
///
/// Allows to access the persistent storage globally.
class PersistentStorageService implements PersistentStorage {
  static PersistentStorageService instance =
      PersistentStorageService._internal();

  PersistentStorageService._internal();

  static void setImplementation(PersistentStorage implementation) {
    instance._implementation = implementation;
  }

  static Future<void> initializeImplementation(
      PersistentStorage implementation) {
    setImplementation(implementation);
    return instance.initialize();
  }

  PersistentStorage? _implementation;

  @override
  Future<void> addEntry(WorkEntry entry) {
    _checkHasImplementation();
    return _implementation!.addEntry(entry);
  }

  @override
  Future<void> close() {
    _checkHasImplementation();
    return _implementation!.close();
  }

  @override
  Future<void> deleteAllEntries() {
    _checkHasImplementation();
    return _implementation!.deleteAllEntries();
  }

  @override
  Future<void> deleteEntry(WorkEntry entry) {
    _checkHasImplementation();
    return _implementation!.deleteEntry(entry);
  }

  @override
  Future<void> initialize() {
    _checkHasImplementation();
    return _implementation!.initialize();
  }

  @override
  Future<List<WorkEntry>> loadEntries() {
    _checkHasImplementation();
    return _implementation!.loadEntries();
  }

  @override
  Future<void> saveEntries(List<WorkEntry> entries) {
    _checkHasImplementation();
    return _implementation!.saveEntries(entries);
  }

  @override
  Future<void> updateEntry(WorkEntry newEntry, WorkEntry oldEntry) {
    _checkHasImplementation();
    return _implementation!.updateEntry(newEntry, oldEntry);
  }

  void _checkHasImplementation() {
    if (_implementation == null) {
      throw StateError(
          'No PersistentStorage implementation provided for PersistentStorageService');
    }
  }
}
