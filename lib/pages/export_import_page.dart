import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:kgl_time/data_model/work_entries.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/pages/kgl_page.dart';
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
import '../kgl_time_app.dart';

class ExportImportPage extends KglPage {
  const ExportImportPage({super.key, required super.appTitle});

  @override
  String? pageTitle(AppLocalizations? loc) =>
      loc?.exportImportEntries ?? "<Export / Import Data>";

  @override
  bool get showSettingsButton => false;

  @override
  Widget body(BuildContext context) {
    AppLocalizations? loc = AppLocalizations.of(context);
    return KglPage.alwaysFillingScrollView(
      maxWidth: KglTimeApp.maxPageWidth,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExportEntriesCard(
              title: (loc) => loc?.exportTable ?? "<export as table>",
              fileContent: csvFileContent(context),
              fileName: ExportService().csvFileName(),
              mimeType: 'text/csv; charset=utf-8',
              explanationLabel: (loc) => loc?.exportCsvExplanation,
            ),
            ExportEntriesCard(
              title: (loc) => loc?.exportBackup ?? "<export backup>",
              fileContent: jsonFileContent(context),
              fileName: ExportService().jsonFileName(),
              mimeType: 'application/json; charset=utf-8',
              explanationLabel: (loc) => loc?.exportJsonExplanation,
            ),
            ImportExportCard(
              title: (loc) => loc?.importBackup ?? "<import json>",
              explanationLabel: (loc) => loc?.importBackupExplanation,
              actions: [
                ElevatedButton.icon(
                  onPressed: onImportJsonBackup(context),
                  label: Text(loc?.importBacupAndReplaceExistingEntries ?? "<import json and replace data>"),
                  icon: Icon(Icons.upload_outlined),
                ),
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
      onError: (error) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc?.importFailed??"<Import failed.>"))),
    );
    if (loadedData == null) {
      return;
    }
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) =>
            ImportReplaceConfirmationDialog(loadedData: loadedData),
      );
    }
  };
}
