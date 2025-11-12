import 'dart:convert';
import 'dart:developer';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:intl/intl.dart';
import 'package:kgl_time/data_model/work_entries.dart';
import 'package:kgl_time/format_duration.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/main.dart';
import 'package:kgl_time/pages/kgl_page.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data_model/work_categories.dart';
import '../data_model/work_category.dart';
import '../data_model/work_entry.dart';
import '../export_import/work_data.dart';
import '../kgl_time_app.dart';

class ExportImportPage extends KglPage {
  const ExportImportPage({super.key, required super.appTitle});

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

  String csvFileName() => 'work_entries_export_${fileTimestamp()}.csv';

  String fileTimestamp() =>
      DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());

  @override
  String? pageTitle(AppLocalizations? loc) =>
      loc?.exportImportEntries ?? "<Export / Import Data>";

  @override
  bool get showSettingsButton => false;

  String exportEntriesToCsv(List<WorkEntry> entries, AppLocalizations? loc) {
    List<List<dynamic>> rows = [
      [
        loc?.workingTime ?? "Working Time",
        loc?.date ?? "Date",
        loc?.description ?? "Description",
        loc?.fromTo ?? "From-To",
        loc?.categories ?? "Categories",
      ],
      ...entries.map(
        (entry) => [
          formatDuration(entry.workDuration),
          formatDate(entry.date, loc),
          entry.description,
          if (entry.startTime != null && entry.endTime != null)
            '${formatTime(entry.startTime!)} - ${formatTime(entry.endTime!)}'
          else
            null,
          entry.categories.map((category) => category.displayName).join(", "),
        ],
      ),
    ];

    return ListToCsvConverter(convertNullTo: '').convert(rows);
  }

  VoidCallback onSave({
    required Uint8List fileContent,
    required String fileName,
    required BuildContext context,
    List<String>? mimeTypesFilter,
  }) => () async {
    ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    AppLocalizations? loc = AppLocalizations.of(context);
    try {
      String? path = await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(
          data: fileContent,
          fileName: fileName,
          mimeTypesFilter: mimeTypesFilter,
        ),
      );
      if (path != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              loc?.fileSavedSuccessfully ?? "<File saved successfully.>",
            ),
          ),
        );
      }
    } catch (error, stacktrace) {
      log("Failed to save file", error: error, stackTrace: stacktrace);
      messenger.showSnackBar(
        SnackBar(
          content: Text(loc?.failedToSaveFile ?? "<Failed to save file.>"),
        ),
      );
    }
  };

  VoidCallback onSaveAsCsv(BuildContext context) => onSave(
    fileContent: csvFileContent(context),
    fileName: csvFileName(),
    context: context,
    mimeTypesFilter: ['text/csv'],
  );

  Uint8List csvFileContent(BuildContext context) {
    List<WorkEntry> entries = context.read<WorkEntries>().entries;
    AppLocalizations? loc = AppLocalizations.of(context);
    String csvData = exportEntriesToCsv(entries, loc);
    Uint8List fileContent = utf8.encode(csvData);
    return fileContent;
  }

  VoidCallback onShare({
    required Uint8List fileContent,
    required String fileName,
    required BuildContext context,
    String? mimeType,
  }) => () async {
    XFile file = XFile.fromData(
      fileContent,
      mimeType: mimeType,
      name: fileName,
    );
    AppLocalizations? loc = AppLocalizations.of(context);
    ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      ShareResult result = await SharePlus.instance.share(
        ShareParams(files: [file], fileNameOverrides: [fileName]),
      );
      if (result.status == ShareResultStatus.success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              loc?.fileSharedSuccessfully ?? "<File shared successfully.>",
            ),
          ),
        );
      }
    } catch (error, stacktrace) {
      log("Failed to share file", error: error, stackTrace: stacktrace);
      messenger.showSnackBar(
        SnackBar(
          content: Text(loc?.failedToShareFile ?? "<Failed to share file.>"),
        ),
      );
    }
  };

  VoidCallback onShareCsv(BuildContext context) => onShare(
    fileContent: csvFileContent(context),
    fileName: csvFileName(),
    context: context,
    mimeType: 'text/csv; charset=utf-8',
  );

  VoidCallback onShareJson(BuildContext context) => onShare(
    fileContent: jsonFileContent(context),
    fileName: jsonFileName(),
    context: context,
    mimeType: 'application/json; charset=utf-8',
  );

  VoidCallback onSaveJson(BuildContext context) => onSave(
    fileContent: jsonFileContent(context),
    fileName: jsonFileName(),
    context: context,
    mimeTypesFilter: ['application/json'],
  );

  Uint8List jsonFileContent(BuildContext context) {
    List<WorkEntry> entries = context.read<WorkEntries>().entriesIncludingTrash;
    List<WorkCategory> categories = context.read<WorkCategories>().entries;
    WorkData workData = WorkData(
      workEntries: entries,
      workCategories: categories,
      schemaVersion: schemaVersion,
      exportedAt: DateTime.now(),
    );
    return utf8.encode(jsonEncode(workData.toJson()));
  }

  String jsonFileName() => 'kgl_time_backup_${fileTimestamp()}.json';

  VoidCallback onImportJsonBackup(BuildContext context) => () async {
    ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    void showError() {
      messenger.showSnackBar(SnackBar(content: Text("<Import failed.>")));
    }

    AppLocalizations? loc = AppLocalizations.of(context);
    final OpenFileDialogParams params = OpenFileDialogParams(
      dialogType: OpenFileDialogType.document,
      //mimeTypesFilter: ['application/json'],
    );
    String? filePath = await FlutterFileDialog.pickFile(params: params);
    if (filePath != null) {
      String data = await XFile(filePath).readAsString();
      dynamic decoded;
      try {
        decoded = jsonDecode(data);
      } catch (e) {
        log("$filePath does not contain valid JSON", error: e);
        showError();
        return;
      }

      WorkData? t = WorkData.tryFromJson(decoded);
      if (t == null) {
        showError();
        return;
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("<Import Data>"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Date of backup: ${formatDate(t.exportedAt, loc)}, ${formatTime(t.exportedAt)}",
              ),
              Text(
                "Work entries: ${t.workEntries.length}, categories: ${t.workCategories.length}",
              ),
              if (t.schemaVersion > schemaVersion) ...[
                SizedBox(height: 12),
                Text(
                  "<Warning: The backup was created with a newer version of the app (schema version ${t.schemaVersion}) than the current app version (schema version $schemaVersion). Importing the data may lead to loss of information or app instability. Proceed with caution.>",
                ),
              ],
              SizedBox(height: 12),
              Text(
                "<Are you sure you want to import the data from the selected file? This will delete all your current entries and categories and replace with the backup.>",
              ),
            ],
          ),
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
                WorkData currentData = WorkData(
                  workEntries: entriesList.entriesIncludingTrash,
                  workCategories: categoriesList.entries,
                  schemaVersion: schemaVersion,
                  exportedAt: DateTime.now(),
                );
                entriesList.replaceAllEntries(t.workEntries);
                categoriesList.replaceAllEntries(t.workCategories);
                Navigator.of(context).pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text("<Import successful.>"),
                    action: SnackBarAction(
                      label: "rückgängig",
                      onPressed: () {
                        entriesList.replaceAllEntries(currentData.workEntries);
                        categoriesList.replaceAllEntries(
                          currentData.workCategories,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }
  };
}
