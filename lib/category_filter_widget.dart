import 'package:animated_list_plus/transitions.dart';
import 'package:collection/collection.dart';
import 'package:kgl_time/data_model/work_categories.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/hover_controls.dart';
import 'package:kgl_time/select_categories.dart';
import 'package:kgl_time/width_constrained_list_view.dart';
import 'package:kgl_time/work_entry_widgets/work_entry_details.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'data_model/work_entries.dart';
import 'data_model/work_entry.dart';
import 'l10n/generated/app_localizations.dart';

class CategoryFilterWidget extends StatefulWidget {
  final WorkCategories categories;
  const CategoryFilterWidget({super.key, required this.categories});

  @override
  State<CategoryFilterWidget> createState() => _CategoryFilterWidgetState();
}

class _CategoryFilterWidgetState extends State<CategoryFilterWidget> {
  late Map<WorkCategory, bool> _selectedCategories;
  final GlobalKey _controlsKey = GlobalKey();
  bool isWithoutCategoryChipSelected = true;
  @override
  void initState() {
    super.initState();
    _selectedCategories = {for (var e in widget.categories.entries) e: true};
  }

  @override
  void didUpdateWidget(covariant CategoryFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateCategoriesOnChanged();
  }

  @override
  Widget build(BuildContext context) {
    return HoverControls(
      controlsKey: _controlsKey,
      hoveringControls: Padding(
        key: _controlsKey,
        padding: const EdgeInsets.all(8.0),
        child: SelectCategoriesWidget(
          categories: _selectedCategories,
          onSelectedCategoriesChanged: (categories) {
            setState(() {
              _selectedCategories = categories;
            });
          },
          showWithoutCategoryChip: true,
          isWithoutCategoryChipSelected: isWithoutCategoryChipSelected,
          onToggleWithoutCategory: (bool isSelected) {
            setState(() {
              isWithoutCategoryChipSelected = isSelected;
            });
          },
        ),
      ),
      builder: (_, controlsHeight) {
        return Consumer<WorkEntries>(
          builder: (context, workEntries, _) {
            Iterable<int> selectedCategoryIds = [
              for (var e in _selectedCategories.entries)
                if (e.value) e.key.id,
            ];
            List<WorkEntry> filteredEntries = workEntries.entries
                .where(
              (entry) {
                bool isInSelectedCategory = entry.categories
                    .map((c) => c.id)
                    .any(selectedCategoryIds.contains);
                if (isInSelectedCategory) {
                  return true;
                }
                if (entry.categories.isEmpty && isWithoutCategoryChipSelected) {
                  return true;
                }
                return false;
              },
            )
                .toList();

            if (filteredEntries.isNotEmpty) {
              return AnimatedWidthConstrainedListView<WorkEntry>(
                shrinkWrap: true,
                items: filteredEntries,
                itemBuilder:
                    (
                      BuildContext context,
                      Animation<double> animation,
                      WorkEntry entry,
                      int index,
                    ) {
                      return SizeFadeTransition(
                        animation: animation,
                        axis: Axis.vertical,
                        child: WorkEntryDetails(workEntry: entry, key: ValueKey(entry.id)),
                      );
                    },
                areItemsTheSame: (WorkEntry oldItem, WorkEntry newItem) => oldItem.id == newItem.id,
                padding: EdgeInsetsGeometry.only(top: controlsHeight),
              );
            }
            return Center(
              child: Text(AppLocalizations.of(context)?.noMatchingEntries ?? '<noMatchingEntries>'),
            );
          },
        );
      },
    );
  }

  void _updateCategoriesOnChanged() {
    const IterableEquality<WorkCategory> equality = IterableEquality();
    if (!equality.equals(widget.categories.entries, _selectedCategories.keys)) {
      Map<int, bool> idMap = {for (final e in _selectedCategories.entries) e.key.id: e.value};
      _selectedCategories = {for (var e in widget.categories.entries) e: idMap[e.id] ?? true};
    }
  }
}
