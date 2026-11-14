import 'dart:convert';
import 'dart:developer';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart' show AsyncCallback, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:kgl_time/export_import/work_data.dart';
import 'package:share_plus/share_plus.dart';

import '../data_model/work_categories.dart';
import '../data_model/work_entries.dart';
import '../main.dart';
import '../persistent_storage/persistent_storage_service.dart';

class ImportService {
  /// Native platforms supported by the file picker plugin. Web is unsupported.
  List<TargetPlatform> get supportedImportPlatforms => const [
    TargetPlatform.android,
    TargetPlatform.iOS,
  ];

  bool isImportSupportedOnCurrentPlatform() =>
      supportedImportPlatforms.contains(defaultTargetPlatform);

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
    if (workData == null && onError != null) {
      onError(ArgumentError("Invalid WorkData"));
    }
    return workData;
  }

  /// Imports the given [workData] into the provided [entriesList] and [categoriesList],
  /// replacing their contents only after the storage transaction commits.
  ///
  /// Returns an asynchronous undo action using a separate snapshot of the previous data.
  /// Undo rejects changes made since the import rather than overwriting them.
  Future<AsyncCallback> importAndReplace(
    WorkData workData,
    WorkEntries entriesList,
    WorkCategories categoriesList,) async {
    final WorkData currentData = _copy(
      WorkData(
        workEntries: entriesList.entriesIncludingTrash,
        workCategories: categoriesList.entries,
        backupFormatVersion: backupFormatVersion,
        exportedAt: clock.now(),
      ),
    );
    await _replaceAndPublish(_copy(workData), entriesList, categoriesList);
    final String importedState = _stateJson(entriesList, categoriesList);

    return () async {
      if (_stateJson(entriesList, categoriesList) != importedState) {
        throw StateError('Cannot undo an import after the work data has changed');
      }
      await _replaceAndPublish(_copy(currentData), entriesList, categoriesList);
    };
  }

  Future<void> _replaceAndPublish(
    WorkData data,
    WorkEntries entriesList,
    WorkCategories categoriesList,
  ) async {
    final bool committed = await PersistentStorageService.instance.replaceWorkData(
      entries: data.workEntries,
      categories: data.workCategories,
    );
    if (!committed) throw StateError('Storage did not commit the backup replacement');
    categoriesList.loadEntries(data.workCategories);
    entriesList.loadEntries(data.workEntries);
  }

  WorkData _copy(WorkData data) => WorkData.fromJson(
    jsonDecode(jsonEncode(data.toJson())) as Map<String, dynamic>,
  );

  String _stateJson(WorkEntries entries, WorkCategories categories) => jsonEncode(
    <String, Object>{
      'workEntries': entries.entriesIncludingTrash,
      'workCategories': categories.entries,
    },
  );
}
