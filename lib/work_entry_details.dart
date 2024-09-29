import 'package:flutter/material.dart';
import 'package:kgl_time/work_entry.dart';
import 'package:kgl_time/work_entry_widget.dart';

import 'format_duration.dart';

class WorkEntryDetails extends WorkEntryWidget {
  const WorkEntryDetails({super.key, required super.workEntry});

  @override
  final Axis rightSideButtonsAxis = Axis.vertical;

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
        if (workEntry.categories.isNotEmpty) ...[
          SizedBox(height: 8),
          Wrap(
            children: [
              for (WorkCategory category in workEntry.categories) ...[
                Chip(
                  label: Text(category.displayName),
                ),
                SizedBox(width: 8),
              ],
            ],
          ),
        ],
        if (workEntry.description != null &&
            workEntry.description!.isNotEmpty) ...[
          SizedBox(height: 8),
          Text('Beschreibung: ${workEntry.description}'),
        ],
      ],
    );
  }
}
