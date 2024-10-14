import 'package:flutter/foundation.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_interface.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';
import 'package:notifying_list/notifying_list.dart';

class WorkCategories extends ChangeNotifier {
  final Table<WorkCategory> storedEntries =
      PersistentStorageService.instance.workCategories;
  late final List<WorkCategory> _entries;

  WorkCategories(List<WorkCategory> entriesList) {
    _entries = List.from(entriesList);
    _entries.sort((a, b) => a.listIndex.compareTo(b.listIndex));
    notifyListeners();
  }

  List<WorkCategory> get entries => List.unmodifiable(_entries);

  void add(WorkCategory entry, {int? index}) {
    if (index != null) {
      _entries.insert(index, entry);
      _recalculateListIndices();
      storedEntries.deleteAllEntries();
      storedEntries.saveEntries(_entries);
    } else {
      entry.listIndex = _entries.length;
      _entries.add(entry);
      storedEntries.addEntry(entry);
    }
    notifyListeners();
  }

  void remove(WorkCategory entry) {
    _entries.remove(entry);
    storedEntries.deleteEntry(entry);
    notifyListeners();
  }

  void updateEntry(WorkCategory workEntry, WorkCategory newEntry) {
    int index = _entries.indexOf(workEntry);
    _entries[index] = newEntry;
    storedEntries.updateEntry(newEntry, workEntry);
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    _reorderEntries(oldIndex, newIndex);
    _recalculateListIndices();
    storedEntries.deleteAllEntries();
    storedEntries.saveEntries(_entries);
    notifyListeners();
  }

  void _reorderEntries(int oldIndex, int newIndex) {
    WorkCategory entry = _entries[oldIndex];
    _entries.insert(newIndex, entry);
    _entries.removeAt(oldIndex + (oldIndex < newIndex ? 0 : 1));
  }

  void _recalculateListIndices() {
    for (int i = 0; i < _entries.length; i++) {
      _entries[i].listIndex = i;
    }
  }
}
