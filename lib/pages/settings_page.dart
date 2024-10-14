import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kgl_time/delete_dialog.dart';
import 'package:kgl_time/pages/kgl_page.dart';
import 'package:provider/provider.dart';

import '../data_model/work_categories.dart';
import '../data_model/work_category.dart';

class SettingsPage extends KglPage {
  const SettingsPage({super.key, required super.appTitle});

  @override
  final String pageTitle = 'Einstellungen';
  @override
  final bool showSettingsButton = false;

  @override
  Widget body(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [categories(context)],
    );
  }

  Widget categories(BuildContext context) {
    return Consumer<WorkCategories>(builder: (context, categories, _) {
      TextTheme textTheme = Theme.of(context).textTheme;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Kategorien',
            style: textTheme.titleLarge,
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
                          icon: Icon(Icons.edit),
                          onPressed: () => _showNewCategoryDialog(context,
                              existingCategory: category.$2),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => showDeleteConfirmationDialog(
                              context: context,
                              detailText:
                                  'Wollen Sie die Kategorie ${category.$2.displayName} wirklich löschen?\n\nEinträge, die dieser Kategorie zugeordnet sind, werden nicht verändert.',
                              onDelete: () => categories.remove(category.$2)),
                        ),
                      ],
                    ),
                  )
              ],
            )
          else
            Text(
              'Noch keine Kategorien vorhanden',
              style: textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ElevatedButton(
            onPressed: () => _showNewCategoryDialog(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Neue Kategorie hinzufügen'),
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
    TextEditingController controller =
        TextEditingController(text: existingCategory?.displayName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existingCategory == null
              ? 'Neue Kategorie hinzufügen'
              : 'Kategorie bearbeiten'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Kategorie'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                WorkCategories categories =
                    Provider.of<WorkCategories>(context, listen: false);
                if (existingCategory != null) {
                  categories.updateEntry(existingCategory,
                      existingCategory..displayName = controller.text);
                } else {
                  categories.add(WorkCategory(controller.text,
                      listIndex: categories.entries.length));
                }
                Navigator.of(context).pop();
              },
              child:
                  Text(existingCategory == null ? 'Hinzufügen' : 'Speichern'),
            ),
          ],
        );
      },
    );
  }
}
