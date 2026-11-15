import 'dart:developer';

import 'package:kgl_time/export_import/work_data.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../data_model/key_values.dart';
import '../data_model/work_categories.dart';
import '../data_model/work_entries.dart';
import '../l10n/generated/app_localizations.dart';
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
    if (_isImporting || !WorkData.isSupportedVersion(widget.loadedData.backupFormatVersion)) return;
    final WorkEntries entriesList = context.read<WorkEntries>();
    final WorkCategories categoriesList = context.read<WorkCategories>();
    final KeyValues settings = context.read<KeyValues>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final NavigatorState navigator = Navigator.of(context);
    final AppLocalizations? loc = AppLocalizations.of(context);
    setState(() => _isImporting = true);
    try {
      final UndoImport revertImport = await ImportService().importAndReplace(
        widget.loadedData,
        entriesList,
        categoriesList,
        settings,
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
              } on ImportUndoRequiresConfirmation catch (reason) {
                if (!navigator.mounted) return;
                final bool undone =
                    await showDialog<bool>(
                      context: navigator.context,
                      builder: (BuildContext context) => UndoImportConfirmationDialog(
                        onUndo: () => revertImport(discardChanges: true),
                        hasChanges: reason.hasChanges,
                      ),
                    ) ??
                    false;
                if (!undone) return;
              } catch (error, stackTrace) {
                log('Failed to undo backup import', error: error, stackTrace: stackTrace);
                if (messenger.mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(loc?.undoImportFailed ?? '<Undo failed.>')),
                  );
                }
                return;
              }
              if (messenger.mounted) {
                messenger.hideCurrentSnackBar();
                messenger.showSnackBar(
                  SnackBar(content: Text(loc?.undoImportSuccess ?? '<Backup import undone.>')),
                );
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
    final bool supported = WorkData.isSupportedVersion(widget.loadedData.backupFormatVersion);
    return PopScope(
      canPop: !_isImporting,
      child: AlertDialog(
        scrollable: true,
        title: Text(loc?.importBacupAndReplace ?? "<Import Data>"),
        content: _ImportReplaceContent(loadedData: widget.loadedData),
        actions: [
          ElevatedButton(
            onPressed: _isImporting ? null : () => Navigator.of(context).pop(),
            child: Text(loc?.cancel ?? "<Cancel>"),
          ),
          TextButton(
            onPressed: _isImporting || !supported ? null : _importAndReplace,
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
    final bool isTracking = context.select<KeyValues, bool>(
      (KeyValues settings) => settings.get<DateTime>(KeyValues.timeTrackerStartKey) != null,
    );
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
        SizedBox(height: 12),
        Text(
          loc?.importReplaceConfirmationDialog ?? "<import replace confirmation dialog>",
        ),
        if (isTracking) ...<Widget>[
          const SizedBox(height: 12),
          Text(loc?.importCancelsTrackerWarning ?? '<Importing will cancel the running tracker.>'),
        ],
      ],
    );
  }
}
