import 'package:flutter/material.dart';
import 'package:kgl_time/data_model/key_values.dart';
import 'package:kgl_time/data_model/work_entries.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:provider/provider.dart';

class WorkEntryTimeTracker extends StatelessWidget {
  static const String _storageKey = 'timeTrackerStart';

  const WorkEntryTimeTracker({super.key});
  @override
  Widget build(BuildContext context) {
    DateTime? startTime = context.select<KeyValues, DateTime?>(
        (keyValues) => keyValues.get<DateTime?>(_storageKey));
    bool isTracking = startTime != null;
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
              value: isTracking,
              onChanged: (value) {
                KeyValues keyValues = context.read<KeyValues>();
                if (value) {
                  keyValues.set<DateTime>(_storageKey, DateTime.now());
                } else {
                  keyValues.remove(_storageKey);
                  context.read<WorkEntries>().add(WorkEntry.fromStartAndEndTime(
                      startTime: startTime!, endTime: DateTime.now()));
                }
              }),
          Text(isTracking
              ? 'läuft seit ${_trackTime(startTime)}'
              : 'Zeit erfassen'),
        ],
      ),
    );
  }

  String _trackTime(DateTime startTime) {
    int hours = DateTime.now().difference(startTime).inHours;
    int minutes = DateTime.now().difference(startTime).inMinutes %
        Duration.minutesPerHour;
    return [if (hours > 0) "${hours}h", "$minutes min"].join(" ");
  }
}
