import 'package:flutter/foundation.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_interface.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';

class KeyValues extends ChangeNotifier {
  final KeyValueStorage storedEntries =
      PersistentStorageService.instance.keyValueStorage;
  late final Map<String, dynamic> _entries;

  KeyValues(Map<String, dynamic> entries) {
    _entries = Map.from(entries);
    notifyListeners();
  }

  /// Sets [value] to [key]
  ///
  /// If the [key] already exists then the previous [value] is replaced
  void set<T>(String key, T value) {
    storedEntries.set(key, value);
    _entries[key] = value;
    notifyListeners();
  }

  /// Gets the value associated with [key]
  ///
  /// Returns null if none is found
  /// Throws a type error of the value is not of type [T]
  T? get<T>(String key) {
    dynamic value = _entries[key];
    if (value is T || value == null) {
      return value;
    } else {
      throw TypeError();
    }
  }

  /// Removes a value associated with [key]
  void remove(String key) {
    storedEntries.remove(key);
    _entries.remove(key);
    notifyListeners();
  }

  /// Removes a all keys and values
  void clear() {
    storedEntries.clear();
    _entries.clear();
    notifyListeners();
  }
}
