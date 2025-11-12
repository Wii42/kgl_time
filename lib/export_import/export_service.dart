import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:intl/intl.dart';
import 'package:kgl_time/export_import/work_data.dart';
import 'package:share_plus/share_plus.dart';

import '../data_model/work_category.dart';
import '../data_model/work_entry.dart';
import '../format_duration.dart';
import '../l10n/generated/app_localizations.dart';
import '../main.dart';

class ExportService {
  const ExportService();

  String csvFileName() => 'work_entries_export_${fileTimestamp()}.csv';

  String jsonFileName() => 'kgl_time_backup_${fileTimestamp()}.json';

  String fileTimestamp() =>
      DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());

  String entriesToCsv(List<WorkEntry> entries, AppLocalizations? loc) {
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

  String dataToJson(List<WorkEntry> entries, List<WorkCategory> categories) {
    WorkData workData = WorkData(
      workEntries: entries,
      workCategories: categories,
      schemaVersion: schemaVersion,
      exportedAt: DateTime.now(),
    );
    return jsonEncode(workData.toJson());
  }

  Future<void> saveFileLocally({
    required Uint8List fileContent,
    required String fileName,
    List<String>? mimeTypesFilter,
    void Function(String path)? onSuccess,
    void Function(Object error)? onError,
  }) async {
    try {
      String? path = await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(
          data: fileContent,
          fileName: fileName,
          mimeTypesFilter: mimeTypesFilter,
        ),
      );
      if (path != null && onSuccess != null) {
        onSuccess(path);
      }
    } catch (error, stacktrace) {
      log("Failed to save file", error: error, stackTrace: stacktrace);
      if (onError != null) {
        onError(error);
      }
    }
  }

  Future<void> shareFile({
    required Uint8List fileContent,
    required String fileName,
    String? mimeType,
    void Function(ShareResult result)? onSuccess,
    void Function(Object error)? onError,
  }) async {
    XFile file = XFile.fromData(
      fileContent,
      mimeType: mimeType,
      name: fileName,
    );
    try {
      ShareResult result = await SharePlus.instance.share(
        ShareParams(files: [file], fileNameOverrides: [fileName]),
      );
      if (result.status == ShareResultStatus.success && onSuccess != null) {
        onSuccess(result);
      }
    } catch (error, stacktrace) {
      log("Failed to share file", error: error, stackTrace: stacktrace);
      if (onError != null) {
        onError(error);
      }
    }
  }
}
