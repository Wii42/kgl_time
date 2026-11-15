import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/app/kgl_time_app.dart';
import 'package:kgl_time/app/startup_dialogs_gate.dart';
import 'package:kgl_time/l10n/app_locales.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/onboarding/onboarding_controller.dart';
import 'package:kgl_time/onboarding/welcome_dialog.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';
import 'package:kgl_time/whats_new/release_highlight.dart';
import 'package:kgl_time/whats_new/whats_new_controller.dart';
import 'package:kgl_time/whats_new/whats_new_dialog.dart';
import 'package:material_ui/material_ui.dart';

import '../support/memory_storage.dart';

void main() {
  late MemoryKeyValues storage;
  late WhatsNewController controller;
  late GlobalKey<NavigatorState> navigatorKey;

  setUp(() {
    storage = MemoryKeyValues();
    controller = WhatsNewController(storage: storage, isFirstRun: false);
    navigatorKey = GlobalKey<NavigatorState>();
  });

  Future<void> setLastSeen(String version) => storage.set<String>(
    WhatsNewController.lastSeenVersionKey,
    version,
  );

  Future<String?> lastSeen() => storage.get<String>(WhatsNewController.lastSeenVersionKey);

  Future<void> launch(
    WidgetTester tester, {
    String version = '0.4.0',
    Locale locale = const Locale('en'),
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
          whatsNewController: controller,
          onboardingController: OnboardingController(storage: storage),
          currentVersion: version,
          navigatorKey: navigatorKey,
          child: child!,
        ),
        home: const Scaffold(body: Text('Existing app screen')),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('fresh installation shows only the existing screen', (WidgetTester tester) async {
    controller = WhatsNewController(storage: storage, isFirstRun: true);
    await launch(tester);
    expect(find.byType(WhatsNewDialog), findsNothing);
    expect(find.text('Existing app screen'), findsOneWidget);
    expect(await lastSeen(), '0.4.0');
  });

  testWidgets('same app version does not show a dialog', (WidgetTester tester) async {
    await setLastSeen('0.4.0');
    await launch(tester);
    expect(find.byType(WhatsNewDialog), findsNothing);
  });

  testWidgets('update shows a modal over the existing screen and waits for Got it', (
    WidgetTester tester,
  ) async {
    await setLastSeen('0.3.6');
    await launch(tester);
    expect(find.byType(WhatsNewDialog), findsOneWidget);
    expect(find.text('Existing app screen'), findsOneWidget);
    expect(find.text('Backups for your work'), findsOneWidget);
    expect(await lastSeen(), '0.3.6');

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(find.byType(WhatsNewDialog), findsNothing);
    expect(find.text('Existing app screen'), findsOneWidget);
    expect(await lastSeen(), '0.4.0');
  });

  testWidgets('skipped releases produce a single dialog with all eligible highlights', (
    WidgetTester tester,
  ) async {
    controller = WhatsNewController(
      storage: storage,
      isFirstRun: false,
      highlights: const <ReleaseHighlight>[
        ReleaseHighlight(version: '0.4.0', id: HighlightId.jsonBackups),
        ReleaseHighlight(version: '0.5.0', id: HighlightId.jsonBackups),
        ReleaseHighlight(version: '0.6.0', id: HighlightId.jsonBackups),
      ],
    );
    await setLastSeen('0.3.6');
    await launch(tester, version: '0.6.0');
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Backups for your work'), findsNWidgets(3));
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(await lastSeen(), '0.6.0');
  });

  testWidgets('update without highlights advances the baseline without showing a dialog', (
    WidgetTester tester,
  ) async {
    await setLastSeen('0.4.0');
    await launch(tester, version: '0.4.1');
    expect(find.byType(WhatsNewDialog), findsNothing);
    expect(await lastSeen(), '0.4.1');
  });

  testWidgets('disposing before dismissal leaves highlights unseen for the next launch', (
    WidgetTester tester,
  ) async {
    await setLastSeen('0.3.6');
    await launch(tester);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(await lastSeen(), '0.3.6');
    navigatorKey = GlobalKey<NavigatorState>();
    await launch(tester);
    expect(find.byType(WhatsNewDialog), findsOneWidget);
  });

  testWidgets('rebuilding before and after dismissal does not open duplicate dialogs', (
    WidgetTester tester,
  ) async {
    await setLastSeen('0.3.6');
    await launch(tester);
    await launch(tester);
    expect(find.byType(WhatsNewDialog), findsOneWidget);
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    await launch(tester);
    expect(find.byType(WhatsNewDialog), findsNothing);
    expect(await lastSeen(), '0.4.0');
  });

  testWidgets('barrier dismissal also acknowledges the dialog', (WidgetTester tester) async {
    await setLastSeen('0.3.6');
    await launch(tester);
    await tester.tapAt(const Offset(1, 1));
    await tester.pumpAndSettle();
    expect(find.byType(WhatsNewDialog), findsNothing);
    expect(await lastSeen(), '0.4.0');
  });

  testWidgets('downgrade does not show highlights or lower the stored version', (
    WidgetTester tester,
  ) async {
    await setLastSeen('0.5.0');
    await launch(tester);
    expect(find.byType(WhatsNewDialog), findsNothing);
    expect(await lastSeen(), '0.5.0');
  });

  testWidgets('titles, descriptions, and dismissal use the active German locale', (
    WidgetTester tester,
  ) async {
    await setLastSeen('0.3.6');
    await launch(tester, locale: const Locale('de', 'CH'));
    expect(find.text('Was ist neu?'), findsOneWidget);
    expect(find.text('Backups für deine Arbeitsdaten'), findsOneWidget);
    expect(
      find.text(
        'Du kannst deine Einträge und Kategorien jetzt sichern und wiederherstellen – '
        'unter Einstellungen → Export / Import.',
      ),
      findsOneWidget,
    );
    expect(find.text('Verstanden'), findsOneWidget);
    expect(find.text('Got it'), findsNothing);
  });

  testWidgets('localization is resolved again when the locale changes with an open dialog', (
    WidgetTester tester,
  ) async {
    await setLastSeen('0.3.6');
    await launch(tester);
    expect(find.text('Got it'), findsOneWidget);
    await launch(tester, locale: const Locale('de'));
    expect(find.text('Verstanden'), findsOneWidget);
    expect(find.text('Got it'), findsNothing);
    expect(await lastSeen(), '0.3.6');
  });

  testWidgets('five highlights fit a small landscape window with scrollable content', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(568, 320);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    controller = WhatsNewController(
      storage: storage,
      isFirstRun: false,
      highlights: <ReleaseHighlight>[
        for (final int minor in <int>[1, 2, 3, 4, 5, 6])
          ReleaseHighlight(version: '1.$minor.0', id: HighlightId.jsonBackups),
      ],
    );
    await setLastSeen('1.0.0');
    await launch(tester, version: '1.6.0', locale: const Locale('de'));
    expect(find.text('Backups für deine Arbeitsdaten'), findsNWidgets(5));
    expect(tester.widget<AlertDialog>(find.byType(AlertDialog)).scrollable, isTrue);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Verstanden'));
    await tester.pumpAndSettle();
    expect(await lastSeen(), '1.6.0');
  });

  testWidgets('app router integration shows the announcement above its initial screen', (
    WidgetTester tester,
  ) async {
    final MemoryStorage appStorage = MemoryStorage();
    PersistentStorageService.setImplementation(appStorage);
    await appStorage.keyValueStorage.set<String>(WhatsNewController.lastSeenVersionKey, '0.3.6');
    await tester.pumpWidget(
      const KglTimeApp(
        appTitle: 'Test',
        appVersion: '0.4.0',
        initialKeyValueStorage: <String, dynamic>{'isFirstRun': false},
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(WhatsNewDialog), findsOneWidget);
    expect(find.text('Test'), findsWidgets);
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(
      await appStorage.keyValueStorage.get<String>(WhatsNewController.lastSeenVersionKey),
      '0.4.0',
    );
    await tester.pumpWidget(const SizedBox());
    await appStorage.close();
  });

  for (final bool isFirstRun in <bool>[true, false]) {
    testWidgets('app startup without tracking distinguishes first run=$isFirstRun', (
      WidgetTester tester,
    ) async {
      final MemoryStorage appStorage = MemoryStorage();
      PersistentStorageService.setImplementation(appStorage);
      // initializeApp has already persisted false, but preserves the startup
      // value in memory. Reading storage here would misclassify a fresh install.
      await appStorage.keyValueStorage.set<bool>('isFirstRun', false);
      if (isFirstRun) {
        await appStorage.keyValueStorage.set<bool>(OnboardingController.completedKey, false);
      }
      await tester.pumpWidget(
        KglTimeApp(
          appTitle: 'Test',
          appVersion: '0.4.1',
          initialKeyValueStorage: <String, dynamic>{'isFirstRun': isFirstRun},
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(WhatsNewDialog), isFirstRun ? findsNothing : findsOneWidget);
      expect(find.byType(WelcomeDialog), isFirstRun ? findsOneWidget : findsNothing);
      expect(
        await appStorage.keyValueStorage.get<String>(WhatsNewController.lastSeenVersionKey),
        isFirstRun ? '0.4.1' : isNull,
      );
      if (!isFirstRun) {
        expect(find.text('Backups for your work'), findsOneWidget);
        await tester.tap(find.text('Got it'));
        await tester.pumpAndSettle();
        expect(
          await appStorage.keyValueStorage.get<String>(WhatsNewController.lastSeenVersionKey),
          '0.4.1',
        );
      }
      await tester.pumpWidget(const SizedBox());
      await appStorage.close();
    });
  }
}
