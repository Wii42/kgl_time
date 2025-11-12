import 'package:flutter/material.dart';
import 'package:kgl_time/export_import/work_data.dart';
import 'package:provider/provider.dart';

import '../data_model/work_categories.dart';
import '../data_model/work_entries.dart';
import '../format_duration.dart';
import '../l10n/generated/app_localizations.dart';
import '../main.dart';
import 'import_service.dart';

class ImportReplaceConfirmationDialog extends StatelessWidget {
  const ImportReplaceConfirmationDialog({super.key, required this.loadedData});

  final WorkData loadedData;

  @override
  Widget build(BuildContext context) {
    ImportService importService = ImportService();
    ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    AppLocalizations? loc = AppLocalizations.of(context);
    return AlertDialog(
      title: Text("<Import Data>"),
      content: dialogContent(loc),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc?.cancel ?? "<Cancel>"),
        ),
        TextButton(
          child: Text("<Import and Replace>"),
          onPressed: () {
            WorkEntries entriesList = context.read<WorkEntries>();
            WorkCategories categoriesList = context.read<WorkCategories>();
            VoidCallback revertImport = importService.importAndReplace(
              loadedData,
              entriesList,
              categoriesList,
            );
            Navigator.of(context).pop();
            messenger.showSnackBar(
              SnackBar(
                content: Text("<Import successful.>"),
                action: SnackBarAction(
                  label: "rückgängig",
                  onPressed: revertImport,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Column dialogContent(AppLocalizations? loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Date of backup: ${formatDate(loadedData.exportedAt, loc)}, ${formatTime(loadedData.exportedAt)}",
        ),
        Text(
          "Work entries: ${loadedData.workEntries.length}, categories: ${loadedData.workCategories.length}",
        ),
        if (loadedData.schemaVersion > schemaVersion) ...[
          SizedBox(height: 12),
          Text(
            "<Warning: The backup was created with a newer version of the app (schema version ${loadedData.schemaVersion}) than the current app version (schema version $schemaVersion). Importing the data may lead to loss of information or app instability. Proceed with caution.>",
          ),
        ],
        SizedBox(height: 12),
        Text(
          "<Are you sure you want to import the data from the selected file? This will delete all your current entries and categories and replace with the backup.>",
        ),
      ],
    );
  }
}
