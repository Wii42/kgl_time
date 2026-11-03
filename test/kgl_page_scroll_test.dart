import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/always_filling_scroll_view.dart';
import 'package:kgl_time/pages/kgl_page.dart';
import 'package:material_ui/material_ui.dart';

class _ListPage extends KglPage {
  const _ListPage() : super(appTitle: 'Scrolling page');

  @override
  bool get showSettingsButton => false;

  @override
  Widget body(BuildContext context) => ListView.builder(
    itemCount: 100,
    itemExtent: 64,
    itemBuilder: (context, index) => Text('Entry $index'),
  );
}

class _FittingPage extends KglPage {
  const _FittingPage() : super(appTitle: 'Fitting page');

  @override
  bool get showSettingsButton => false;

  @override
  Widget body(BuildContext context) => const AlwaysFillingScrollView(
    child: Center(child: Text('Fitting content')),
  );
}

void main() {
  testWidgets('fitting body stays still below the fixed app bar', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const MaterialApp(home: _FittingPage()));
    await tester.pumpAndSettle();
    final content = find.text('Fitting content');
    final originalPosition = tester.getTopLeft(content);
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scrollable.position.maxScrollExtent, 0);
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(content), originalPosition);
    expect(scrollable.position.pixels, 0);
  });

  testWidgets('app bar stays visible on tall windows and adapts after resizing', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const MaterialApp(home: _ListPage()));
    await tester.pumpAndSettle();
    final title = find.text('Scrolling page');
    final list = find.byType(ListView);
    final originalTop = tester.getTopLeft(title).dy;

    await tester.drag(list, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(title).dy, originalTop);
    expect(find.text('Entry 0'), findsNothing);

    tester.view.physicalSize = const Size(800, 400);
    await tester.pumpAndSettle();
    await tester.drag(list, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(title, findsNothing);

    tester.view.physicalSize = const Size(800, 900);
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(title).dy, originalTop);
    expect(tester.takeException(), isNull);
  });

  testWidgets('app bar hides with the list and returns before reaching the top', (tester) async {
    tester.view.physicalSize = const Size(800, 400);
    addTearDown(tester.view.resetPhysicalSize);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(appBarTheme: const AppBarTheme(backgroundColor: Colors.green)),
        home: const _ListPage(),
      ),
    );
    await tester.pumpAndSettle();
    final title = find.text('Scrolling page');
    final list = find.byType(ListView);
    expect(tester.getRect(title).bottom, greaterThan(0));

    await tester.drag(list, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(title, findsNothing);
    expect(tester.getTopLeft(list).dy, greaterThanOrEqualTo(24));
    final statusBackground = find.byWidgetPredicate(
      (widget) => widget is ColoredBox && widget.color == Colors.green,
    );
    expect(statusBackground, findsOneWidget);
    expect(tester.getTopLeft(statusBackground).dy, 0);

    await tester.drag(list, const Offset(0, 120));
    await tester.pumpAndSettle();
    expect(tester.getRect(title).top, greaterThanOrEqualTo(0));
    expect(find.text('Entry 0'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
