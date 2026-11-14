import 'package:intl/date_symbol_data_local.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/l10n/app_locales.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_interface.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

typedef InitialAppData = ({
  PackageInfo appInfo,
  List<WorkEntry> entries,
  List<WorkCategory> categories,
  Map<String, dynamic> keyValues,
});

List<WorkCategory> createInitialCategories(AppLocalizations loc) => [
  WorkCategory(
    loc.defaultCategoryPlanning,
    listIndex: 0,
    lastEdit: DateTime.timestamp(),
    uuid: WorkEntry.generateUuid(),
  ),
  WorkCategory(
    loc.defaultCategoryMeetings,
    listIndex: 1,
    lastEdit: DateTime.timestamp(),
    uuid: WorkEntry.generateUuid(),
  ),
  WorkCategory(
    loc.defaultCategoryAdministration,
    listIndex: 2,
    lastEdit: DateTime.timestamp(),
    uuid: WorkEntry.generateUuid(),
  ),
];

Future<InitialAppData> initializeApp({required PersistentStorage storage}) async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  await PersistentStorageService.initializeImplementation(storage);
  final PersistentStorageService storageService = PersistentStorageService.instance;
  final List<WorkEntry> initialEntries = await storageService.workEntries.loadEntries();
  final List<WorkCategory> initialCategories = await storageService.workCategories.loadEntries();

  final Map<String, dynamic> initialKeyValueStorage = await storageService.keyValueStorage.getAll();
  final bool isFirstRun = initialKeyValueStorage['isFirstRun'] ?? true;
  if (isFirstRun) {
    final Locale locale = basicLocaleListResolution(
      WidgetsBinding.instance.platformDispatcher.locales,
      supportedAppLocales,
    );
    final AppLocalizations loc = await AppLocalizations.delegate.load(locale);
    final List<WorkCategory> categories = createInitialCategories(loc);
    await storageService.workCategories.saveEntries(categories);
    initialCategories.addAll(categories);
    // Set isFirstRun to false in storage for future runs, but the in memory value is not updated,
    // so that other part of the app still get the notification that it is the first run.
    await storageService.keyValueStorage.set('isFirstRun', false);
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
