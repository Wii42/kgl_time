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
    return Theme(
      data: chipTheme(context),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: _buildCategoryChips(context),
      ),
    );
  }

  List<Widget> _buildCategoryChips(BuildContext context) {
    return [
      for (MapEntry<WorkCategory, bool> element in categories.entries)
        FilterChip(
          //avatar: category.icon != null? Icon(category.icon): null,
          showCheckmark: false,
          label: Text(element.key.displayName),
          selected: element.value,
          onSelected: (selected) {
            Map<WorkCategory, bool> newCategories = Map.from(categories);
            newCategories[element.key] = selected;
            onSelectedCategoriesChanged(newCategories);
          },
        ),
      if (showWithoutCategoryChip)
        FilterChip(
          showCheckmark: false,
          label: Text(AppLocalizations.of(context)?.withoutCategory ?? "<Without category>"),
          selected: isWithoutCategoryChipSelected ?? false,
          onSelected: onToggleWithoutCategory,
        ),
    ];
  }

  ThemeData chipTheme(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color selectedChipColor = isDark
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.primary;

    final Color selectedChipLabelColor = isDark
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onPrimary;
    final Color unselectedChipLabelColor = theme.colorScheme.onSurface;
    theme = theme.copyWith(
      chipTheme: theme.chipTheme.copyWith(
        selectedColor: selectedChipColor,
        secondarySelectedColor: selectedChipColor,
        backgroundColor:
            theme.dialogTheme.backgroundColor ?? theme.colorScheme.surfaceContainerHigh,
        checkmarkColor: selectedChipLabelColor,
        labelStyle: TextStyle(
          color: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? selectedChipLabelColor
                : unselectedChipLabelColor,
          ),
        ),
        side: WidgetStateBorderSide.resolveWith(
          (states) => BorderSide(
            width: 1,
            color: states.contains(WidgetState.selected)
                ? Colors.transparent
                : theme.colorScheme.outline,
          ),
        ),
      ),
    );

    return theme;
  }
}