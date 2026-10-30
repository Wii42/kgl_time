import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../data_model/work_entries.dart';
import 'work_entry_details_content.dart';
import 'work_entry_widget.dart';

class WorkEntryDetails extends WorkEntryWidget {
  const WorkEntryDetails({super.key, required super.workEntry});

  @override
  final Axis rightSideButtonsAxis = Axis.vertical;

  @override
  Widget details(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: workEntry.tickedOff,
          onChanged: (_) {
            WorkEntries entriesList = context.read<WorkEntries>();
            entriesList.updateEntry(workEntry, workEntry..tickedOff = !workEntry.tickedOff);
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
          child: WorkEntryDetailsContent(workEntry: workEntry),
        ),
      ],
    );
  }
}
