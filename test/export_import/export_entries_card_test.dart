import 'dart:typed_data';

import 'package:flutter/foundation.dart' show TargetPlatform, debugDefaultTargetPlatformOverride;
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
      debugDefaultTargetPlatformOverride = platform;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: ExportEntriesCard(
              title: (AppLocalizations? loc) => loc!.exportEntries,
              fileContent: Uint8List.fromList([1, 2, 3]),
              fileName: 'test.csv',
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
    });
  }
}
