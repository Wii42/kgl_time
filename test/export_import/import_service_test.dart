import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
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
      });
    }

    test('reports picker failures through onError instead of throwing', () async {
      pickerError = PlatformException(code: 'picker_failed');
      await expectLater(
        ImportService().loadJsonBackup(onError: errors.add),
        completion(isNull),
      );
      expect(errors, hasLength(1));
    });

    test('reports an unreadable file through onError instead of throwing', () async {
      // The selected path deliberately does not exist.
      await expectLater(
        ImportService().loadJsonBackup(onError: errors.add),
        completion(isNull),
      );
      expect(errors, hasLength(1));
    });
  });

  group('restore safety', () {
    late ControlledBackupStorage storage;
    late WorkEntries entries;
    late WorkCategories categories;
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
      backup = WorkData.fromJson(backupFixture());
    });

    tearDown(() async {
      entries.dispose();
      categories.dispose();
      await storage.close();
    });

    // Accept the current undo callback or a future asynchronous restore result.
    Future<Object?> restore() => Future<Object?>.sync(
      () => ImportService().importAndReplace(backup, entries, categories),
    );

    Future<Object?> state() async => jsonDecode(
      jsonEncode(<String, Object?>{
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
      final Completer<void> barrier = Completer<void>();
      storage.workCategories.writeBarrier = barrier;
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
      } finally {
        barrier.complete();
        await operation;
        await Future<void>.delayed(Duration.zero);
      }
    });

    test('a failed category write preserves both stored and in-memory datasets', () async {
      final Object? before = await state();
      storage.workCategories.failWrites = true;
      await expectLater(restore(), throwsStateError);
      await Future<void>.delayed(Duration.zero);
      expect(await state(), before);
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
