import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/hover_controls.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  const Key firstItemKey = ValueKey<String>('first item');

  Widget listBuilder(BuildContext context, double controlsHeight) => ListView(
    padding: EdgeInsets.only(top: controlsHeight),
    children: const <Widget>[SizedBox(key: firstItemKey, height: 100)],
  );

  void expectClearance(WidgetTester tester, GlobalKey controlsKey, double height) {
    final Rect controls = tester.getRect(find.byKey(controlsKey));
    expect(controls.height, height);
    expect(tester.getTopLeft(find.byKey(firstItemKey)).dy, closeTo(controls.bottom, 0.01));
    expect(tester.takeException(), isNull);
  }

  testWidgets('list clearance follows controls growing and shrinking', (WidgetTester tester) async {
    final GlobalKey controlsKey = GlobalKey();
    final ValueNotifier<double> height = ValueNotifier<double>(40);
    addTearDown(height.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HoverControls(
            controlsKey: controlsKey,
            hoveringControls: ValueListenableBuilder<double>(
              valueListenable: height,
              builder: (BuildContext context, double value, Widget? child) =>
                  SizedBox(key: controlsKey, height: value, width: 200),
            ),
            builder: listBuilder,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expectClearance(tester, controlsKey, 40);

    height.value = 120;
    await tester.pumpAndSettle();
    expectClearance(tester, controlsKey, 120);

    height.value = 30;
    await tester.pumpAndSettle();
    expectClearance(tester, controlsKey, 30);
  });

  testWidgets('list clearance follows controls wrapping after viewport resize', (
    WidgetTester tester,
  ) async {
    final GlobalKey controlsKey = GlobalKey();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(600, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HoverControls(
            controlsKey: controlsKey,
            hoveringControls: Wrap(
              key: controlsKey,
              children: List<Widget>.generate(
                3,
                (int index) => const SizedBox(width: 150, height: 40),
              ),
            ),
            builder: listBuilder,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expectClearance(tester, controlsKey, 40);

    tester.view.physicalSize = const Size(320, 800);
    await tester.pumpAndSettle();
    expectClearance(tester, controlsKey, 80);

    tester.view.physicalSize = const Size(600, 800);
    await tester.pumpAndSettle();
    expectClearance(tester, controlsKey, 40);
  });
}
