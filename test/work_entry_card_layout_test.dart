import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kgl_time/app_route.dart';
import 'package:kgl_time/data_model/work_entry.dart';
import 'package:kgl_time/kgl_time_app.dart';
import 'package:kgl_time/persistent_storage/persistent_storage_service.dart';
import 'package:material_ui/material_ui.dart';

import 'support/memory_storage.dart';

void main() {
  setUpAll(() => initializeDateFormatting('en'));

  testWidgets('entry cards share centered horizontal bounds across pages and resizing', (
    tester,
  ) async {
    final storage = MemoryStorage();
    PersistentStorageService.setImplementation(storage);
    addTearDown(storage.close);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      KglTimeApp(
        appTitle: 'Test',
        initialEntries: [
          WorkEntry.fromDuration(
            duration: const Duration(minutes: 30),
            date: DateTime(2026, 10, 30),
            description: 'Layout fixture',
          )..id = 1,
        ],
      ),
    );
    await tester.pumpAndSettle();
    final router = tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig! as GoRouter;

    // Exercise both sides of the page-width limit, plus landscape -> portrait
    // on the same mounted app. No golden images or text metrics are involved.
    for (final size in [
      const Size(390, 844),
      const Size(844, 390),
      const Size(390, 844),
      const Size(799, 1000),
      const Size(800, 1000),
      const Size(801, 1000),
      const Size(1200, 1000),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      Rect? homeCard;
      for (final route in NavBarAppRoute.navBarItems) {
        router.go(route.path);
        await tester.pumpAndSettle();
        final card = find.byType(Card);
        expect(card, findsOneWidget);
        // Measure the painted surface, excluding Card's external margin.
        final surface = find.descendant(of: card, matching: find.byType(Material)).first;
        final bounds = tester.getRect(surface);
        final reason = '${route.path} at $size';
        expect(bounds.left, closeTo(size.width - bounds.right, 0.01), reason: reason);
        if (homeCard == null) {
          homeCard = bounds;
        } else {
          expect(bounds.left, closeTo(homeCard.left, 0.01), reason: reason);
          expect(bounds.right, closeTo(homeCard.right, 0.01), reason: reason);
        }
        expect(tester.takeException(), isNull, reason: reason);
      }
    }
  });
}
