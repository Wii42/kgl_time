import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:kgl_time/app_route.dart';
import 'package:kgl_time/helpers.dart';
import 'package:kgl_time/pages/kgl_page.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data_model/key_values.dart';
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
    AppLocalizations? loc = AppLocalizations.of(context);
    return KglPage.alwaysFillingScrollView(
      maxWidth: KglTimeApp.maxPageWidth,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            withCard(themeMode(context)),
            ElevatedButton(
                onPressed: () => context.go(NavBarAppRoute.categories.path),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(loc?.editCategories ?? '<editCategories>'),
                    SizedBox(width: 8),
                    Icon(Icons.link)
                  ],
                )),
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
