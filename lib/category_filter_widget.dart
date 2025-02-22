import 'package:flutter/cupertino.dart';
import 'package:kgl_time/data_model/work_categories.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/hover_controls.dart';
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
  final GlobalKey _controlsKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    _selectedCategories = {for (var e in widget.categories.entries) e: true};
  }

  @override
  Widget build(BuildContext context) {
    _updateCategoriesOnChanged();
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
            }),
      ),
      builder: (_, controlsHeight) {
        return Consumer<WorkEntries>(builder: (context, workEntries, _) {
          Iterable<int> selectedCategoryIds = [
            for (var e in idMapSelectedCategories.entries)
              if (e.value) e.key
          ];
          return WidthConstrainedListView(
            shrinkWrap: true,
            children: [
              SizedBox(height: controlsHeight),
              for (var entry in workEntries.entries)
                if (entry.categories
                    .map((c) => c.id)
                    .any(selectedCategoryIds.contains))
                  WorkEntryDetails(workEntry: entry)
            ],
          );
        });
      },
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
