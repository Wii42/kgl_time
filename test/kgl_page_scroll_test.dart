import 'package:flutter_test/flutter_test.dart';
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

void main() {
  testWidgets('app bar hides with the list and returns before reaching the top', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _ListPage()));
    await tester.pumpAndSettle();
    final title = find.text('Scrolling page');
    final list = find.byType(ListView);
    expect(tester.getRect(title).bottom, greaterThan(0));

    await tester.drag(list, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(title, findsNothing);

    await tester.drag(list, const Offset(0, 120));
    await tester.pumpAndSettle();
    expect(tester.getRect(title).top, greaterThanOrEqualTo(0));
    expect(find.text('Entry 0'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
