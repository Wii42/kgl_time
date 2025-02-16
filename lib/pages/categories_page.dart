import 'package:flutter/material.dart';
import 'package:kgl_time/category_filter_widget.dart';
import 'package:kgl_time/data_model/work_categories.dart';
import 'package:kgl_time/edit_categories_widget.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/pages/kgl_page.dart';
import 'package:provider/provider.dart';

class CategoriesPage extends KglPage {
  const CategoriesPage({super.key, required super.appTitle});

  @override
  String? pageTitle(AppLocalizations? loc) => loc?.categories;

  @override
  Widget body(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: EditCategoriesWidget(),
          ),
        ),
        Consumer<WorkCategories>(
          builder: (context, categories, _) {
            return
        Expanded(child: CategoryFilterWidget(categories: categories));})
      ],
    );
  }
}
