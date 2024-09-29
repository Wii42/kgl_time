import 'package:flutter/foundation.dart';

import 'work_entry.dart';
import 'package:notifying_list/notifying_list.dart';

class WorkEntries extends ChangeNotifier {
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
  }

  void remove(WorkEntry entry) {
    _entries.remove(entry);
  }

  void updateEntry(WorkEntry workEntry, WorkEntry newEntry) {
    int index = _entries.indexOf(workEntry);
    _entries[index] = newEntry;
    sortEntriesInReverse(_entries);
  }
}
