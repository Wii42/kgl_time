import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/data_model/work_category.dart';

import 'persistent_storage_interface.dart';

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
  Future<void> close() {
    _checkHasImplementation();
    return _implementation!.close();
  }

  @override
  Future<void> initialize() {
    _checkHasImplementation();
    return _implementation!.initialize();
  }

  void _checkHasImplementation() {
    if (_implementation == null) {
      throw StateError(
          'No PersistentStorage implementation provided for PersistentStorageService');
    }
  }

  @override
  Table<WorkCategory> get workCategories {
    _checkHasImplementation();
    return _implementation!.workCategories;
  }

  @override
  Table<WorkEntry> get workEntries {
    _checkHasImplementation();
    return _implementation!.workEntries;
  }
}
