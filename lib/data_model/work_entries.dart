import 'package:flutter/foundation.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_interface.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';
import 'package:notifying_list/notifying_list.dart';

import 'work_entry.dart';

class WorkEntries extends ChangeNotifier {
  final Table<WorkEntry> _storedEntries =
      PersistentStorageService.instance.workEntries;
  late final CallbackNotifyingList<WorkEntry> _entries;

  WorkEntries(List<WorkEntry> entriesList) {
    entriesList = List.from(entriesList);
    sortEntriesInReverse(entriesList);
    _entries = CallbackNotifyingList<WorkEntry>(notifyListeners);
    _entries.addAll(entriesList);
    _removeEntriesInTrashPermanentlyAfter(const Duration(days: 30));
  }

  static void sortEntriesInReverse(List<WorkEntry> entriesList) {
    entriesList.sort((a, b) {
      DateTime aDate = a.startTime ?? a.endTime ?? a.date;
      DateTime bDate = b.startTime ?? b.endTime ?? b.date;
      return -aDate.compareTo(bDate);
    });
    print('Sorted entries in reverse chronological order.');
  }

  /// All entries that are not in the trash
  List<WorkEntry> get entries =>
      List.unmodifiable(_entries.where((entry) => !entry.isInTrash));

  List<WorkEntry> get entriesInTrash =>
      List.unmodifiable(_entries.where((entry) => entry.isInTrash));

  void add(WorkEntry entry) {
    _entries.add(entry);
    sortEntriesInReverse(_entries);
    _storedEntries.addEntry(entry);
  }

  void moveToTrashBin(WorkEntry entry) {
    WorkEntry newEntry = entry.withTrashStatus(DateTime.now(), tickedOff: false);
    updateEntry(entry, newEntry..id = entry.id);
  }

  void restoreFromTrashBin(WorkEntry entry) {
    WorkEntry newEntry = entry.withTrashStatus(null);
    updateEntry(entry, newEntry.. id = entry.id);
  }

  void _removeEntryPermanently(WorkEntry entry) {
    _entries.remove(entry);
    _storedEntries.deleteEntry(entry);
  }

  void _removeEntriesInTrashPermanentlyAfter(Duration duration){
    DateTime cutoffDate = DateTime.now().subtract(duration);
    _removeEntriesInTrashPermanentlyOlderThan(cutoffDate);
  }
  
  void _removeEntriesInTrashPermanentlyOlderThan(DateTime cutoffDate) {
    List<WorkEntry> entriesToRemove = _entries
        .where((entry) =>
            entry.isInTrash &&
            (entry.wasMovedToTrashAt?.isBefore(cutoffDate) ?? false))
        .toList();
    for (var entry in entriesToRemove) {
      _removeEntryPermanently(entry);
      print(
          'Permanently removed work entry with id ${entry.id} from trash bin.');
    }
  }

  void updateEntry(WorkEntry workEntry, WorkEntry newEntry) {
    int index = _entries.indexOf(workEntry);
    _entries[index] = newEntry;
    sortEntriesInReverse(_entries);
    _storedEntries.updateEntry(newEntry, workEntry);
  }
}
