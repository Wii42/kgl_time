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
import '../kgl_time_app.dart';

class ExportImportPage extends KglPage {
  const ExportImportPage({super.key, required super.appTitle});

  @override
  Widget body(BuildContext context) {
    return KglPage.alwaysFillingScrollView(
      maxWidth: KglTimeApp.maxPageWidth,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            shareSaveButtonRow(
              context: context,
              saveButtonLabel: (loc) => loc?.saveEntriesAs("CSV") ?? "<save entries as CSV>",
              onSave: onSaveAsCsv(context),
              onShare: onShareCsv(context),
              explanationLabel: (loc) => loc?.exportCsvExplanation,
            ),
            shareSaveButtonRow(
              context: context,
              saveButtonLabel: (loc) => loc?.saveBackup??"<save backup>",
              onSave: onSaveJson(context),
              onShare: onShareJson(context),
              explanationLabel: (loc) => loc?.exportJsonExplanation,
            ),
            //ElevatedButton(
            //  onPressed: onShareJson(context),
            //  child: Text("<export as json>"),
            //),
          ],
        ),
      ),
    );
  }

  Widget shareSaveButtonRow({
    required BuildContext context,
    required Function(AppLocalizations? loc) saveButtonLabel,
    required VoidCallback onSave,
    required VoidCallback onShare,
    Function(AppLocalizations? loc)? explanationLabel,
  }) {
    AppLocalizations? loc = AppLocalizations.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                label: Text(
                  saveButtonLabel(loc),
                ),
                icon: Icon(Icons.save_alt_outlined),
                onPressed: (Platform.isAndroid | Platform.isIOS) ? onSave : null,
              ),
            ),
            SizedBox(width: 8),
            OutlinedButton.icon(
              label: Text(loc?.share ?? "<share>"),
              icon: Icon(Icons.share),
              onPressed: !Platform.isLinux ? onShare : null,
            ),
          ],
        ),
        if (explanationLabel != null) ...[
          SizedBox(height: 4),
          Text(
            explanationLabel(loc),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
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
        "WorkDuration",
        loc?.date ?? "Date",
        loc?.description ?? "Description",
        "FromTo",
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
    print("Sharing file: $fileName");
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
}

class WorkData {
  final List<WorkEntry> workEntries;
  final List<WorkCategory> workCategories;
  final int schemaVersion;
  final DateTime exportedAt;

  const WorkData({
    required this.workEntries,
    required this.workCategories,
    required this.schemaVersion,
    required this.exportedAt,
  });

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'exportedAt': exportedAt.toIso8601String(),
    'workEntries': workEntries.map((e) => e.toJson()).toList(),
    'workCategories': workCategories.map((c) => c.toJson()).toList(),
  };

  factory WorkData.fromJson(Map<String, dynamic> json) {
    return WorkData(
      schemaVersion: json['schemaVersion'],
      exportedAt: DateTime.parse(json['exportedAt']),
      workEntries: (json['workEntries'] as List<dynamic>)
          .map((e) => WorkEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      workCategories: (json['workCategories'] as List<dynamic>)
          .map((c) => WorkCategory.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  static WorkData? tryFromJson(Map<String, dynamic> json) {
    try {
      return WorkData.fromJson(json);
    } catch (e, stacktrace) {
      log(
        "Failed to parse WorkData from JSON",
        error: e,
        stackTrace: stacktrace,
      );
      return null;
    }
  }
}
