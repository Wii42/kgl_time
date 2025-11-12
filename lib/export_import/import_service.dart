import 'dart:convert';
import 'dart:developer';

import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:kgl_time/export_import/work_data.dart';
import 'package:share_plus/share_plus.dart';

import '../data_model/work_categories.dart';
import '../data_model/work_entries.dart';
import '../main.dart';

class ImportService {
  Future<WorkData?> loadJsonBackup({
    void Function(Object error)? onError,
  }) async {
    final OpenFileDialogParams params = OpenFileDialogParams(
      dialogType: OpenFileDialogType.document,
      //mimeTypesFilter: ['application/json'],
    );
    String? filePath = await FlutterFileDialog.pickFile(params: params);
    if (filePath == null) {
      log("No file selected for import");
      return null;
    }
    String data = await XFile(filePath).readAsString();
    dynamic decoded;
    try {
      decoded = jsonDecode(data);
    } catch (e) {
      log("$filePath does not contain valid JSON", error: e);
      if (onError != null) {
        onError(e);
      }
      return null;
    }

    WorkData? workData = WorkData.tryFromJson(decoded);
    if (workData == null) {
      if (onError != null) {
        onError(ArgumentError("Invalid WorkData"));
      }
    }
    return workData;
  }

  /// Imports the given [workData] into the provided [entriesList] and [categoriesList],
  /// replacing their current contents.
  ///
  /// Returns a function that, when called, will revert the changes made by this import,
  void Function() importAndReplace(
    WorkData workData,
    WorkEntries entriesList,
    WorkCategories categoriesList,
  ) {
    WorkData currentData = WorkData(
      workEntries: entriesList.entriesIncludingTrash,
      workCategories: categoriesList.entries,
      schemaVersion: schemaVersion,
      exportedAt: DateTime.now(),
    );
    entriesList.replaceAllEntries(workData.workEntries);
    categoriesList.replaceAllEntries(workData.workCategories);

    return () {
      entriesList.replaceAllEntries(currentData.workEntries);
      categoriesList.replaceAllEntries(currentData.workCategories);
    };
  }
}
