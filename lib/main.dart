import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/persistent_storage/isar_persistent_storage.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';

import 'data_model/work_category.dart';
import 'kgl_time_app.dart';

const String appVersion = '0.2.3';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PersistentStorageService.initializeImplementation(
      IsarPersistentStorage());
  List<WorkEntry> initialEntries =
      await PersistentStorageService.instance.workEntries.loadEntries();
  List<WorkCategory> initialCategories =
      await PersistentStorageService.instance.workCategories.loadEntries();
  Map<String, dynamic> initialKeyValueStorage =
      await PersistentStorageService.instance.keyValueStorage.getAll();
  bool isFirstRun = initialKeyValueStorage['isFirstRun'] ?? true;
  if (isFirstRun) {
    await PersistentStorageService.instance.workCategories
        .saveEntries(mockWorkCategories);
    initialCategories.addAll(mockWorkCategories);
    await PersistentStorageService.instance.keyValueStorage
        .set('isFirstRun', false);
  }
  await initializeDateFormatting(); // initialize the date formatting for German
  runApp(KglTimeApp(
    appTitle: 'KGL Time',
    initialEntries: initialEntries,
    initialCategories: initialCategories,
    initialKeyValueStorage: initialKeyValueStorage,
  ));
}

List<WorkCategory> get mockWorkCategories => [
      WorkCategory('Telefonanruf'),
      WorkCategory('Kategorie 2'),
      WorkCategory('Kategorie 3'),
      WorkCategory('Kategorie 4'),
      WorkCategory('Kategorie 5'),
    ];

List<WorkEntry> get mockWorkEntries => [
      WorkEntry.fromDuration(
        duration: const Duration(hours: 1),
        date: DateTime.now(),
        description: 'Test',
        categories: [mockWorkCategories[0].toEmbedded()],
      ),
      WorkEntry.fromDuration(
        duration: const Duration(minutes: 30),
        date: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
        description: 'Test2',
        categories: [mockWorkCategories[1].toEmbedded()],
      ),
      WorkEntry.fromDuration(
        duration: const Duration(hours: 1, minutes: 30),
        date: DateTime.now().subtract(const Duration(days: 7)),
        description: 'old entry',
        categories: [
          mockWorkCategories[3].toEmbedded(),
          mockWorkCategories[4].toEmbedded()
        ],
      ),
    ];
