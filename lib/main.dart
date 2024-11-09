import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/persistent_storage/isar_persistent_storage.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';
import 'package:kgl_time/persistent_storage/temp_storage.dart';

import 'data_model/work_category.dart';
import 'kgl_time_app.dart';

bool isLoadTest = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PersistentStorageService.initializeImplementation(
      isLoadTest ? TempStorage() : IsarPersistentStorage());
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
  await initializeDateFormatting(
      'de', '_'); // initialize the date formatting for German
  runApp(KglTimeApp(
    appTitle: 'KGL Time',
    initialEntries: isLoadTest ? loadTestEntries() : initialEntries,
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
      WorkEntry(
        workDurationInSeconds: const Duration(hours: 1).inSeconds,
        date: DateTime.now(),
        description: 'Test',
        categories: [mockWorkCategories[0].toEmbedded()],
      ),
      WorkEntry(
        workDurationInSeconds: const Duration(minutes: 30).inSeconds,
        date: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
        description: 'Test2',
        categories: [mockWorkCategories[1].toEmbedded()],
      ),
      WorkEntry(
        workDurationInSeconds: const Duration(hours: 1, minutes: 30).inSeconds,
        date: DateTime.now().subtract(const Duration(days: 7)),
        description: 'old entry',
        categories: [
          mockWorkCategories[3].toEmbedded(),
          mockWorkCategories[4].toEmbedded()
        ],
      ),
    ];

List<WorkEntry> loadTestEntries() {
  Random rand = Random(0);
  return [for (int i = 0; i < 10000; i++) createRandomWorkEntry(rand)];
}

WorkEntry createRandomWorkEntry(Random rand) {
  return WorkEntry.fromDuration(
    duration: Duration(
      minutes: rand.nextInt(180),
      seconds: rand.nextInt(60),
    ),
    date: DateTime.now().subtract(Duration(days: rand.nextInt(3650))),
    categories: (mockWorkCategories.map((e) => e.toEmbedded()).toList()
      ..shuffle(rand))
      .take(rand.nextInt(mockWorkCategories.length)).toList(),
  );
}
