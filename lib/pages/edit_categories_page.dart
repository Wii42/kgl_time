import 'package:kgl_time/app/app_layout_constants.dart';
import 'package:kgl_time/pages/kgl_page.dart';
import 'package:kgl_time/widgets/categories/edit_categories_widget.dart';
import 'package:kgl_time/widgets/layout/always_filling_scroll_view.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';

class EditCategoriesPage extends KglPage {
  const EditCategoriesPage({super.key, required super.appTitle});

  @override
  String? pageTitle(AppLocalizations? loc) => loc?.editCategories;

  @override
  Widget body(BuildContext context) => AlwaysFillingScrollView(
    maxWidth: AppLayoutConstants.maxPageWidth,
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: EditCategoriesWidget(),
    ),
  );

  @override
  bool get showSettingsButton => false;
}
