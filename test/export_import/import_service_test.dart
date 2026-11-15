import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/data_model/key_values.dart';
import 'package:kgl_time/data_model/value.dart';
import 'package:kgl_time/data_model/work_categories.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/data_model/work_entries.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/export_import/import_service.dart';
import 'package:kgl_time/export_import/work_data.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';

import '../support/backup_fixture.dart';
import '../support/controlled_backup_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('loadJsonBackup', () {
    const MethodChannel channel = MethodChannel('flutter_file_dialog');
    late Directory directory;
    late File file;
    String? selectedPath;
    PlatformException? pickerError;
    final List<Object> errors = <Object>[];

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('kgl_import_test_');
      file = File('${directory.path}/backup.json');
      selectedPath = file.path;
      pickerError = null;
      errors.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall call) async {
          expect(call.method, 'pickFile');
          if (pickerError != null) throw pickerError!;
          return selectedPath;
        },
      );
    });

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      );
      await directory.delete(recursive: true);
    });

    test('cancellation returns no backup and reports no error', () async {
      selectedPath = null;
      expect(await ImportService().loadJsonBackup(onError: errors.add), isNull);
      expect(errors, isEmpty);
    });

    test('reads a valid snapshot without changing its source file', () async {
      final String contents = jsonEncode(backupFixture());
      await file.writeAsString(contents);
      final WorkData? loaded = await ImportService().loadJsonBackup(onError: errors.add);
      expect(loaded, isNotNull);
      expect(jsonDecode(jsonEncode(loaded!.toJson())), backupFixture());
      expect(await file.readAsString(), contents);
      expect(errors, isEmpty);
    });

    for (final String contents in <String>['not JSON', '{}', '[]']) {
      test('reports invalid file contents: $contents', () async {
        await file.writeAsString(contents);
        expect(await ImportService().loadJsonBackup(onError: errors.add), isNull);
        expect(errors, hasLength(1));
        expect(errors.single, isA<FormatException>());
      });
    }

    for (final String collection in <String>['workEntries', 'workCategories']) {
      for (final bool duplicate in <bool>[false, true]) {
        test('reports ${duplicate ? 'duplicate' : 'invalid'} IDs in $collection', () async {
          final Map<String, dynamic> json = backupFixture();
          final List<Map<String, dynamic>> records = json[collection] as List<Map<String, dynamic>>;
          records.first['id'] = duplicate ? records.last['id'] : 1.5;
          await file.writeAsString(jsonEncode(json));

          expect(await ImportService().loadJsonBackup(onError: errors.add), isNull);
          expect(errors, hasLength(1));
          expect(errors.single, isA<FormatException>());
          expect(errors.single, isNot(isA<UnsupportedBackupFormatException>()));
        });
      }
    }

    test('reports picker failures through onError instead of throwing', () async {
      pickerError = PlatformException(code: 'picker_failed');
      await expectLater(
        ImportService().loadJsonBackup(onError: errors.add),
        completion(isNull),
      );
      expect(errors, hasLength(1));
      expect(
        errors.single,
        isA<PlatformException>().having(
          (PlatformException error) => error.code,
          'code',
          'picker_failed',
        ),
      );
    });

    test('reports an unreadable file through onError instead of throwing', () async {
      // The selected path deliberately does not exist.
      await expectLater(
        ImportService().loadJsonBackup(onError: errors.add),
        completion(isNull),
      );
      expect(errors, hasLength(1));
      expect(errors.single, isA<FileSystemException>());
    });

    test('reports an unsupported backup format before returning data for confirmation', () async {
      final Map<String, dynamic> json = backupFixture()..['backupFormatVersion'] = 2;
      await file.writeAsString(jsonEncode(json));
      expect(await ImportService().loadJsonBackup(onError: errors.add), isNull);
      expect(errors, hasLength(1));
      expect(errors.single, isA<UnsupportedBackupFormatException>());
    });
  });

  group('restore safety', () {
    late ControlledBackupStorage storage;
    late WorkEntries entries;
    late WorkCategories categories;
    late KeyValues settings;
    late WorkData backup;

    setUp(() async {
      storage = ControlledBackupStorage();
      PersistentStorageService.setImplementation(storage);
      final WorkEntry original = WorkEntry(
        workDurationInSeconds: 60,
        date: DateTime.utc(2020),
        lastEdit: DateTime.utc(2020, 1, 2),
        categories: <EmbeddedWorkCategory>[
          EmbeddedWorkCategory(displayName: 'Original category', id: 7),
        ],
      )..id = 1;
      final WorkCategory category = WorkCategory('Original category', listIndex: 0)..id = 7;
      await storage.workEntries.saveEntries(<WorkEntry>[original]);
      await storage.workCategories.saveEntries(<WorkCategory>[category]);
      entries = WorkEntries(<WorkEntry>[original]);
      categories = WorkCategories(<WorkCategory>[category]);
      settings = KeyValues(<String, dynamic>{});
      backup = WorkData.fromJson(backupFixture());
    });

    tearDown(() async {
      entries.dispose();
      categories.dispose();
      settings.dispose();
      await storage.close();
    });

    Future<UndoImport> restore() =>
        ImportService().importAndReplace(backup, entries, categories, settings);

    Future<void> startTracker() async {
      settings.set<DateTime>(KeyValues.timeTrackerStartKey, DateTime.utc(2026, 11, 15, 8));
      settings.set<String>(KeyValues.timeTrackerCategoriesKey, '7');
      await Future<void>.delayed(Duration.zero);
    }

    Future<Object?> state() async => jsonDecode(
      jsonEncode(<String, Object?>{
        'trackerStart': settings
            .get<DateTime>(KeyValues.timeTrackerStartKey)
            ?.toUtc()
            .toIso8601String(),
        'trackerCategories': settings.get<String>(KeyValues.timeTrackerCategoriesKey),
        'storedTrackerStart': (await storage.keyValueStorage.get<DateTime>(
          KeyValues.timeTrackerStartKey,
        ))?.toUtc().toIso8601String(),
        'storedTrackerCategories': await storage.keyValueStorage.get<String>(
          KeyValues.timeTrackerCategoriesKey,
        ),
        'entries': entries.entriesIncludingTrash.map((WorkEntry entry) => entry.toJson()).toList(),
        'categories': categories.entries.map((WorkCategory category) => category.toJson()).toList(),
        'storedEntries': (await storage.workEntries.loadEntries())
            .map((WorkEntry entry) => entry.toJson())
            .toList(),
        'storedCategories': (await storage.workCategories.loadEntries())
            .map((WorkCategory category) => category.toJson())
            .toList(),
      }),
    );

    test('does not complete while category persistence is pending', () async {
      await startTracker();
      final Completer<void> barrier = Completer<void>();
      storage.workCategories.writeBarrier = barrier;
      final Object? before = await state();
      bool completed = false;
      final Future<void> operation = restore().then<void>((Object? result) {
        completed = true;
      });
      try {
        await Future<void>.delayed(Duration.zero);
        expect(
          completed,
          isFalse,
          reason: 'Restore must await persistence before reporting success',
        );
        expect(await state(), before);
      } finally {
        barrier.complete();
        await operation;
        await Future<void>.delayed(Duration.zero);
      }
    });

    test('a failed category write preserves both stored and in-memory datasets', () async {
      await startTracker();
      final Object? before = await state();
      storage.workCategories.failWrites = true;
      await expectLater(restore(), throwsStateError);
      await Future<void>.delayed(Duration.zero);
      expect(await state(), before);
    });

    test('a false transaction result preserves both stored and in-memory datasets', () async {
      await startTracker();
      final Object? before = await state();
      storage.acceptReplacement = false;
      await expectLater(restore(), throwsStateError);
      expect(await state(), before);
    });

    for (final String invalid in <String>['version', 'entry IDs', 'category IDs']) {
      test(
        'invalid $invalid cannot replace data or cancel tracking even when constructed directly',
        () async {
          await startTracker();
          final Object? before = await state();
          backup = WorkData(
            backupFormatVersion: invalid == 'version' ? 2 : 1,
            exportedAt: backup.exportedAt,
            workEntries: invalid == 'entry IDs'
                ? <WorkEntry>[backup.workEntries.first, backup.workEntries.first]
                : backup.workEntries,
            workCategories: invalid == 'category IDs'
                ? <WorkCategory>[backup.workCategories.first, backup.workCategories.first]
                : backup.workCategories,
          );
          await expectLater(restore(), throwsFormatException);
          expect(await state(), before);
          expect(storage.replacementCalls, 0);
        },
      );
    }

    test(
      'successful import cancels tracking without saving it and undo does not restart it',
      () async {
        await startTracker();
        final UndoImport undo = await restore();
        expect(settings.get<DateTime>(KeyValues.timeTrackerStartKey), isNull);
        expect(settings.get<String>(KeyValues.timeTrackerCategoriesKey), isNull);
        expect(await storage.keyValueStorage.get<DateTime>(KeyValues.timeTrackerStartKey), isNull);
        expect(
          await storage.keyValueStorage.get<String>(KeyValues.timeTrackerCategoriesKey),
          isNull,
        );
        expect(await storage.workEntries.loadEntries(), hasLength(backup.workEntries.length));
        await undo();
        expect(settings.get<DateTime>(KeyValues.timeTrackerStartKey), isNull);
        expect(await storage.keyValueStorage.get<DateTime>(KeyValues.timeTrackerStartKey), isNull);
        expect(await storage.workEntries.loadEntries(), hasLength(1));
      },
    );

    test(
      'a new tracker requires confirmation even if the imported work data is unchanged',
      () async {
        final UndoImport undo = await restore();
        await startTracker();
        final Object? before = await state();
        await expectLater(
          undo(),
          throwsA(
            isA<ImportUndoRequiresConfirmation>().having(
              (ImportUndoRequiresConfirmation reason) => reason.hasChanges,
              'hasChanges',
              isFalse,
            ),
          ),
        );
        expect(await state(), before);
        await undo(discardChanges: true);
        expect(settings.get<DateTime>(KeyValues.timeTrackerStartKey), isNull);
        expect(settings.get<String>(KeyValues.timeTrackerCategoriesKey), isNull);
        expect(await storage.keyValueStorage.get<DateTime>(KeyValues.timeTrackerStartKey), isNull);
        expect(
          await storage.keyValueStorage.get<String>(KeyValues.timeTrackerCategoriesKey),
          isNull,
        );
        expect(await storage.workEntries.loadEntries(), hasLength(1));
      },
    );

    test('undo awaits the same atomic replacement and restores a separate snapshot', () async {
      final Object? before = await state();
      final WorkEntry oldEntry = entries.entries.single;
      final WorkCategory oldCategory = categories.entries.single;
      final UndoImport undo = await restore();
      final Object? imported = await state();
      oldEntry.description = 'Changed stale reference';
      oldEntry.categories.single.displayName = 'Changed stale category';
      oldCategory.displayName = 'Changed stale root category';
      final Completer<void> barrier = Completer<void>();
      storage.workCategories.writeBarrier = barrier;
      bool completed = false;
      final Future<void> operation = undo().then((_) {
        completed = true;
      });
      try {
        await Future<void>.delayed(Duration.zero);
        expect(completed, isFalse);
        expect(await state(), imported);
      } finally {
        barrier.complete();
        await operation;
      }
      expect(await state(), before);
      expect(storage.replacementCalls, 2);
    });

    for (final bool throwsError in <bool>[true, false]) {
      test('failed undo preserves the imported data (exception: $throwsError)', () async {
        final UndoImport undo = await restore();
        await startTracker();
        final Object? imported = await state();
        storage.workCategories.failWrites = throwsError;
        storage.acceptReplacement = throwsError;
        await expectLater(undo(discardChanges: true), throwsStateError);
        expect(await state(), imported);
      });
    }

    test('undo requires confirmation before discarding later edits', () async {
      final Object? before = await state();
      final UndoImport undo = await restore();
      final WorkEntry entry = entries.entries.single;
      final WorkEntry edited = entry.copyWith(description: const Value<String?>('New work'));
      entries.updateEntry(entry, edited);
      await Future<void>.delayed(Duration.zero);
      final Object? changed = await state();
      await expectLater(undo(), throwsA(isA<ImportUndoRequiresConfirmation>()));
      expect(await state(), changed);
      expect(storage.replacementCalls, 1);
      await undo(discardChanges: true);
      expect(await state(), before);
      expect(storage.replacementCalls, 2);
    });

    test(
      'successful restore preserves edit dates, trash and historical category snapshots',
      () async {
        await restore();
        await Future<void>.delayed(Duration.zero);
        final Map<String, dynamic> expected = backupFixture();
        expect(
          jsonDecode(
            jsonEncode(
              (await storage.workEntries.loadEntries())
                  .map((WorkEntry entry) => entry.toJson())
                  .toList(),
            ),
          ),
          unorderedEquals(expected['workEntries'] as List<dynamic>),
        );
        expect(entries.entriesInTrash.single.id, 43);
        expect(entries.entriesInTrash.single.lastEdit, isNull);
        expect(
          jsonDecode(
            jsonEncode(
              (await storage.workCategories.loadEntries())
                  .map((WorkCategory category) => category.toJson())
                  .toList(),
            ),
          ),
          expected['workCategories'],
        );
      },
    );

    test(
      'restore honors category listIndex even when records are in a different array order',
      () async {
        final Map<String, dynamic> json = backupFixture();
        json['workCategories'] = (json['workCategories'] as List<dynamic>).reversed.toList();
        backup = WorkData.fromJson(json);
        await restore();
        await Future<void>.delayed(Duration.zero);
        expect(categories.entries.map((WorkCategory category) => category.id), <int>[7, 8]);
      },
    );
  });
}
