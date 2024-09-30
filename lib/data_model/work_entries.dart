import 'package:flutter/foundation.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';
import 'package:notifying_list/notifying_list.dart';

import 'work_entry.dart';

class WorkEntries extends ChangeNotifier {
  final PersistentStorageService storage =
      PersistentStorageService.instance;
  late final CallbackNotifyingList<WorkEntry> _entries;

  WorkEntries(List<WorkEntry> entriesList) {
    entriesList = List.from(entriesList);
    sortEntriesInReverse(entriesList);
    _entries = CallbackNotifyingList<WorkEntry>(notifyListeners);
    _entries.addAll(entriesList);
  }

  void sortEntriesInReverse(List<WorkEntry> entriesList) {
    entriesList.sort((a, b) {
      DateTime aDate = a.startTime ?? a.endTime ?? a.date;
      DateTime bDate = b.startTime ?? b.endTime ?? b.date;
      return -aDate.compareTo(bDate);
    });
  }

  List<WorkEntry> get entries => List.unmodifiable(_entries);

  void add(WorkEntry entry) {
    _entries.add(entry);
    sortEntriesInReverse(_entries);
    storage.addEntry(entry);
  }

  void remove(WorkEntry entry) {
    _entries.remove(entry);
    storage.deleteEntry(entry);
  }

  void updateEntry(WorkEntry workEntry, WorkEntry newEntry) {
    int index = _entries.indexOf(workEntry);
    _entries[index] = newEntry;
    sortEntriesInReverse(_entries);
    storage.updateEntry(newEntry, workEntry);
  }
}
