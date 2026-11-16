import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/app/app_initialization.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'support/memory_storage.dart';

void main() {
  final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    PackageInfo.setMockInitialValues(
      appName: 'Test',
      packageName: 'test.kgl_time',
      version: '0.4.1',
      buildNumber: '19',
      buildSignature: '',
    );
  });

  for (final (Locale locale, List<String> names) in <(Locale, List<String>)>[
    (const Locale('en'), <String>['Planning', 'Meetings', 'Administration']),
    (const Locale('de'), <String>['Planung', 'Besprechungen', 'Verwaltung']),
    (const Locale('fr'), <String>['Planning', 'Meetings', 'Administration']),
  ]) {
    test('first startup persists categories in the app language for $locale', () async {
      final MemoryStorage storage = MemoryStorage();
      addTearDown(storage.close);
      binding.platformDispatcher.localesTestValue = <Locale>[locale];
      addTearDown(binding.platformDispatcher.clearLocalesTestValue);

      final InitialAppData data = await initializeApp(storage: storage);
      expect(data.categories.map((WorkCategory category) => category.displayName), names);
      expect(data.categories.map((WorkCategory category) => category.listIndex), <int>[0, 1, 2]);
      expect(
        (await storage.workCategories.loadEntries()).map(
          (WorkCategory category) => category.displayName,
        ),
        names,
      );

      binding.platformDispatcher.localesTestValue = <Locale>[const Locale('de', 'CH')];
      final InitialAppData nextLaunch = await initializeApp(storage: storage);
      expect(nextLaunch.categories.map((WorkCategory category) => category.displayName), names);
    });
  }
}
