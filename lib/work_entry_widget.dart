import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kgl_time/work_entry.dart';

import 'format_duration.dart';

abstract class WorkEntryWidget extends StatelessWidget {
  final WorkEntry workEntry;

  Axis get rightSideButtonsAxis;

  const WorkEntryWidget({super.key, required this.workEntry});

  Widget details(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Card(
      //margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            details(context),
            switch (rightSideButtonsAxis) {
              Axis.horizontal => Row(children: rightSideButtons()),
              Axis.vertical => Column(children: rightSideButtons()),
            },
          ],
        ),
      ),
    );
  }

  String formattedDate() => DateFormat('EE dd.MM.yyyy', 'de').format(workEntry.date);

  List<Widget> rightSideButtons() {
    return [
      IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
      SizedBox(width: 12),
      IconButton(onPressed: () {}, icon: Icon(Icons.delete))
    ];
  }
}
