import 'package:flutter/material.dart';
import 'package:kgl_time/work_entry_widgets/work_entry_details.dart';
import 'package:kgl_time/work_entry_widgets/work_entry_widget.dart';
import 'package:provider/provider.dart';

import '../data_model/work_entries.dart';
import '../l10n/generated/app_localizations.dart';

class TrashedWorkEntry extends WorkEntryWidget {
  const TrashedWorkEntry({super.key, required super.workEntry});

  @override
  Widget details(BuildContext context) {
    AppLocalizations? loc = AppLocalizations.of(context);
    TextTheme textTheme = Theme.of(context).textTheme;
    return WorkEntryDetails.workEntryDetails(workEntry, textTheme, loc);
  }

  @override
  Axis get rightSideButtonsAxis => Axis.vertical;

  @override
  List<Widget> rightSideButtons(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations? loc = AppLocalizations.of(context);
    return [
      FilledButton(
          onPressed: () {
            WorkEntries entries = context.read<WorkEntries>();
            entries.restoreFromTrashBin(workEntry);
          },
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Icon(Icons.restore_from_trash),
            ),
            Text(
              loc?.restoreEntry ?? "<restore Entry>",
              style: textTheme.labelSmall?.apply(color: Colors.white),
            )
          ])),
    ];
  }
}
