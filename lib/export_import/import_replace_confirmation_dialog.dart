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
      title: Text(loc?.importBacupAndReplace ?? "<Import Data>"),
      content: dialogContent(loc),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc?.cancel ?? "<Cancel>"),
        ),
        TextButton(
          child: Text(
            loc?.importBacupAndReplaceExistingEntries ?? "<Import and Replace>",
            textAlign: TextAlign.center,
          ),
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
                content: Text(loc?.importSuccess ?? "<Import successful.>"),
                action: SnackBarAction(
                  label: loc?.undo ?? "<undo>",
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
          loc?.dateOfBackup(
                "${formatDate(loadedData.exportedAt, loc)}, ${formatTime(loadedData.exportedAt)}",
              ) ??
              "<date of backup>",
        ),
        Text(
          loc?.nrOfEntriesAndCategories(
                loadedData.workEntries.length,
                loadedData.workCategories.length,
              ) ??
              "<Number of entries and categories>",
        ),
        if (loadedData.schemaVersion > schemaVersion) ...[
          SizedBox(height: 12),
          Text(
            loc?.backupFromNewerVersionWarning ??
                "<Warning backup is form newer version>",
          ),
        ],
        SizedBox(height: 12),
        Text(
          loc?.importReplaceConfirmationDialog ??
              "<import replace confirmation dialog>",
        ),
      ],
    );
  }
}
