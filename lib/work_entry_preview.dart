import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kgl_time/work_entry.dart';

class WorkEntryPreview extends StatelessWidget {
  final WorkEntry workEntry;

  const WorkEntryPreview({super.key, required this.workEntry});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDuration(workEntry.workDuration),
                  style: textTheme.headlineSmall,
                ),
                Text(DateFormat('dd.MM.yyyy').format(workEntry.date)),
              ],
            ),
            Row(
              children: [
                IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
                SizedBox(width: 12),
                IconButton(onPressed: () {}, icon: Icon(Icons.delete))
              ],
            )
          ],
        ),
      ),
    );
  }

  String formatDuration(Duration duration) {
    List<String> parts = [];
    if (duration.inHours > 0) {
      parts.add('${duration.inHours}h');
    }
    if (duration.inMinutes.remainder(60) > 0) {
      parts.add('${duration.inMinutes.remainder(60)} min');
    }
    return parts.join(' ');
  }
}
