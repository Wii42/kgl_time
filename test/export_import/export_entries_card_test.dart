import 'dart:typed_data';

import 'package:flutter/foundation.dart' show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter/services.dart' show MethodCall, MethodChannel;
import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/export_import/export_entries_card.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  const List<(TargetPlatform, bool, bool)> platforms = [
    (TargetPlatform.android, true, true),
    (TargetPlatform.iOS, true, true),
    (TargetPlatform.macOS, false, true),
    (TargetPlatform.windows, false, true),
    (TargetPlatform.linux, false, false),
    (TargetPlatform.fuchsia, false, false),
  ];

  for (final (TargetPlatform platform, bool canSave, bool canShare) in platforms) {
    testWidgets('export availability and hints on ${platform.name}', (WidgetTester tester) async {
      int filesCreated = 0;
      debugDefaultTargetPlatformOverride = platform;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: ExportEntriesCard(
              title: (AppLocalizations? loc) => loc!.exportImportEntries,
              createFile: () {
                filesCreated++;
                return (content: Uint8List.fromList(<int>[1, 2, 3]), fileName: 'test.csv');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final TextButton saveButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Save locally'),
      );
      final TextButton shareButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Share'),
      );
      expect(saveButton.onPressed, canSave ? isNotNull : isNull);
      expect(shareButton.onPressed, canShare ? isNotNull : isNull);
      expect(
        find.text('Saving files is not supported on this platform.'),
        canSave ? findsNothing : findsOneWidget,
      );
      expect(
        find.text('Sharing files is not supported on this platform.'),
        canShare ? findsNothing : findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      expect(filesCreated, 0);
    });
  }

  testWidgets('saving creates current contents and filename on every press', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    const MethodChannel channel = MethodChannel('flutter_file_dialog');
    final List<Map<Object?, Object?>> saved = <Map<Object?, Object?>>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall call) async {
        expect(call.method, 'saveFile');
        saved.add(call.arguments as Map<Object?, Object?>);
        return '/saved/export.csv';
      },
    );
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    int revision = 1;
    int filesCreated = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExportEntriesCard(
            title: (AppLocalizations? loc) => 'Export',
            createFile: () {
              filesCreated++;
              return (
                content: Uint8List.fromList(<int>[revision]),
                fileName: 'export_$revision.csv',
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(filesCreated, 0);
    for (final int current in <int>[2, 3]) {
      revision = current;
      await tester.tap(find.widgetWithText(TextButton, '<save locally>'));
      await tester.pumpAndSettle();
      expect(saved.last['fileName'], 'export_$current.csv');
      expect(saved.last['data'], <int>[current]);
    }
    expect(filesCreated, 2);
    expect(tester.takeException(), isNull);
  });

  for (final (String button, String failure) in <(String, String)>[
    ('<save locally>', '<Failed to save file.>'),
    ('<share>', '<Failed to share file.>'),
  ]) {
    testWidgets('$button reports file generation failure when pressed', (
      WidgetTester tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      int filesCreated = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportEntriesCard(
              title: (AppLocalizations? loc) => 'Export',
              createFile: () {
                filesCreated++;
                throw StateError('Cannot create export');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(filesCreated, 0);
      await tester.tap(find.widgetWithText(TextButton, button));
      await tester.pumpAndSettle();
      expect(filesCreated, 1);
      expect(find.text(failure), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
