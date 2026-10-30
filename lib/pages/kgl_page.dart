import 'package:go_router/go_router.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../app_route.dart';

abstract class KglPage extends StatelessWidget {
  final String appTitle;

  Widget body(BuildContext context);

  // Null means this page uses the app title; subclasses may provide a title.
  // ignore: many_lints/function_always_returns_null
  String? pageTitle(AppLocalizations? loc) => null;

  bool get showSettingsButton => true;

  const KglPage({super.key, required this.appTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appbarTitle(context),
        actions: [
          if (showSettingsButton)
            IconButton(
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.settings),
              ),
              onPressed: () {
                context.push(AppRoute.settings.path);
              },
            ),
        ],
      ),
      body: body(context),
    );
  }

  Widget appbarTitle(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations? localizations = AppLocalizations.of(context);
    TextTheme textTheme = theme.textTheme;
    String? pageTitle = this.pageTitle(localizations);
    String largeTitle = pageTitle ?? appTitle;
    String? smallTitle = pageTitle != null ? appTitle : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (smallTitle != null)
          Text(
            smallTitle,
            style: textTheme.bodySmall?.copyWith(color: theme.appBarTheme.foregroundColor),
          ),
        Text(largeTitle),
      ],
    );
  }
}
