import 'dart:convert';
import 'dart:developer';
import 'dart:io' show Platform;

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:intl/intl.dart';
import 'package:kgl_time/data_model/work_entries.dart';
import 'package:kgl_time/format_duration.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/pages/kgl_page.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data_model/work_entry.dart';
import '../kgl_time_app.dart';

class ExportImportPage extends KglPage {
  const ExportImportPage({super.key, required super.appTitle});

  @override
  Widget body(BuildContext context) {
    AppLocalizations? loc = AppLocalizations.of(context);
    return KglPage.alwaysFillingScrollView(
        maxWidth: KglTimeApp.maxPageWidth,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Expanded(
                    child: OutlinedButton.icon(
                  label: Text(
                      loc?.saveEntriesAs("CSV") ?? "<save entries as CSV>"),
                  icon: Icon(Icons.save_alt_outlined),
                  onPressed: (Platform.isAndroid | Platform.isIOS)
                      ? onSaveAsCsv(context)
                      : null,
                )),
                SizedBox(width: 8,),
                OutlinedButton.icon(
                  label: Text(loc?.share ?? "<share>"),
                  icon: Icon(Icons.share),
                  onPressed: !Platform.isLinux ? onShareCsv(context) : null,
                )
              ]),
            ],
          ),
        ));
  }

  String csvFileName() {
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    String fileName = 'work_entries_export_$timestamp.csv';
    return fileName;
  }

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
        loc?.categories ?? "Categories"
      ],
      ...entries.map((entry) => [
            formatDuration(entry.workDuration),
            formatDate(entry.date, loc),
            entry.description,
            if (entry.startTime != null && entry.endTime != null)
              '${formatTime(entry.startTime!)} - ${formatTime(entry.endTime!)}'
            else
              null,
            entry.categories.map((category) => category.displayName).join(", ")
          ]),
    ];

    return ListToCsvConverter(convertNullTo: '').convert(rows);
  }

  void Function() onSaveAsCsv(BuildContext context) => () async {
        List<WorkEntry> entries = context.read<WorkEntries>().entries;
        AppLocalizations? loc = AppLocalizations.of(context);
        String csvData = exportEntriesToCsv(entries, loc);
        String fileName = csvFileName();
        ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
        try {
          String? path = await FlutterFileDialog.saveFile(
              params: SaveFileDialogParams(
                  data: utf8.encode(csvData), fileName: fileName));
          if (path != null) {
            messenger.showSnackBar(SnackBar(
                content: Text(loc?.fileSavedSuccessfully ??
                    "<File saved successfully.>")));
          }
        } catch (error, stacktrace) {
          log("Failed to save file", error: error, stackTrace: stacktrace);
          messenger.showSnackBar(SnackBar(
              content:
                  Text(loc?.failedToSaveFile ?? "<Failed to save file.>")));
        }
      };

  void Function() onShareCsv(BuildContext context) => () async {
        List<WorkEntry> entries = context.read<WorkEntries>().entries;
        AppLocalizations? loc = AppLocalizations.of(context);
        String csvData = exportEntriesToCsv(entries, loc);
        String fileName = csvFileName();
        XFile file = XFile.fromData(
          utf8.encode(csvData),
          mimeType: 'text/csv; charset=utf-8',
          name: fileName,
        );
        ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
        try {
          ShareResult result = await SharePlus.instance.share(
            ShareParams(
              files: [file],
              fileNameOverrides: [fileName],
            ),
          );
          if (result.status == ShareResultStatus.success) {
            messenger.showSnackBar(SnackBar(
                content: Text(loc?.fileSharedSuccessfully ??
                    "<File shared successfully.>")));
          }
        } catch (error, stacktrace) {
          log("Failed to share file", error: error, stackTrace: stacktrace);
          messenger.showSnackBar(SnackBar(
              content:
                  Text(loc?.failedToShareFile ?? "<Failed to share file.>")));
        }
      };
}
