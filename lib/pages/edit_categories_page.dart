import 'package:flutter/material.dart';
import 'package:kgl_time/edit_categories_widget.dart';
import 'package:kgl_time/pages/kgl_page.dart';

import '../kgl_time_app.dart';
import '../l10n/generated/app_localizations.dart';

class EditCategoriesPage extends KglPage {
  const EditCategoriesPage({super.key, required super.appTitle});

  @override
  String? pageTitle(AppLocalizations? loc) => loc?.editCategories;

  @override
  Widget body(BuildContext context) =>
      KglPage.alwaysFillingScrollView(child: Center(child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: EditCategoriesWidget(),
      )), maxWidth: KglTimeApp.maxPageWidth);

  @override
  bool get showSettingsButton => false;
}
