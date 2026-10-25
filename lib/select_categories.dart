import 'package:flutter/material.dart';

import 'data_model/work_category.dart';

class SelectCategoriesWidget extends StatelessWidget {
  final Map<WorkCategory, bool> categories;
  final void Function(Map<WorkCategory, bool> selectedCategories) onSelectedCategoriesChanged;

  const SelectCategoriesWidget({
    super.key,
    required this.categories,
    required this.onSelectedCategoriesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: _buildCategoryChips(context),
    );
  }

  List<Widget> _buildCategoryChips(BuildContext context) {
    return [
      for (MapEntry<WorkCategory, bool> element in categories.entries)
        ChoiceChip(
          //avatar: category.icon != null? Icon(category.icon): null,
          label: Text(element.key.displayName),
          selected: element.value,
          onSelected: (selected) {
            Map<WorkCategory, bool> newCategories = Map.from(categories);
            newCategories[element.key] = selected;
            onSelectedCategoriesChanged(newCategories);
          },
        ),
    ];
  }
}