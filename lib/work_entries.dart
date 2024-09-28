import 'package:flutter/foundation.dart';

import 'work_entry.dart';
import 'package:notifying_list/notifying_list.dart';

class WorkEntries extends ChangeNotifier {
  late final CallbackNotifyingList<WorkEntry> entries;

  WorkEntries(List<WorkEntry> entries) {
    entries = List.from(entries);
    entries.sort((a, b) {
      DateTime aDate = a.startTime ?? a.endTime ?? a.date;
      DateTime bDate = b.startTime ?? b.endTime ?? b.date;
      return aDate.compareTo(bDate);
    });
    entries = entries.reversed.toList();
    this.entries = CallbackNotifyingList<WorkEntry>(notifyListeners);
    this.entries.addAll(entries);
  }
}
