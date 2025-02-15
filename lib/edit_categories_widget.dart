import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'data_model/work_categories.dart';
import 'data_model/work_category.dart';
import 'data_model/work_entries.dart';
import 'data_model/work_entry.dart';
import 'delete_dialog.dart';

class EditCategoriesWidget extends StatelessWidget {
  const EditCategoriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations? loc = AppLocalizations.of(context);
    return Consumer<WorkCategories>(builder: (context, categories, _) {
      TextTheme textTheme = Theme.of(context).textTheme;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              loc?.categories ?? '<Categories>',
              style: textTheme.titleLarge,
            ),
          ),
          if (categories.entries.isNotEmpty)
            ReorderableListView(
              primary: false,
              shrinkWrap: true,
              onReorder: categories.reorder,
              children: [
                for ((int, WorkCategory) category in categories.entries.indexed)
                  ListTile(
                    key: Key("${category.$1} ${category.$2.id}"),
                    title: Text(category.$2.displayName),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit_outlined),
                          onPressed: () => _showNewCategoryDialog(context,
                              existingCategory: category.$2),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline_outlined),
                          onPressed: () => showDeleteConfirmationDialog(
                              context: context,
                              detailText: (l) =>
                                  l?.deleteCategoryConfirmationDialog(
                                      category.$2.displayName),
                              onDelete: () => categories.remove(category.$2)),
                        ),
                      ],
                    ),
                  )
              ],
            )
          else
            Text(
              loc?.noExistingCategories ?? '<noCategories>',
              style: textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          if (categories.entries.isNotEmpty) SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _showNewCategoryDialog(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(
                  loc?.addNewCategory ?? '<addNewCategory>',
                  textAlign: TextAlign.center,
                )),
                Icon(Icons.add),
              ],
            ),
          )
        ],
      );
    });
  }

  void _showNewCategoryDialog(BuildContext context,
      {WorkCategory? existingCategory}) {
    AppLocalizations? loc = AppLocalizations.of(context);
    TextEditingController controller =
        TextEditingController(text: existingCategory?.displayName);
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text((existingCategory == null
                  ? loc?.addNewCategory
                  : loc?.editCategory) ??
              ''),
          content: Form(
            key: formKey,
            child: TextFormField(
              autofocus: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return loc?.emptyCategoryNameError ?? '<emptyCategory>';
                }
                return null;
              },
              controller: controller,
              decoration: InputDecoration(hintText: loc?.category),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc?.cancel ?? '<cancel>'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  WorkCategories categories =
                      Provider.of<WorkCategories>(context, listen: false);
                  if (existingCategory != null) {
                    String oldName = existingCategory.displayName;
                    categories.updateEntry(existingCategory,
                        existingCategory..displayName = controller.text);
                    WorkEntries workEntries =
                        Provider.of<WorkEntries>(context, listen: false);

                    Iterable<WorkEntry> entriesWithThisCategory = workEntries
                        .entries
                        .where((entry) => entry.categories.any((category) =>
                            category.displayName == oldName &&
                            category.id == existingCategory.id));
                    for (WorkEntry entry in entriesWithThisCategory) {
                      WorkEntry newEntry = WorkEntry(
                        workDurationInSeconds: entry.workDurationInSeconds,
                        date: entry.date,
                        categories: [
                          for (EmbeddedWorkCategory category
                              in entry.categories)
                            if (category.id == existingCategory.id &&
                                category.displayName == oldName)
                              category..displayName = controller.text
                            else
                              category
                        ],
                        description: entry.description,
                        startTime: entry.startTime,
                        endTime: entry.endTime,
                        lastEdit: entry.lastEdit,
                        tickedOff: entry.tickedOff,
                        createType: entry.createType,
                        wasEdited: entry.wasEdited,
                      )..id = entry.id;
                      workEntries.updateEntry(entry, newEntry);
                    }
                  } else {
                    categories.add(WorkCategory(controller.text,
                        listIndex: categories.entries.length));
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text((existingCategory == null ? loc?.add : loc?.save) ??
                  '<add/save>'),
            ),
          ],
        );
      },
    );
  }
}
