import 'package:flutter/material.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/original_text_theme.dart';

/// Shows a dialog to confirm the deletion of an entry.
/// [onDelete] is called when the user confirms the deletion.
void showDeleteConfirmationDialog(
    {required BuildContext context,
    required void Function()? onDelete,
    String? Function(AppLocalizations? loc) detailText =
        defaultConfirmDeleteText}) {
  AppLocalizations? loc = AppLocalizations.of(context);
  ThemeData theme = Theme.of(context);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Theme(
        data: theme.copyWith(
            textTheme: theme.extension<OriginalTextTheme>()?.textTheme ??
                theme.textTheme),
        child: AlertDialog(
          title: Text(loc?.confirmDelete ?? '<confirmDelete>'),
          content: Text(detailText(loc) ?? '<explanationText>'),
          actions: <Widget>[
            TextButton(
              child: Text(loc?.cancel ?? '<cancel>'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete?.call();
              },
              child: Text(
                loc?.delete ?? '<delete>',
                style: TextStyle(
                    color:
                        theme.colorScheme.error), // Highlight the Delete button
              ),
            ),
          ],
        ),
      );
    },
  );
}

String? defaultConfirmDeleteText(AppLocalizations? loc) =>
    loc?.confirmDeleteDialog;
