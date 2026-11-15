import 'dart:convert';
import 'dart:typed_data';

import 'package:kgl_time/app/app_layout_constants.dart';
import 'package:kgl_time/data_model/work_entries.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/pages/kgl_page.dart';
import 'package:kgl_time/widgets/layout/always_filling_scroll_view.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../data_model/work_categories.dart';
import '../data_model/work_category.dart';
import '../data_model/work_entry.dart';
import '../export_import/export_entries_card.dart';
import '../export_import/export_import_card.dart';
import '../export_import/export_service.dart';
import '../export_import/import_replace_confirmation_dialog.dart';
import '../export_import/import_service.dart';
import '../export_import/work_data.dart';

class ExportImportPage extends KglPage {
  const ExportImportPage({super.key, required super.appTitle});

  @override
  String? pageTitle(AppLocalizations? loc) => loc?.exportImportEntries ?? "<Export / Import Data>";

  @override
  bool get showSettingsButton => false;

  @override
  Widget body(BuildContext context) {
    AppLocalizations? loc = AppLocalizations.of(context);
    final bool canImport = ImportService().isImportSupportedOnCurrentPlatform();
    return AlwaysFillingScrollView(
      maxWidth: AppLayoutConstants.maxPageWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExportEntriesCard(
              title: (loc) => loc?.exportTable ?? "<export as table>",
              createFile: () => (
                content: csvFileContent(context),
                fileName: const ExportService().csvFileName(),
              ),
              mimeType: 'text/csv; charset=utf-8',
              explanationLabel: (loc) => loc?.exportCsvExplanation ?? "<Export as CSV explanation>",
            ),
            SizedBox(height: 16),
            ExportEntriesCard(
              title: (loc) => loc?.exportBackup ?? "<export backup>",
              createFile: () => (
                content: jsonFileContent(context),
                fileName: const ExportService().jsonFileName(),
              ),
              mimeType: 'application/json; charset=utf-8',
              explanationLabel: (loc) =>
                  loc?.exportJsonExplanation ?? "<export to JSON explanation>",
            ),
            SizedBox(height: 16),
            ImportExportCard(
              title: (loc) => loc?.importBackup ?? "<import json>",
              explanationLabel: (loc) =>
                  loc?.importBackupExplanation ?? "<import backup explanation>",
              actions: [
                TextButton.icon(
                  onPressed: canImport ? onImportJsonBackup(context) : null,
                  label: Text(loc?.importBackup ?? '<Import backup>'),
                  icon: Icon(Icons.upload_outlined),
                ),
              ],
              warningLabels: [
                if (!canImport) (loc) => loc?.importingNotSupported ?? "<Importing not supported>",
              ],
            ),
          ],
        ),
      ),
    );
  }

  Uint8List csvFileContent(BuildContext context) {
    List<WorkEntry> entries = context.read<WorkEntries>().entries;
    AppLocalizations? loc = AppLocalizations.of(context);
    String csvData = ExportService().entriesToCsv(entries, loc);
    Uint8List fileContent = utf8.encode(csvData);
    return fileContent;
  }

  Uint8List jsonFileContent(BuildContext context) {
    List<WorkEntry> entries = context.read<WorkEntries>().entriesIncludingTrash;
    List<WorkCategory> categories = context.read<WorkCategories>().entries;
    return utf8.encode(ExportService().dataToJson(entries, categories));
  }

  VoidCallback onImportJsonBackup(BuildContext context) => () async {
    AppLocalizations? loc = AppLocalizations.of(context);
    WorkData? loadedData = await ImportService().loadJsonBackup(
      onError: (Object error) {
        if (!context.mounted) return;
        if (error is UnsupportedBackupFormatException) {
          showDialog<void>(
            context: context,
            builder: (BuildContext dialogContext) => AlertDialog(
              scrollable: true,
              title: Text(loc?.unsupportedBackupFormatTitle ?? '<Unsupported backup format>'),
              content: Text(loc?.unsupportedBackupFormat ?? '<Unsupported backup format>'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(MaterialLocalizations.of(dialogContext).okButtonLabel),
                ),
              ],
            ),
          );
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is FormatException
                  ? loc?.invalidBackupData ?? '<Invalid backup data.>'
                  : loc?.importFailed ?? '<Import failed.>',
            ),
          ),
        );
      },
    );
    if (loadedData == null) {
      return;
    }
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => ImportReplaceConfirmationDialog(loadedData: loadedData),
      );
    }
  };
}
