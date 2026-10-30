import 'package:material_ui/material_ui.dart';

import 'data_model/work_category.dart';
import 'l10n/generated/app_localizations.dart';

class SelectCategoriesWidget extends StatelessWidget {
  final Map<WorkCategory, bool> categories;
  final void Function(Map<WorkCategory, bool> selectedCategories) onSelectedCategoriesChanged;

  /// Selects if a chip for entries without a category associated should be shown.
  final bool showWithoutCategoryChip;

  /// [isWithoutCategoryChipSelected] should be provided if [showWithoutCategoryChip] is true
  final bool? isWithoutCategoryChipSelected;

  /// [onToggleWithoutCategory] should be provided if [showWithoutCategoryChip] is true
  final void Function(bool isSelected)? onToggleWithoutCategory;

  const SelectCategoriesWidget({
    super.key,
    required this.categories,
    required this.onSelectedCategoriesChanged,
    this.showWithoutCategoryChip = false,
    this.isWithoutCategoryChipSelected,
    this.onToggleWithoutCategory,
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
      if (showWithoutCategoryChip)
        ChoiceChip(
          label: Text(AppLocalizations.of(context)?.withoutCategory ?? "<Without category>"),
          selected: isWithoutCategoryChipSelected ?? false,
          onSelected: onToggleWithoutCategory,
        ),
    ];
  }
}