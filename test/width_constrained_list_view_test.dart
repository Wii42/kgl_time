import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/kgl_time_app.dart';
import 'package:kgl_time/width_constrained_list_view.dart';

void main() {
  for (final useBuilder in [false, true]) {
    final constructor = useBuilder ? 'builder' : 'children';

    for (final cacheExtent in <double?>[0, 300, null]) {
      testWidgets('$constructor lays out the configured cache and scrolls in both directions '
          '(cacheExtent: $cacheExtent)', (tester) async {
        final controller = ScrollController();
        addTearDown(controller.dispose);
        final laidOut = <int>{};
        Widget item(int index) => LayoutBuilder(
          builder: (context, constraints) {
            laidOut.add(index);
            return Text('Row $index', key: ValueKey(index));
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 200,
                child: useBuilder
                    ? WidthConstrainedListView.builder(
                        controller: controller,
                        cacheExtent: cacheExtent,
                        itemExtent: 50,
                        itemCount: 40,
                        itemBuilder: (context, index) => item(index),
                      )
                    : WidthConstrainedListView(
                        controller: controller,
                        cacheExtent: cacheExtent,
                        itemExtent: 50,
                        children: List.generate(40, item),
                      ),
              ),
            ),
          ),
        );

        // Row 8 is outside the viewport, but inside a 250px default or 300px cache.
        expect(laidOut, containsAll([0, 1, 2, 3]));
        expect(laidOut.contains(8), cacheExtent != 0);
        // Distinguish the explicit 300px cache from Flutter's 250px default.
        expect(laidOut.contains(9), cacheExtent == 300);
        expect(laidOut, isNot(contains(15)));
        expect(controller.position.maxScrollExtent, 1800);

        controller.jumpTo(600);
        await tester.pump();
        expect(tester.getCenter(find.byKey(const ValueKey(12))).dy, 25);
        expect(laidOut, contains(12));

        controller.jumpTo(0);
        await tester.pump();
        expect(tester.getCenter(find.byKey(const ValueKey(0))).dy, 25);
        expect(tester.takeException(), isNull);
      });
    }

    for (final width in [320.0, 1200.0]) {
      testWidgets('$constructor centers rows and preserves padding at width $width', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        const rowKey = ValueKey('row');
        const row = SizedBox(key: rowKey, width: double.infinity, height: 50);
        const padding = EdgeInsets.fromLTRB(8, 10, 24, 20);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: useBuilder
                  ? WidthConstrainedListView.builder(
                      padding: padding,
                      itemCount: 1,
                      itemBuilder: (context, index) => row,
                    )
                  : WidthConstrainedListView(padding: padding, children: const [row]),
            ),
          ),
        );

        final availableWidth = width - 64; // 16px added to each supplied side.
        final expectedWidth = availableWidth.clamp(0.0, KglTimeApp.maxPageWidth);
        final rect = tester.getRect(find.byKey(rowKey));
        expect(rect.width, expectedWidth);
        expect(rect.left, 24 + (availableWidth - expectedWidth) / 2);
        expect(rect.top, 10);
        expect(rect.height, 50);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
