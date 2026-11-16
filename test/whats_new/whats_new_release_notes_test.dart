import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/app/startup_dialogs_gate.dart';
import 'package:kgl_time/data_model/key_values.dart';
import 'package:kgl_time/l10n/app_locales.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/main.dart' as app;
import 'package:kgl_time/onboarding/onboarding_controller.dart';
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
  const MethodChannel launcherChannel = MethodChannel('plugins.flutter.io/url_launcher');
  final List<MethodCall> launches = <MethodCall>[];
  late MemoryKeyValues storage;

  setUpAll(() {
    app.appInfo = PackageInfo(
      appName: 'Test',
      packageName: 'test.kgl_time',
      version: '0.4.1',
      buildNumber: '19',
    );
  });

  setUp(() {
    storage = MemoryKeyValues();
    launches.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      launcherChannel,
      (MethodCall call) async {
        if (call.method == 'launch') launches.add(call);
        return true;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      launcherChannel,
      null,
    );
  });

  Future<void> launch(WidgetTester tester, Locale locale) async {
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    final WhatsNewController controller = WhatsNewController(storage: storage, isFirstRun: false);
    await storage.set<String>(WhatsNewController.lastSeenVersionKey, '0.3.6');
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
          whatsNewController: controller,
          onboardingController: OnboardingController(storage: storage),
          currentVersion: '0.4.0',
          navigatorKey: navigatorKey,
          child: child!,
        ),
        home: const Scaffold(body: Text('Existing app screen')),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> launchSettings(
    WidgetTester tester,
    Locale locale, {
    String? lastSeenVersion,
  }) async {
    final MemoryStorage appStorage = MemoryStorage();
    PersistentStorageService.setImplementation(appStorage);
    storage = appStorage.keyValueStorage;
    if (lastSeenVersion != null) {
      await storage.set<String>(WhatsNewController.lastSeenVersionKey, lastSeenVersion);
    }
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
    addTearDown(appStorage.close);
  }

  for (final Locale locale in <Locale>[const Locale('en'), const Locale('de')]) {

    testWidgets('release notes open externally without acknowledging the dialog in $locale', (
      WidgetTester tester,
    ) async {
      await launch(tester, locale);
      final AppLocalizations loc = AppLocalizations.of(
        tester.element(find.byType(WhatsNewDialog)),
      )!;
      expect(
        find.text(locale.languageCode == 'de' ? 'Versionshinweise' : 'Release notes'),
        findsOneWidget,
      );
      await tester.tap(find.text(loc.whatsNewReleaseNotes));
      await tester.pumpAndSettle();

      expect(launches, hasLength(1));
      expect(
        launches.single.arguments,
        containsPair('url', 'https://github.com/Wii42/kgl_time/blob/main/CHANGELOG.md#v0.4.0'),
      );
      expect(launches.single.arguments, containsPair('useWebView', false));
      expect(launches.single.arguments, containsPair('useSafariVC', false));
      expect(find.byType(WhatsNewDialog), findsOneWidget);
      expect(await storage.get<String>(WhatsNewController.lastSeenVersionKey), '0.3.6');

      await tester.tap(find.text(loc.whatsNewDismiss));
      await tester.pumpAndSettle();
      expect(find.byType(WhatsNewDialog), findsNothing);
      expect(await storage.get<String>(WhatsNewController.lastSeenVersionKey), '0.4.0');
    });

    testWidgets('release notes and dismissal fit a small landscape window in $locale', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(568, 320);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await launch(tester, locale);
      final AppLocalizations loc = AppLocalizations.of(
        tester.element(find.byType(WhatsNewDialog)),
      )!;
      expect(tester.takeException(), isNull);
      await tester.tap(find.text(loc.whatsNewReleaseNotes));
      await tester.pumpAndSettle();
      expect(launches, hasLength(1));
      expect(find.byType(WhatsNewDialog), findsOneWidget);
      await tester.tap(find.text(loc.whatsNewDismiss));
      await tester.pumpAndSettle();
      expect(find.byType(WhatsNewDialog), findsNothing);
      expect(tester.takeException(), isNull);
    });

    for (final String? lastSeenVersion in <String?>['0.4.1', null]) {
      testWidgets('Settings reopens recent highlights in $locale with last seen $lastSeenVersion', (
        WidgetTester tester,
      ) async {
        await launchSettings(tester, locale, lastSeenVersion: lastSeenVersion);
        final AppLocalizations loc = AppLocalizations.of(
          tester.element(find.byType(SettingsPage)),
        )!;
        final Finder tile = find.widgetWithText(ListTile, loc.whatsNew);

        await tester.ensureVisible(tile);
        await tester.pumpAndSettle();
        await tester.tap(tile);
        await tester.pumpAndSettle();
        expect(find.byType(WhatsNewDialog), findsOneWidget);
        expect(find.text(loc.highlightJsonBackupsTitle), findsOneWidget);
        expect(tester.widget<WhatsNewDialog>(find.byType(WhatsNewDialog)).currentVersion, '0.4.1');

        await tester.tap(find.text(loc.whatsNewReleaseNotes));
        await tester.pumpAndSettle();
        expect(
          launches.single.arguments,
          containsPair('url', 'https://github.com/Wii42/kgl_time/blob/main/CHANGELOG.md#v0.4.1'),
        );
        expect(find.byType(WhatsNewDialog), findsOneWidget);
        await tester.tap(find.text(loc.whatsNewDismiss));
        await tester.pumpAndSettle();
        expect(await storage.get<String>(WhatsNewController.lastSeenVersionKey), lastSeenVersion);

        await tester.tap(tile);
        await tester.pumpAndSettle();
        expect(find.byType(WhatsNewDialog), findsOneWidget);
        await tester.tap(find.text(loc.whatsNewDismiss));
        await tester.pumpAndSettle();
        expect(await storage.get<String>(WhatsNewController.lastSeenVersionKey), lastSeenVersion);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('empty manual dialog still offers localized release notes in $locale', (
      WidgetTester tester,
    ) async {
      await launchSettings(tester, locale);
      final BuildContext context = tester.element(find.byType(SettingsPage));
      final AppLocalizations loc = AppLocalizations.of(context)!;
      final Future<void> dismissed = showDialog<void>(
        context: context,
        builder: (BuildContext context) => const WhatsNewDialog(
          highlights: <ReleaseHighlight>[],
          currentVersion: '0.4.1',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(loc.whatsNewNoHighlights), findsOneWidget);
      await tester.tap(find.text(loc.whatsNewReleaseNotes));
      await tester.pumpAndSettle();
      expect(
        launches.single.arguments,
        containsPair('url', 'https://github.com/Wii42/kgl_time/blob/main/CHANGELOG.md#v0.4.1'),
      );
      expect(find.byType(WhatsNewDialog), findsOneWidget);
      await tester.tap(find.text(loc.whatsNewDismiss));
      await tester.pumpAndSettle();
      await dismissed;
      expect(await storage.get<String>(WhatsNewController.lastSeenVersionKey), isNull);
    });
  }
}
