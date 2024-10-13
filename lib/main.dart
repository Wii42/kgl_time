import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/persistent_storage/isar_persistent_storage.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';

import 'data_model/work_category.dart';
import 'kgl_time_app.dart';

List<WorkEntry> mockWorkEntries = [
  WorkEntry(
    workDurationInSeconds: const Duration(hours: 1).inSeconds,
    date: DateTime.now(),
    description: 'Test',
    categories: [EmbeddedWorkCategory(displayName: 'Telefonanruf')],
  ),
  WorkEntry(
    workDurationInSeconds: const Duration(minutes: 30).inSeconds,
    date: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
    description: 'Test2',
    categories: [EmbeddedWorkCategory(displayName: 'Kategorie 2')],
  ),
  WorkEntry(
    workDurationInSeconds: const Duration(hours: 1, minutes: 30).inSeconds,
    date: DateTime.now().subtract(const Duration(days: 7)),
    description: 'old entry',
    categories: [
      EmbeddedWorkCategory(displayName: 'Kategorie 4'),
      EmbeddedWorkCategory(displayName: 'Kategorie 5')
    ],
  ),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PersistentStorageService.initializeImplementation(
      IsarPersistentStorage());
  List<WorkEntry> initialEntries =
      await PersistentStorageService.instance.workEntries.loadEntries();
  List<WorkCategory> initialCategories =
      await PersistentStorageService.instance.workCategories.loadEntries();
  await initializeDateFormatting(
      'de', '_'); // initialize the date formatting for German
  runApp(KglTimeApp(
    appTitle: 'KGL Time',
    initialEntries: initialEntries,
    initialCategories: initialCategories,
  ));
}
