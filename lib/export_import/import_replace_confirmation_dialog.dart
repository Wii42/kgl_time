import 'dart:developer';

import 'package:kgl_time/export_import/work_data.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../data_model/work_categories.dart';
import '../data_model/work_entries.dart';
import '../l10n/generated/app_localizations.dart';
import '../main.dart';
import '../utils/format_duration.dart';
import 'import_service.dart';
import 'undo_import_confirmation_dialog.dart';

class ImportReplaceConfirmationDialog extends StatefulWidget {
  const ImportReplaceConfirmationDialog({super.key, required this.loadedData});

  final WorkData loadedData;

  @override
  State<ImportReplaceConfirmationDialog> createState() => _ImportReplaceConfirmationDialogState();
}

class _ImportReplaceConfirmationDialogState extends State<ImportReplaceConfirmationDialog> {
  bool _isImporting = false;

  Future<void> _importAndReplace() async {
    if (_isImporting) return;
    final WorkEntries entriesList = context.read<WorkEntries>();
    final WorkCategories categoriesList = context.read<WorkCategories>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final NavigatorState navigator = Navigator.of(context);
    final AppLocalizations? loc = AppLocalizations.of(context);
    setState(() => _isImporting = true);
    try {
      final UndoImport revertImport = await ImportService().importAndReplace(
        widget.loadedData,
        entriesList,
        categoriesList,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(loc?.importSuccess ?? '<Import successful.>'),
          action: SnackBarAction(
            label: loc?.undo ?? '<Undo>',
            onPressed: () async {
              try {
                await revertImport();
              } on ImportUndoRequiresConfirmation {
                if (navigator.mounted) {
                  await showDialog<void>(
                    context: navigator.context,
                    builder: (BuildContext context) => UndoImportConfirmationDialog(
                      onUndo: () => revertImport(discardChanges: true),
                    ),
                  );
                }
              } catch (error, stackTrace) {
                log('Failed to undo backup import', error: error, stackTrace: stackTrace);
                if (messenger.mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(loc?.undoImportFailed ?? '<Undo failed.>')),
                  );
                }
              }
            },
          ),
        ),
      );
    } catch (error, stackTrace) {
      log('Failed to replace work data from backup', error: error, stackTrace: stackTrace);
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(loc?.importFailed ?? '<Import failed.>')),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? loc = AppLocalizations.of(context);
    return PopScope(
      canPop: !_isImporting,
      child: AlertDialog(
        title: Text(loc?.importBacupAndReplace ?? "<Import Data>"),
        content: _ImportReplaceContent(loadedData: widget.loadedData),
        actions: [
          ElevatedButton(
            onPressed: _isImporting ? null : () => Navigator.of(context).pop(),
            child: Text(loc?.cancel ?? "<Cancel>"),
          ),
          TextButton(
            onPressed: _isImporting ? null : _importAndReplace,
            child: Text(
              loc?.importBacupAndReplaceExistingEntries ?? "<Import and Replace>",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportReplaceContent extends StatelessWidget {
  const _ImportReplaceContent({required this.loadedData});

  final WorkData loadedData;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? loc = AppLocalizations.of(context);
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
                loadedData.workCategories.length,
                loadedData.workEntries.length,
              ) ??
              "<Number of entries and categories>",
        ),
        if (loadedData.backupFormatVersion > backupFormatVersion) ...[
          SizedBox(height: 12),
          Text(
            loc?.backupFromNewerVersionWarning ?? "<Warning backup is form newer version>",
          ),
        ],
        SizedBox(height: 12),
        Text(
          loc?.importReplaceConfirmationDialog ?? "<import replace confirmation dialog>",
        ),
      ],
    );
  }
}
