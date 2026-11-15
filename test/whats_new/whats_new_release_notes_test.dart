import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/l10n/app_locales.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/whats_new/whats_new_controller.dart';
import 'package:kgl_time/whats_new/whats_new_dialog.dart';
import 'package:kgl_time/whats_new/whats_new_gate.dart';
import 'package:material_ui/material_ui.dart';

import '../support/memory_storage.dart';

void main() {
  const MethodChannel launcherChannel = MethodChannel('plugins.flutter.io/url_launcher');
  final List<MethodCall> launches = <MethodCall>[];
  late MemoryKeyValues storage;

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
        builder: (BuildContext context, Widget? child) => WhatsNewGate(
          controller: controller,
          currentVersion: '0.4.0+18',
          navigatorKey: navigatorKey,
          child: child!,
        ),
        home: const Scaffold(body: Text('Existing app screen')),
      ),
    );
    await tester.pumpAndSettle();
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
        containsPair('url', 'https://github.com/Wii42/kgl_time/blob/main/README.md#v040'),
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
  }
}
