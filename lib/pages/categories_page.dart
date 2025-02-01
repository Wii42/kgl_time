import 'package:flutter/material.dart';
import 'package:kgl_time/edit_categories_widget.dart';
import 'package:kgl_time/pages/kgl_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        )
      ],
    );
  }
}
