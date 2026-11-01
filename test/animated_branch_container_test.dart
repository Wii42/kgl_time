import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/animated_branch_container.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('default slide follows tab order and reverses without jumping', (tester) async {
    var index = 0;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return AnimatedBranchContainer(
              currentIndex: index,
              duration: const Duration(milliseconds: 200),
              curve: Curves.linear,
              children: const [Text('First'), Text('Middle'), Text('Last')],
            );
          },
        ),
      ),
    );
    double offsetOf(String label) => tester
        .widget<SlideTransition>(
          find
              .ancestor(
                of: find.text(label, skipOffstage: false),
                matching: find.byType(SlideTransition, skipOffstage: false),
              )
              .first,
        )
        .position
        .value
        .dx;

    update(() => index = 2);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(offsetOf('First'), lessThan(0));
    expect(offsetOf('Last'), greaterThan(0));
    final beforeReverse = offsetOf('First');
    update(() => index = 0);
    await tester.pump();
    expect(offsetOf('First'), closeTo(beforeReverse, 0.0001));
    await tester.pumpAndSettle();
    expect(offsetOf('First'), 0);
    expect(offsetOf('Last'), greaterThan(0));

    update(() => index = 2);
    await tester.pumpAndSettle();
    update(() => index = 0);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(offsetOf('First'), lessThan(0));
    expect(offsetOf('Last'), greaterThan(0));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom transitions reverse smoothly and preserve branch state', (tester) async {
    var index = 0;
    var count = 0;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return AnimatedBranchContainer(
              currentIndex: index,
              duration: const Duration(milliseconds: 200),
              curve: Curves.linear,
              transitionBuilder: (context, animation, position, child) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1).animate(animation),
                  child: child,
                ),
              ),
              children: [
                StatefulBuilder(
                  builder: (context, setCount) => TextButton(
                    onPressed: () => setCount(() => count++),
                    child: Text('Count $count'),
                  ),
                ),
                const Text('Second branch'),
              ],
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Count 0'));
    await tester.pumpAndSettle();
    update(() => index = 1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final fades = tester.widgetList<FadeTransition>(find.byType(FadeTransition)).toList();
    expect(fades.where((fade) => (fade.opacity.value - 0.5).abs() < 0.01), hasLength(2));

    // Reverse while both branches are still transitioning.
    update(() => index = 0);
    await tester.pumpAndSettle();
    expect(find.text('Count 1'), findsOneWidget);
    expect(find.text('Second branch'), findsNothing);
    await tester.tap(find.text('Count 1'));
    await tester.pumpAndSettle();
    expect(find.text('Count 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
