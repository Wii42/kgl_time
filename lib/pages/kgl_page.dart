import 'package:flutter/services.dart';
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
      body: StatusBarSafeArea(
        child: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              systemOverlayStyle: SystemUiOverlayStyle.light,
              primary: true,
              floating: true,
              scrolledUnderElevation: 0,
              title: _AppBarTitle(appTitle: appTitle, pageTitle: pageTitle),
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
          ],
          body: SafeArea(
            top: false, // The outer SafeArea keeps the status-bar area fixed.
            bottom: false,
            child: body(context),
          ),
        ),
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  final String appTitle;
  final String? Function(AppLocalizations? loc) pageTitle;

  const new({
    required this.appTitle,
    required this.pageTitle,
  });

  @override
  Widget build(BuildContext context) {
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

/// Makes sure that the status bar area is filled with a background color, even when the app bar scrolls out of view.
class StatusBarSafeArea extends StatelessWidget {
  final Widget? child;

  const new({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
      child: SafeArea(
        left: false,
        right: false,
        bottom: false,
        child: ColoredBox(color: Theme.of(context).scaffoldBackgroundColor, child: child),
      ),
    );
  }
}
