import 'package:flutter/cupertino.dart';
import 'package:kgl_time/data_model/work_categories.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/pages/kgl_page.dart';
import 'package:kgl_time/select_categories.dart';
import 'package:kgl_time/width_constrained_list_view.dart';
import 'package:kgl_time/work_entry_widgets/work_entry_details.dart';
import 'package:provider/provider.dart';

import 'data_model/work_entries.dart';

class CategoryFilterWidget extends StatefulWidget {
  final WorkCategories categories;
  const CategoryFilterWidget({super.key, required this.categories});

  @override
  State<CategoryFilterWidget> createState() => _CategoryFilterWidgetState();
}

class _CategoryFilterWidgetState extends State<CategoryFilterWidget> {
  late Map<WorkCategory, bool> _selectedCategories;
  @override
  void initState() {
    super.initState();
    _selectedCategories = {for (var e in widget.categories.entries) e: true};
  }

  @override
  Widget build(BuildContext context) {
    _updateCategoriesOnChanged();
    return Column(
      children: [
        SelectCategoriesWidget(
            categories: _selectedCategories,
            onSelectedCategoriesChanged: (categories) {
              setState(() {
                _selectedCategories = categories;
              });
            }),
        Consumer<WorkEntries>(builder: (context, workEntries, _) {
          Iterable<int> selectedCategoryIds = [
            for (var e in idMapSelectedCategories.entries)
              if (e.value) e.key
          ];
          return Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              return WidthConstrainedListView(
                shrinkWrap: true,
                children: [
                  for (var entry in workEntries.entries)
                    if (entry.categories
                        .map((c) => c.id)
                        .any(selectedCategoryIds.contains))
                      WorkEntryDetails(workEntry: entry)
                ],
              );
            }),
          );
        }),
      ],
    );
  }

  void _updateCategoriesOnChanged() {
    if (widget.categories.entries != _selectedCategories.keys) {
      Map<int, bool> idMap = idMapSelectedCategories;
      _selectedCategories = {
        for (var e in widget.categories.entries) e: idMap[e.id] ?? true
      };
    }
  }

  Map<int, bool> get idMapSelectedCategories {
    return {for (var e in _selectedCategories.entries) e.key.id: e.value};
  }
}
