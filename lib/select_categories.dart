import 'package:flutter/material.dart';
import 'package:kgl_time/data_model/key_values.dart';
import 'package:kgl_time/data_model/work_categories.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import 'data_model/work_category.dart';

class SelectCategoriesWidget extends StatelessWidget {
  final Map<WorkCategory, bool> categories;
  final void Function(Map<WorkCategory, bool> selectedCategories)
      onSelectedCategoriesChanged;

  const SelectCategoriesWidget(
      {super.key,
      required this.categories,
      required this.onSelectedCategoriesChanged});

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

  static void showSelectCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return SelectCategoryDialog();
      },
    );
  }
}

class SelectCategoryDialog extends StatefulWidget {
  static const String storageKey = 'timeTrackerCategories';

  const SelectCategoryDialog({super.key});

  @override
  State<SelectCategoryDialog> createState() => _SelectCategoryDialogState();

  static String serializeCategories(Map<WorkCategory, bool> categories) {
    return categories.entries
        .where((element) => element.value)
        .map((e) => e.key.id)
        .join(',');
  }

  static List<WorkCategory> deserializeCategories(
      String serialized, List<WorkCategory> allCategories) {
    List<String> ids = serialized.split(',');
    List<int> idInts = ids.map((e) => int.tryParse(e)).nonNulls.toList();
    return allCategories
        .where((element) => idInts.contains(element.id))
        .toList();
  }
}

class _SelectCategoryDialogState extends State<SelectCategoryDialog> {
  Map<WorkCategory, bool> selectedCategories = {};

  @override
  Widget build(BuildContext context) {
    AppLocalizations? loc = AppLocalizations.of(context);
    return Consumer2<WorkCategories, KeyValues>(
      builder: (BuildContext context, WorkCategories categories,
          KeyValues keyValues, _) {
        String? serializedCategories =
            keyValues.get<String>(SelectCategoryDialog.storageKey);
        List<WorkCategory> storedCategories = [];
        if (serializedCategories != null) {
          storedCategories = SelectCategoryDialog.deserializeCategories(
              serializedCategories, categories.entries);
        }
        selectedCategories = Map.fromIterable(categories.entries,
            value: (e) =>
                selectedCategories[e] ?? storedCategories.contains(e));

        return AlertDialog(
          title: Text(loc?.selectCategory ?? ''),
          content: SelectCategoriesWidget(
              categories: selectedCategories,
              onSelectedCategoriesChanged: (categories) {
                setState(() {
                  selectedCategories = categories;
                });
              }),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc?.cancel ?? ''),
            ),
            ElevatedButton(
              onPressed: () {
                keyValues.set(
                    SelectCategoryDialog.storageKey,
                    SelectCategoryDialog.serializeCategories(
                        selectedCategories));
                Navigator.of(context).pop();
              },
              child: Text(loc?.save ?? ''),
            ),
          ],
        );
      },
    );
  }
}
