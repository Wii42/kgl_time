import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kgl_time/data_model/work_entries.dart';
import 'package:kgl_time/delete_dialog.dart';
import 'package:kgl_time/pages/kgl_page.dart';
import 'package:kgl_time/helpers.dart';
import 'package:provider/provider.dart';

import '../data_model/key_values.dart';
import '../data_model/work_categories.dart';
import '../data_model/work_category.dart';
import '../data_model/work_entry.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends KglPage {
  const SettingsPage({super.key, required super.appTitle});

  @override
  final String pageTitle = 'Einstellungen';
  @override
  final bool showSettingsButton = false;

  @override
  Widget body(BuildContext context) {
    return KglPage.alwaysFillingScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            withCard(themeMode(context)),
            withCard(categories(context)),
            infos(context),
          ].withSpaceBetween(height: 16),
        ),
      ),
    );
  }

  Widget withCard(Widget child) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: child,
    ));
  }

  Widget themeMode(BuildContext context) {
    Map<ThemeMode, String> themeModeNames = {
      ThemeMode.system: 'System',
      ThemeMode.light: 'Hell',
      ThemeMode.dark: 'Dunkel'
    };
    Map<ThemeMode, IconData> themeModeIcons = {
      ThemeMode.system: Icons.brightness_auto,
      ThemeMode.light: Icons.brightness_7,
      ThemeMode.dark: Icons.brightness_2
    };
    return Consumer<KeyValues>(builder: (context, keyValues, _) {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Darstellung'),
        ToggleButtons(
          isSelected: [
            for (ThemeMode themeMode in ThemeMode.values)
              (parseThemeMode(keyValues.get<String>('themeMode')) ??
                      ThemeMode.system) ==
                  themeMode
          ],
          children: [
            for (ThemeMode themeMode in ThemeMode.values)
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  children: [
                    Icon(themeModeIcons[themeMode]),
                    Text(
                      themeModeNames[themeMode] ?? '',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              )
          ],
          onPressed: (int index) {
            keyValues.set('themeMode', ThemeMode.values[index].name);
          },
        ),
      ]);
    });
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
                          icon: Icon(Icons.edit_outlined),
                          onPressed: () => _showNewCategoryDialog(context,
                              existingCategory: category.$2),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline_outlined),
                          onPressed: () => showDeleteConfirmationDialog(
                              context: context,
                              detailText:
                                  'Wollen Sie die Kategorie ${category.$2.displayName} wirklich löschen?\n\n'
                                  'Einträge, die dieser Kategorie zugeordnet sind, werden nicht verändert.',
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
                        for (EmbeddedWorkCategory category in entry.categories)
                          if (category.id == existingCategory.id &&
                              category.displayName == oldName)
                            category..displayName = controller.text
                          else
                            category
                      ],
                      description: entry.description,
                      startTime: entry.startTime,
                      endTime: entry.endTime,
                    )..id = entry.id;
                    workEntries.updateEntry(entry, newEntry);
                  }
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

  Widget infos(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        infoWithLink(
            infoText: 'Kontakt: ',
            linkText: 'wi42.dev@gmail.com',
            link: Uri.parse('mailto:wi42.dev@gmail.com'),
            context: context),
        infoWithLink(
            infoText: 'Lizenz: ',
            linkText: 'GNU General Public License v3.0',
            link: Uri.https(
                'github.com', 'Wii42/kgl_time/blob/master/LICENSE.md'),
            context: context),
        infoWithLink(
            linkText: 'Datenschutzrichtlinie',
            link: Uri.parse('https://github.com/Wii42/kgl_time/blob/master/PRIVACY.md#datenschutzrichtlinie-für-kgl-time'),
            context: context),
        Text(''),
        Text("v0.0.2", style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget infoWithLink({
    String? infoText,
    required String linkText,
    required Uri link,
    required BuildContext context,
  }) {
    ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            children: [
              if (infoText != null)
                TextSpan(text: infoText, style: theme.textTheme.bodyMedium),
              TooltipSpan(
                message: link.toString(),
                inlineSpan: TextSpan(
                  text: linkText,
                  style: theme.textTheme.bodyMedium
                      ?.apply(color: theme.colorScheme.primary),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchUrl(link);
                    },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TooltipSpan extends WidgetSpan {
  TooltipSpan({
    required String message,
    required TextSpan inlineSpan,
  }) : super(
          child: Tooltip(
            message: message,
            child: Text.rich(
              inlineSpan,
            ),
          ),
        );
}
