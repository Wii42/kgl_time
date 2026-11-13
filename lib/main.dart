import 'package:intl/date_symbol_data_local.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/persistent_storage/isar_persistent_storage.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'data_model/work_category.dart';
import 'kgl_time_app.dart';
import 'l10n/app_locales.dart';
import 'l10n/generated/app_localizations.dart';

late final PackageInfo appInfo;

typedef InitialAppData = ({
  PackageInfo appInfo,
  List<WorkEntry> entries,
  List<WorkCategory> categories,
  Map<String, dynamic> keyValues,
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  InitialAppData data = await initializeApp();
  appInfo = data.appInfo;
  runApp(
    KglTimeApp(
      appTitle: 'KGL Time',
      initialEntries: data.entries,
      initialCategories: data.categories,
      initialKeyValueStorage: data.keyValues,
    ),
  );
}

List<WorkCategory> createInitialCategories(AppLocalizations loc) => [
  WorkCategory(loc.defaultCategoryPlanning, listIndex: 0),
  WorkCategory(loc.defaultCategoryMeetings, listIndex: 1),
  WorkCategory(loc.defaultCategoryAdministration, listIndex: 2),
];

Future<InitialAppData> initializeApp() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  await PersistentStorageService.initializeImplementation(IsarPersistentStorage());
  final List<WorkEntry> initialEntries = await PersistentStorageService.instance.workEntries
      .loadEntries();
  final List<WorkCategory> initialCategories = await PersistentStorageService
      .instance
      .workCategories
      .loadEntries();

  final Map<String, dynamic> initialKeyValueStorage = await PersistentStorageService
      .instance
      .keyValueStorage
      .getAll();
  final bool isFirstRun = initialKeyValueStorage['isFirstRun'] ?? true;
  if (isFirstRun) {
    final Locale locale = basicLocaleListResolution(
      WidgetsBinding.instance.platformDispatcher.locales,
      supportedAppLocales,
    );
    final AppLocalizations loc = await AppLocalizations.delegate.load(locale);
    final List<WorkCategory> categories = createInitialCategories(loc);
    await PersistentStorageService.instance.workCategories.saveEntries(categories);
    initialCategories.addAll(categories);
    // Set isFirstRun to false in storage for future runs, but the in memory value is not updated,
    // so that other part of the app still get the notification that it is the first run.
    await PersistentStorageService.instance.keyValueStorage.set('isFirstRun', false);
    initialKeyValueStorage['isFirstRun'] = true;
  }
  await initializeDateFormatting(); // initialize the date formatting for German

  return (
    appInfo: packageInfo,
    entries: initialEntries,
    categories: initialCategories,
    keyValues: initialKeyValueStorage,
  );
}
