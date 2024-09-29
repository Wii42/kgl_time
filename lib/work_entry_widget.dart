import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kgl_time/format_duration.dart';
import 'package:kgl_time/work_entries.dart';
import 'package:kgl_time/work_entry.dart';
import 'package:provider/provider.dart';

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
            Expanded(child: details(context)),
            switch (rightSideButtonsAxis) {
              Axis.horizontal => Row(children: rightSideButtons(context)),
              Axis.vertical => Column(children: rightSideButtons(context)),
            },
          ],
        ),
      ),
    );
  }

  String formattedDate() => formatDate(workEntry.date);

  List<Widget> rightSideButtons(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            context.go('/newEntry', extra: workEntry);
          },
          icon: Icon(Icons.edit)),
      SizedBox(width: 12),
      IconButton(
          onPressed: () {
            _showDeleteConfirmationDialog(context);
          },
          icon: Icon(Icons.delete))
    ];
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Löschen bestätigen'),
          content: Text('Wollen Sie diesen Eintrag wirklich löschen?'),
          actions: <Widget>[
            TextButton(
              child: Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: Text(
                'Löschen',
                style:
                    TextStyle(color: Colors.red), // Highlight the Delete button
              ),
              onPressed: () {
                Navigator.of(context).pop();
                WorkEntries workEntries =
                    context.read<WorkEntries>(); // Close the dialog
                _deleteItem(workEntries); // Call the delete function
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(WorkEntries workEntries) {
    workEntries.remove(workEntry);
    print('Item deleted');
  }
}
