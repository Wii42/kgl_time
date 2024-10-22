import 'package:flutter/material.dart';

import '../format_duration.dart';
import 'work_entry_widget.dart';

class WorkEntryPreview extends WorkEntryWidget {
  @override
  final Axis rightSideButtonsAxis = Axis.horizontal;

  const WorkEntryPreview({super.key, required super.workEntry});

  @override
  Widget details(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatDuration(workEntry.workDuration),
          style: textTheme.headlineSmall,
        ),
        Text(formattedDate()),
      ],
    );
  }
}