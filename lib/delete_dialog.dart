import 'package:flutter/material.dart';
/// Shows a dialog to confirm the deletion of an entry.
/// [onDelete] is called when the user confirms the deletion.
void showDeleteConfirmationDialog(
    {required BuildContext context, required void Function()? onDelete, String detailText = 'Wollen Sie diesen Eintrag wirklich löschen?'}) {
  ThemeData theme = Theme.of(context);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Löschen bestätigen'),
        content: Text(detailText),
        actions: <Widget>[
          TextButton(
            child: Text('Abbrechen'),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
          ),
          TextButton(
            onPressed: (){
              Navigator.of(context).pop();
              onDelete?.call();
            },
            child: Text(
              'Löschen',
              style: TextStyle(
                  color:
                      theme.colorScheme.error), // Highlight the Delete button
            ),
          ),
        ],
      );
    },
  );
}
