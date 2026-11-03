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

class _SizedPage extends KglPage {
  final ValueNotifier<double> contentHeight;

  const _SizedPage(this.contentHeight) : super(appTitle: 'Sized page');

  @override
  bool get showSettingsButton => false;

  @override
  Widget body(BuildContext context) => ValueListenableBuilder<double>(
    valueListenable: contentHeight,
    builder: (context, height, _) => AlwaysFillingScrollView(
      child: SizedBox(height: height, child: const Text('Resizable content')),
    ),
  );
}

void main() {
  testWidgets('adapts to content changes and resizing without losing the body state', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 700);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final height = ValueNotifier<double>(100);
    addTearDown(height.dispose);
    await tester.pumpWidget(MaterialApp(home: _SizedPage(height)));
    await tester.pumpAndSettle();
    final scroll = find.byType(SingleChildScrollView);
    final bodyState = tester.state(find.descendant(of: scroll, matching: find.byType(Scrollable)));
    SliverAppBar bar() => tester.widget<SliverAppBar>(find.byType(SliverAppBar));
    expect(bar().pinned, isTrue);
    height.value = 660; // Only 16 pixels taller than the body with the toolbar visible.
    await tester.pumpAndSettle();
    expect(bar().floating, isTrue);
    await tester.drag(scroll, const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(find.text('Sized page'), findsNothing);
    expect(
      tester.state(find.descendant(of: scroll, matching: find.byType(Scrollable))),
      same(bodyState),
    );
    await tester.drag(scroll, const Offset(0, 200));
    await tester.pumpAndSettle();
    height.value = 100;
    await tester.pumpAndSettle();
    expect(bar().pinned, isTrue);
    expect(find.text('Sized page'), findsOneWidget);
    height.value = 660;
    await tester.pumpAndSettle();
    expect(bar().floating, isTrue);
    tester.view.physicalSize = const Size(800, 900);
    await tester.pumpAndSettle();
    expect(bar().pinned, isTrue);
    tester.view.physicalSize = const Size(800, 400);
    await tester.pumpAndSettle();
    expect(bar().floating, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fitting body stays still below the fixed app bar', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const MaterialApp(home: _FittingPage()));
    await tester.pumpAndSettle();
    final content = find.text('Fitting content');
    final originalPosition = tester.getTopLeft(content);
    final scrollable = tester.state<ScrollableState>(
      find.descendant(of: find.byType(SingleChildScrollView), matching: find.byType(Scrollable)),
    );
    expect(scrollable.position.maxScrollExtent, 0);
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(content), originalPosition);
    expect(scrollable.position.pixels, 0);
  });

  testWidgets('overflowing body hides the app bar even on tall windows', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const MaterialApp(home: _ListPage()));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Scrolling page'), findsNothing);
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
