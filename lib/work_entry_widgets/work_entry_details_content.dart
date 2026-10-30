import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/format_duration.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import 'work_entry_widget.dart';

class WorkEntryDetailsContent extends StatelessWidget {
  final WorkEntry workEntry;

  const WorkEntryDetailsContent({super.key, required this.workEntry});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? loc = AppLocalizations.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatDuration(workEntry.workDuration),
          style: textTheme.headlineSmall,
        ),
        if (workEntry.startTime != null && workEntry.endTime != null)
          Text('${formatTime(workEntry.startTime!)} - ${formatTime(workEntry.endTime!)}'),
        Text(WorkEntryWidget.formattedDate(workEntry, loc)),
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
        if (workEntry.description != null && workEntry.description!.isNotEmpty) ...[
          SizedBox(height: 8),
          Text('${loc?.description}: ${workEntry.description}'),
        ],
      ],
    );
  }
}
