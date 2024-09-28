import 'package:flutter/foundation.dart';

import 'work_entry.dart';
import 'package:notifying_list/notifying_list.dart';

class WorkEntries extends ChangeNotifier {
  late final CallbackNotifyingList<WorkEntry> entries;

  WorkEntries(List<WorkEntry> entries) {
    entries = CallbackNotifyingList<WorkEntry>(notifyListeners);
  }
}
