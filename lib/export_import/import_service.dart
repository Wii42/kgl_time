import 'dart:convert';
import 'dart:developer';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:kgl_time/export_import/work_data.dart';
import 'package:share_plus/share_plus.dart';

import '../data_model/key_values.dart';
import '../data_model/work_categories.dart';
import '../data_model/work_entries.dart';
import '../main.dart';
import '../persistent_storage/persistent_storage_service.dart';

typedef UndoImport = Future<void> Function({bool discardChanges});

class ImportUndoRequiresConfirmation implements Exception {
  const ImportUndoRequiresConfirmation({required this.hasChanges});

  final bool hasChanges;
}

class ImportService {
  static const List<String> _trackerKeys = <String>[
    KeyValues.timeTrackerStartKey,
    KeyValues.timeTrackerCategoriesKey,
  ];

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
    try {
      final OpenFileDialogParams params = OpenFileDialogParams(
        dialogType: OpenFileDialogType.document,
      );
      final String? filePath = await FlutterFileDialog.pickFile(params: params);
      if (filePath == null) {
        return null;
      }
      final String data = await XFile(filePath).readAsString();
      try {
        final Map<String, dynamic> decoded = jsonDecode(data) as Map<String, dynamic>;
        return WorkData.fromJson(decoded);
      } catch (error, stackTrace) {
        Error.throwWithStackTrace(
          error is FormatException ? error : FormatException('Invalid backup data: $error'),
          stackTrace,
        );
      }
    } catch (error, stackTrace) {
      log('Failed to load backup', error: error, stackTrace: stackTrace);
      onError?.call(error);
      return null;
    }
  }

  /// Imports the given [workData] into the provided [entriesList] and [categoriesList],
  /// replacing their contents only after the storage transaction commits.
  ///
  /// Returns an asynchronous undo action using a separate snapshot of the previous data.
  /// Successful replacement cancels time tracking without saving a new entry.
  /// Undo requires confirmation to discard later changes or cancel a running tracker.
  Future<UndoImport> importAndReplace(
    WorkData workData,
    WorkEntries entriesList,
    WorkCategories categoriesList,
    KeyValues settings,
  ) async {
    final WorkData currentData = _copy(
      WorkData(
        workEntries: entriesList.entriesIncludingTrash,
        workCategories: categoriesList.entries,
        backupFormatVersion: backupFormatVersion,
        exportedAt: clock.now(),
      ),
    );
    await _replaceAndPublish(_copy(workData), entriesList, categoriesList, settings);
    final String importedState = _stateJson(entriesList, categoriesList);

    return ({bool discardChanges = false}) async {
      final bool hasChanges = _stateJson(entriesList, categoriesList) != importedState;
      final bool isTracking = settings.get<DateTime>(KeyValues.timeTrackerStartKey) != null;
      if (!discardChanges && (hasChanges || isTracking)) {
        throw ImportUndoRequiresConfirmation(hasChanges: hasChanges);
      }
      await _replaceAndPublish(_copy(currentData), entriesList, categoriesList, settings);
    };
  }

  Future<void> _replaceAndPublish(
    WorkData data,
    WorkEntries entriesList,
    WorkCategories categoriesList,
    KeyValues settings,
  ) async {
    data.validate();
    final bool committed = await PersistentStorageService.instance.replaceWorkData(
      entries: data.workEntries,
      categories: data.workCategories,
      keysToRemove: _trackerKeys,
    );
    if (!committed) throw StateError('Storage did not commit the backup replacement');
    settings.removeFromMemory(_trackerKeys);
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
