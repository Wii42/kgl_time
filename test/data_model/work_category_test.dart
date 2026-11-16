import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/data_model/work_category.dart';

void main() {
  WorkCategory category(int id) =>
      WorkCategory('Office', icon: CategoryIcon.work, listIndex: 0)..id = id;

  test('live categories and embedded snapshots are unequal in both directions', () {
    final WorkCategory live = category(7);
    final EmbeddedWorkCategory embedded = live.toEmbedded();

    expect(live == embedded, isFalse);
    expect(embedded == live, isFalse);
    expect(<IWorkCategory>[live].contains(embedded), isFalse);
    expect(<IWorkCategory>[embedded].contains(live), isFalse);
  });

  test('equivalent objects retain equal hashes and independent collection lookups', () {
    final WorkCategory live = category(7);
    final WorkCategory liveCopy = WorkCategory.fromJson(live.toJson());
    final EmbeddedWorkCategory embedded = live.toEmbedded();
    final EmbeddedWorkCategory embeddedCopy = EmbeddedWorkCategory.fromJson(embedded.toJson());

    expect(live == liveCopy, isTrue);
    expect(liveCopy == live, isTrue);
    expect(live.hashCode, liveCopy.hashCode);
    expect(embedded == embeddedCopy, isTrue);
    expect(embeddedCopy == embedded, isTrue);
    expect(embedded.hashCode, embeddedCopy.hashCode);

    final Map<IWorkCategory, String> values = <IWorkCategory, String>{
      live: 'live',
      embedded: 'snapshot',
    };
    expect(values, hasLength(2));
    expect(values[liveCopy], 'live');
    expect(values[embeddedCopy], 'snapshot');
    expect(<IWorkCategory>{live, embedded, liveCopy, embeddedCopy}, hasLength(2));
  });

  test('same-named live categories with different IDs remain distinct', () {
    final WorkCategory first = category(7);
    final WorkCategory second = category(8);

    expect(first == second, isFalse);
    expect(second == first, isFalse);
    expect(<WorkCategory>{first, second}, hasLength(2));
  });
}
