import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:kgl_time/data_model/work_entries.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/pages/kgl_page.dart';
import 'package:provider/provider.dart';

import '../data_model/work_categories.dart';
import '../data_model/work_category.dart';
import '../data_model/work_entry.dart';
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
    return KglPage.alwaysFillingScrollView(
      maxWidth: KglTimeApp.maxPageWidth,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            exportEntriesCard(
              context: context,
              title: (loc) => loc?.exportTable ?? "<export as table>",
              onSave: onSaveAsCsv(context),
              onShare: onShareCsv(context),
              explanationLabel: (loc) => loc?.exportCsvExplanation,
            ),
            exportEntriesCard(
              context: context,
              title: (loc) => loc?.exportBackup ?? "<export backup>",
              onSave: onSaveJson(context),
              onShare: onShareJson(context),
              explanationLabel: (loc) => loc?.exportJsonExplanation,
            ),
            importExportCard(
              context: context,
              title: (_) => "<import json>",
              actions: [
                ElevatedButton.icon(
                  onPressed: onImportJsonBackup(context),
                  label: Text("<import json and replace data>"),
                  icon: Icon(Icons.upload_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget exportEntriesCard({
    required BuildContext context,
    required Function(AppLocalizations? loc) title,
    required VoidCallback onSave,
    required VoidCallback onShare,
    Function(AppLocalizations? loc)? explanationLabel,
  }) {
    AppLocalizations? loc = AppLocalizations.of(context);
    return importExportCard(
      context: context,
      title: title,
      explanationLabel: explanationLabel,
      actions: [
        TextButton.icon(
          label: Text(loc?.saveLocally ?? "<save locally>"),
          icon: Icon(Icons.save_alt_outlined),
          onPressed: (Platform.isAndroid | Platform.isIOS) ? onSave : null,
        ),

        TextButton.icon(
          label: Text(loc?.share ?? "<share>"),
          icon: Icon(Icons.share),
          onPressed: !Platform.isLinux ? onShare : null,
        ),
      ],
    );
  }

  Widget importExportCard({
    required BuildContext context,
    required Function(AppLocalizations? loc) title,
    List<Widget> actions = const [],
    Function(AppLocalizations? loc)? explanationLabel,
  }) {
    AppLocalizations? loc = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              title(loc),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            Divider(height: 12),
            SizedBox(height: 4),
            if (explanationLabel != null) ...[
              Text(
                explanationLabel(loc),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SizedBox(height: 4),
            ],

            Wrap(spacing: 8, runSpacing: 8, children: actions),
          ],
        ),
      ),
    );
  }

  VoidCallback onSave({
    required Uint8List fileContent,
    required String fileName,
    required BuildContext context,
    List<String>? mimeTypesFilter,
  }) => () async {
    ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    AppLocalizations? loc = AppLocalizations.of(context);
    return ExportService().saveFileLocally(
      fileContent: fileContent,
      fileName: fileName,
      mimeTypesFilter: mimeTypesFilter,
      onSuccess: (path) => messenger.showSnackBar(
        SnackBar(
          content: Text(
            loc?.fileSavedSuccessfully ?? "<File saved successfully.>",
          ),
        ),
      ),
      onError: (error) => messenger.showSnackBar(
        SnackBar(
          content: Text(loc?.failedToSaveFile ?? "<Failed to save file.>"),
        ),
      ),
    );
  };

  VoidCallback onSaveAsCsv(BuildContext context) => onSave(
    fileContent: csvFileContent(context),
    fileName: ExportService().csvFileName(),
    context: context,
    mimeTypesFilter: ['text/csv'],
  );

  Uint8List csvFileContent(BuildContext context) {
    List<WorkEntry> entries = context.read<WorkEntries>().entries;
    AppLocalizations? loc = AppLocalizations.of(context);
    String csvData = ExportService().entriesToCsv(entries, loc);
    Uint8List fileContent = utf8.encode(csvData);
    return fileContent;
  }

  VoidCallback onShare({
    required Uint8List fileContent,
    required String fileName,
    required BuildContext context,
    String? mimeType,
  }) => () async {
    AppLocalizations? loc = AppLocalizations.of(context);
    ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    return ExportService().shareFile(
      fileContent: fileContent,
      fileName: fileName,
      mimeType: mimeType,
      onSuccess: (result) => messenger.showSnackBar(
        SnackBar(
          content: Text(
            loc?.fileSharedSuccessfully ?? "<File shared successfully.>",
          ),
        ),
      ),
      onError: (error) => messenger.showSnackBar(
        SnackBar(
          content: Text(loc?.failedToShareFile ?? "<Failed to share file.>"),
        ),
      ),
    );
  };

  VoidCallback onShareCsv(BuildContext context) => onShare(
    fileContent: csvFileContent(context),
    fileName: ExportService().csvFileName(),
    context: context,
    mimeType: 'text/csv; charset=utf-8',
  );

  VoidCallback onShareJson(BuildContext context) => onShare(
    fileContent: jsonFileContent(context),
    fileName: ExportService().jsonFileName(),
    context: context,
    mimeType: 'application/json; charset=utf-8',
  );

  VoidCallback onSaveJson(BuildContext context) => onSave(
    fileContent: jsonFileContent(context),
    fileName: ExportService().jsonFileName(),
    context: context,
    mimeTypesFilter: ['application/json'],
  );

  Uint8List jsonFileContent(BuildContext context) {
    List<WorkEntry> entries = context.read<WorkEntries>().entriesIncludingTrash;
    List<WorkCategory> categories = context.read<WorkCategories>().entries;
    return utf8.encode(ExportService().dataToJson(entries, categories));
  }

  VoidCallback onImportJsonBackup(BuildContext context) => () async {
    WorkData? loadedData = await ImportService().loadJsonBackup(
      onError: (error) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("<Import failed.>"))),
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
