import 'package:flutter/foundation.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_interface.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';
import 'package:notifying_list/notifying_list.dart';

class WorkCategories extends ChangeNotifier {
  final Table<WorkCategory> storedEntries =
      PersistentStorageService.instance.workCategories;
  late final CallbackNotifyingList<IWorkCategory> _entries;

  WorkCategories(List<IWorkCategory> entriesList) {
    entriesList = List.from(entriesList);
    _entries = CallbackNotifyingList<IWorkCategory>(notifyListeners);
    _entries.addAll(entriesList);
  }

  List<WorkCategory> get entries => List.unmodifiable(_entries);

  void add(WorkCategory entry) {
    _entries.add(entry);
    storedEntries.addEntry(entry);
  }

  void remove(WorkCategory entry) {
    _entries.remove(entry);
    storedEntries.deleteEntry(entry);
  }

  void updateEntry(WorkCategory workEntry, WorkCategory newEntry) {
    int index = _entries.indexOf(workEntry);
    _entries[index] = newEntry;
    storedEntries.updateEntry(newEntry, workEntry);
  }
}
