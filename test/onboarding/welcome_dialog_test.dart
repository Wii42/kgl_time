import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/app/startup_dialogs_gate.dart';
import 'package:kgl_time/data_model/key_values.dart';
import 'package:kgl_time/l10n/app_locales.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/main.dart' as app;
import 'package:kgl_time/onboarding/onboarding_controller.dart';
import 'package:kgl_time/onboarding/welcome_dialog.dart';
import 'package:kgl_time/pages/settings_page.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';
import 'package:kgl_time/whats_new/release_highlight.dart';
import 'package:kgl_time/whats_new/whats_new_controller.dart';
import 'package:kgl_time/whats_new/whats_new_dialog.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../support/memory_storage.dart';

void main() {
  late MemoryStorage storage;
  late GlobalKey<NavigatorState> navigatorKey;

  setUpAll(() {
    app.appInfo = PackageInfo(
      appName: 'Test',
      packageName: 'test.kgl_time',
      version: '0.4.1',
      buildNumber: '19',
    );
  });

  setUp(() async {
    storage = MemoryStorage();
    PersistentStorageService.setImplementation(storage);
    navigatorKey = GlobalKey<NavigatorState>();
    await storage.keyValueStorage.set<bool>(OnboardingController.completedKey, false);
  });

  tearDown(() async => storage.close());

  Future<bool?> completed() => storage.keyValueStorage.get<bool>(OnboardingController.completedKey);

  Future<void> launch(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    bool isFirstRun = true,
    List<ReleaseHighlight> highlights = releaseHighlights,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        locale: locale,
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: supportedAppLocales,
        builder: (BuildContext context, Widget? child) => StartupDialogsGate(
          onboardingController: OnboardingController(storage: storage.keyValueStorage),
          whatsNewController: WhatsNewController(
            storage: storage.keyValueStorage,
            isFirstRun: isFirstRun,
            highlights: highlights,
          ),
          currentVersion: '0.4.1',
          navigatorKey: navigatorKey,
          child: child!,
        ),
        home: const Scaffold(body: Text('Existing app screen')),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('first launch shows welcome over the app without release highlights', (
    WidgetTester tester,
  ) async {
    await launch(tester);
    expect(find.byType(WelcomeDialog), findsOneWidget);
    expect(find.byType(WhatsNewDialog), findsNothing);
    expect(find.text('Existing app screen'), findsOneWidget);
    expect(await completed(), isFalse);
    expect(
      await storage.keyValueStorage.get<String>(WhatsNewController.lastSeenVersionKey),
      '0.4.1',
    );
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeDialog), findsNothing);
    expect(find.byType(WhatsNewDialog), findsNothing);
  });

  for (final String dismissal in <String>['button', 'outside', 'back']) {
    testWidgets('$dismissal dismissal completes onboarding and prevents another welcome', (
      WidgetTester tester,
    ) async {
      await launch(tester);
      switch (dismissal) {
        case 'button':
          await tester.tap(find.text('Get started'));
        case 'outside':
          await tester.tapAt(const Offset(1, 1));
        case 'back':
          await tester.binding.handlePopRoute();
      }
      await tester.pumpAndSettle();
      expect(await completed(), isTrue);
      expect(find.byType(WelcomeDialog), findsNothing);

      await tester.pumpWidget(const SizedBox());
      navigatorKey = GlobalKey<NavigatorState>();
      await launch(tester, isFirstRun: false, highlights: const <ReleaseHighlight>[]);
      expect(find.byType(WelcomeDialog), findsNothing);
      expect(find.text('Existing app screen'), findsOneWidget);
    });
  }

  testWidgets('closing the app before dismissal shows welcome again on the next launch', (
    WidgetTester tester,
  ) async {
    await launch(tester);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(await completed(), isFalse);

    navigatorKey = GlobalKey<NavigatorState>();
    await launch(tester, isFirstRun: false);
    expect(find.byType(WelcomeDialog), findsOneWidget);
    expect(find.byType(WhatsNewDialog), findsNothing);
    expect(await completed(), isFalse);
  });

  testWidgets('rebuilds do not open duplicate welcome dialogs or reopen a dismissed one', (
    WidgetTester tester,
  ) async {
    await launch(tester);
    await launch(tester);
    expect(find.byType(WelcomeDialog), findsOneWidget);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    await launch(tester);
    expect(find.byType(WelcomeDialog), findsNothing);
    expect(find.byType(WhatsNewDialog), findsNothing);
    expect(await completed(), isTrue);
  });

  testWidgets('existing users without the new completion flag do not see onboarding', (
    WidgetTester tester,
  ) async {
    await storage.keyValueStorage.remove(OnboardingController.completedKey);
    await launch(tester, isFirstRun: false, highlights: const <ReleaseHighlight>[]);
    expect(find.byType(WelcomeDialog), findsNothing);
    expect(await completed(), isNull);
  });

  testWidgets('completed users still receive release highlights', (WidgetTester tester) async {
    await storage.keyValueStorage.set<bool>(OnboardingController.completedKey, true);
    await storage.keyValueStorage.set<String>(WhatsNewController.lastSeenVersionKey, '0.3.6');
    await launch(tester, isFirstRun: false);
    expect(find.byType(WelcomeDialog), findsNothing);
    expect(find.byType(WhatsNewDialog), findsOneWidget);
  });

  for (final Locale locale in <Locale>[const Locale('en'), const Locale('de')]) {
    testWidgets('welcome content is localized in $locale', (WidgetTester tester) async {
      await launch(tester, locale: locale);
      final AppLocalizations loc = AppLocalizations.of(
        tester.element(find.byType(WelcomeDialog)),
      )!;
      expect(
        find.text(locale.languageCode == 'de' ? 'Willkommen bei KGL Time' : 'Welcome to KGL Time'),
        findsOneWidget,
      );
      expect(find.text(loc.welcomeTrackTimeTitle), findsOneWidget);
      expect(find.text(loc.welcomeTrackTimeDescription), findsOneWidget);
      expect(find.text(loc.welcomeCategoriesTitle), findsOneWidget);
      expect(find.text(loc.welcomeCategoriesDescription), findsOneWidget);
      expect(find.text(loc.welcomeBackupsTitle), findsOneWidget);
      expect(find.text(loc.welcomeBackupsDescription), findsOneWidget);
      expect(find.text(loc.welcomeDismiss), findsOneWidget);
    });

    for (final Size size in <Size>[const Size(320, 568), const Size(568, 320)]) {
      testWidgets('welcome scrolls on $size with larger text in $locale', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await launch(tester, locale: locale);
        final AppLocalizations loc = AppLocalizations.of(
          tester.element(find.byType(WelcomeDialog)),
        )!;
        expect(tester.widget<AlertDialog>(find.byType(AlertDialog)).scrollable, isTrue);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text(loc.welcomeDismiss));
        await tester.pumpAndSettle();
        expect(await completed(), isTrue);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Settings can reopen welcome in $locale and dismissal completes it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<KeyValues>(
          create: (BuildContext context) => KeyValues(<String, dynamic>{}),
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[
              ...GlobalMaterialLocalizations.delegates,
              AppLocalizations.delegate,
            ],
            supportedLocales: supportedAppLocales,
            home: const SettingsPage(appTitle: 'Test'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final AppLocalizations loc = AppLocalizations.of(
        tester.element(find.byType(SettingsPage)),
      )!;
      final Finder tile = find.widgetWithText(ListTile, loc.gettingStarted);
      expect((tester.widget<ListTile>(tile).leading! as Icon).icon, Icons.waving_hand_outlined);
      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(find.byType(WelcomeDialog), findsOneWidget);
      await tester.tap(find.text(loc.welcomeDismiss));
      await tester.pumpAndSettle();
      expect(await completed(), isTrue);

      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(find.byType(WelcomeDialog), findsOneWidget);
      await tester.tapAt(const Offset(1, 1));
      await tester.pumpAndSettle();
      expect(find.byType(WelcomeDialog), findsNothing);
      expect(await completed(), isTrue);
    });
  }
}
