import 'package:kgl_time/app_initialization.dart';
import 'package:kgl_time/persistent_storage/isar_persistent_storage.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'kgl_time_app.dart';

late final PackageInfo appInfo;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  InitialAppData data = await initializeApp(storage: IsarPersistentStorage());
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
