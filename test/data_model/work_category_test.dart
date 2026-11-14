import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/data_model/work_category.dart';

void main() {
  test('equality is symmetric between a category and its embedded copy', () {
    final WorkCategory category = WorkCategory(
      'Office',
      uuid: 'category-a',
      lastEdit: DateTime.utc(2020),
      listIndex: 0,
    )..id = 7;
    final EmbeddedWorkCategory embedded = category.toEmbedded();

    // Both equality directions must agree, whether cross-type equality is supported or not.
    expect(embedded == category, category == embedded);
    if (category == embedded) {
      expect(category.hashCode, embedded.hashCode);
    }
  });
}
