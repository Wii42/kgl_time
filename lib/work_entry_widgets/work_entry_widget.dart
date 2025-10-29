import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kgl_time/data_model/work_entries.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/delete_dialog.dart';
import 'package:kgl_time/format_duration.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../app_route.dart';
import '../original_text_theme.dart';

abstract class WorkEntryWidget extends StatelessWidget {
  final WorkEntry workEntry;

  Axis get rightSideButtonsAxis;

  const WorkEntryWidget({super.key, required this.workEntry});

  Widget details(BuildContext context);

  @override
  Widget build(BuildContext context) {
    ThemeData parentTheme = Theme.of(context);
    return Theme(
      data: workEntry.tickedOff
          ? parentTheme.copyWith(
              textTheme: parentTheme.textTheme
                  .apply(bodyColor: parentTheme.disabledColor),
              extensions: [
                  ...parentTheme.extensions.values,
                  OriginalTextTheme(textTheme: parentTheme.textTheme),
                  // Save original text theme
                ])
          : parentTheme,
      child: Builder(builder: (context) {
        return Card(
          //margin: EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: details(context)),
                switch (rightSideButtonsAxis) {
                  Axis.horizontal => Row(children: rightSideButtons(context)),
                  Axis.vertical => Column(children: rightSideButtons(context)),
                },
              ],
            ),
          ),
        );
      }),
    );
  }

  static String formattedDate(WorkEntry workEntry, AppLocalizations? loc) =>
      formatDate(workEntry.date, loc);

  List<Widget> rightSideButtons(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            context.push(AppRoute.newEntry.path, extra: workEntry);
          },
          icon: Icon(Icons.edit_outlined)),
      SizedBox(width: 12),
      IconButton(
          onPressed: () {
            _showDeleteConfirmationDialog(context);
          },
          icon: Icon(Icons.delete_outline_outlined))
    ];
  }

  void _showDeleteConfirmationDialog(BuildContext context) =>
      showDeleteConfirmationDialog(
          context: context,
          onDelete: () {
            WorkEntries workEntries =
                context.read<WorkEntries>(); // Close the dialog
            _deleteItem(workEntries); // Call the delete function
          });

  void _deleteItem(WorkEntries workEntries) {
    workEntries.moveToTrashBin(workEntry);
  }
}
