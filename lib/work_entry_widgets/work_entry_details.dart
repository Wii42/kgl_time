import 'package:flutter/material.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../data_model/work_entries.dart';
import '../format_duration.dart';
import 'work_entry_widget.dart';

class WorkEntryDetails extends WorkEntryWidget {
  const WorkEntryDetails({super.key, required super.workEntry});

  @override
  final Axis rightSideButtonsAxis = Axis.vertical;

  @override
  Widget details(BuildContext context) {
    AppLocalizations? loc = AppLocalizations.of(context);
    TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Checkbox(
          value: workEntry.tickedOff,
          onChanged: (_) {
            WorkEntries entriesList = context.read<WorkEntries>();
            entriesList.updateEntry(
                workEntry, workEntry..tickedOff = !workEntry.tickedOff);
          },
          shape: CircleBorder(),
          side: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
          visualDensity: VisualDensity.compact,
        ),
        SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatDuration(workEntry.workDuration),
                style: textTheme.headlineSmall,
              ),
              if (workEntry.startTime != null && workEntry.endTime != null)
                Text(
                    '${formatTime(workEntry.startTime!)} - ${formatTime(workEntry.endTime!)}'),
              Text(formattedDate(loc)),
              if (workEntry.categories.isNotEmpty) ...[
                SizedBox(height: 8),
                Wrap(
                  children: [
                    for (IWorkCategory category in workEntry.categories) ...[
                      RawChip(
                        isEnabled: !workEntry.tickedOff,
                        //avatar: category.icon != null? Icon(category.icon): null,
                        padding: EdgeInsets.zero,
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
                Text('${loc?.description}: ${workEntry.description}'),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
