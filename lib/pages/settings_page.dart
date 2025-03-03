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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../kgl_time_app.dart';
import '../main.dart';

class SettingsPage extends KglPage {
  const SettingsPage({super.key, required super.appTitle});

  @override
  String? pageTitle(AppLocalizations? loc) => loc?.settings;
  @override
  final bool showSettingsButton = false;

  @override
  Widget body(BuildContext context) {
    return KglPage.alwaysFillingScrollView(
      maxWidth: KglTimeApp.maxPageWidth,
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
    AppLocalizations? loc = AppLocalizations.of(context);
    Map<ThemeMode, String?> themeModeNames = {
      ThemeMode.system: loc?.systemBrightness,
      ThemeMode.light: loc?.lightMode,
      ThemeMode.dark: loc?.darkMode
    };
    Map<ThemeMode, IconData> themeModeIcons = {
      ThemeMode.system: Icons.brightness_auto,
      ThemeMode.light: Icons.brightness_7,
      ThemeMode.dark: Icons.brightness_2
    };
    return Consumer<KeyValues>(builder: (context, keyValues, _) {
      return LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              runAlignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text(loc?.appearance ?? '<Appearance>'),
                SegmentedButton<ThemeMode>(
                  segments: [
                    for (ThemeMode mode in ThemeMode.values)
                      ButtonSegment(
                          value: mode,
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              children: [
                                Icon(themeModeIcons[mode], size: 20),
                                Text(
                                  themeModeNames[mode] ?? '<themeMode>',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                          )),
                  ],
                  showSelectedIcon: false,
                  selected: {
                    parseThemeMode(keyValues.get<String>('themeMode')) ??
                        ThemeMode.system
                  },
                  onSelectionChanged: (Set<ThemeMode> modes) {
                    keyValues.set('themeMode', modes.single.name);
                  },
                  style: ButtonStyle(
                      iconColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return Theme.of(context).colorScheme.primary;
                        }
                        return null;
                      }),
                      visualDensity: VisualDensity.compact),
                )
              ]),
        );
      });
    });
  }

  Widget categories(BuildContext context) {
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
              child:
                  Text((existingCategory == null ? loc?.add : loc?.save) ?? '<add/save>'),
            ),
          ],
        );
      },
    );
  }

  Widget infos(BuildContext context) {
    AppLocalizations? loc = AppLocalizations.of(context);
    ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        infoWithLink(
            infoText: '${loc?.contact}: ',
            linkText: 'wi42.dev@gmail.com',
            link: Uri.parse('mailto:wi42.dev@gmail.com'),
            context: context),
        infoWithLink(
            linkText: loc?.privacyPolicy ?? '<privacyPolicy>',
            link: Uri.parse(
                'https://github.com/Wii42/kgl_time/blob/master/PRIVACY.md#${loc?.privacyPolicyUrlFragment}'),
            context: context),
        Text(''),
        Text("v$appVersion", style: theme.textTheme.bodySmall),
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
