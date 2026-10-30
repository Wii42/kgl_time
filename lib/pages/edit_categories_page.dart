import 'package:kgl_time/always_filling_scroll_view.dart';
import 'package:kgl_time/edit_categories_widget.dart';
import 'package:kgl_time/pages/kgl_page.dart';
import 'package:material_ui/material_ui.dart';

import '../kgl_time_app.dart';
import '../l10n/generated/app_localizations.dart';

class EditCategoriesPage extends KglPage {
  const EditCategoriesPage({super.key, required super.appTitle});

  @override
  String? pageTitle(AppLocalizations? loc) => loc?.editCategories;

  @override
  Widget body(BuildContext context) => AlwaysFillingScrollView(
    maxWidth: KglTimeApp.maxPageWidth,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: EditCategoriesWidget(),
      ),
    ),
  );

  @override
  bool get showSettingsButton => false;
}
