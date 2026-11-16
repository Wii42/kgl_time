import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/app/animated_branch_container.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('default slide follows tab order and reverses without jumping', (
    WidgetTester tester,
  ) async {
    int index = 0;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
    final double beforeReverse = offsetOf('First');
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

  testWidgets('branch-local state survives completed and interrupted tab switches', (
    WidgetTester tester,
  ) async {
    int index = 0;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            update = setState;
            return AnimatedBranchContainer(
              currentIndex: index,
              duration: const Duration(milliseconds: 200),
              curve: Curves.linear,
              children: const <Widget>[
                _Counter(),
                Text('Second branch'),
              ],
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Count 0'));
    await tester.pumpAndSettle();
    update(() => index = 1);
    await tester.pumpAndSettle();
    expect(find.text('Second branch'), findsOneWidget);
    expect(find.text('Count 1'), findsNothing);
    update(() => index = 0);
    await tester.pumpAndSettle();
    expect(find.text('Count 1'), findsOneWidget);

    update(() => index = 1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

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

class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => setState(() => _count++),
    child: Text('Count $_count'),
  );
}
