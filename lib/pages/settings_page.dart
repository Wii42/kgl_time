import 'package:go_router/go_router.dart';
import 'package:kgl_time/app/app_layout_constants.dart';
import 'package:kgl_time/app/app_route.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/pages/kgl_page.dart';
import 'package:kgl_time/utils/helpers.dart';
import 'package:kgl_time/widgets/layout/always_filling_scroll_view.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data_model/key_values.dart';
import '../main.dart';
import '../onboarding/onboarding_controller.dart';
import '../onboarding/welcome_dialog.dart';
import '../whats_new/whats_new_controller.dart';
import '../whats_new/whats_new_dialog.dart';

class SettingsPage extends KglPage {
  const SettingsPage({super.key, required super.appTitle});

  @override
  String? pageTitle(AppLocalizations? loc) => loc?.settings;
  @override
  final bool showSettingsButton = false;

  @override
  Widget body(BuildContext context) {
    final AppLocalizations? loc = AppLocalizations.of(context);
    return AlwaysFillingScrollView(
      maxWidth: AppLayoutConstants.maxPageWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _SettingsSection(
              sectionTitle: loc?.appearance ?? '<Appearance>',
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _ThemeModeSettings(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SettingsSection(
              sectionTitle: loc?.settingsDataSectionTitle ?? '<Data>',
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: Text(loc?.editCategories ?? '<Edit Categories>'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoute.editCategories.path),
                ),
                ListTile(
                  leading: const Icon(Icons.recycling_outlined),
                  title: Text(loc?.trashBin ?? '<Trash Bin>'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoute.entriesTrashBin.path),
                ),
                ListTile(
                  leading: const Icon(Icons.import_export_outlined),
                  title: Text(loc?.settingsExportImport ?? '<Export / Import>'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoute.exportImport.path),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _AboutSection(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppLocalizations? loc = AppLocalizations.of(context);
    Map<ThemeMode, String?> themeModeNames = {
      ThemeMode.system: loc?.systemBrightness,
      ThemeMode.light: loc?.lightMode,
      ThemeMode.dark: loc?.darkMode,
    };
    Map<ThemeMode, IconData> themeModeIcons = {
      ThemeMode.system: Icons.brightness_auto,
      ThemeMode.light: Icons.brightness_7,
      ThemeMode.dark: Icons.brightness_2,
    };
    return Consumer<KeyValues>(
      builder: (context, keyValues, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final ThemeData theme = Theme.of(context);
            final ListTileThemeData tileTheme = ListTileTheme.of(context);

            final TextStyle? titleStyle =
                tileTheme.titleTextStyle ??
                    theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    );
            return SizedBox(
              width: constraints.maxWidth,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Text(loc?.theme ?? '<Theme>', style: titleStyle),
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
                          ),
                        ),
                    ],
                    showSelectedIcon: false,
                    selected: {
                      parseThemeMode(keyValues.get<String>('themeMode')) ?? ThemeMode.system,
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
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations? loc = AppLocalizations.of(context);
    final Uri contactUri = Uri.parse('mailto:wi42.dev@gmail.com');
    final Uri privacyUri = Uri.parse(
      'https://github.com/Wii42/kgl_time/blob/main/PRIVACY.md#${loc?.privacyPolicyUrlFragment}',
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SettingsSection(
          sectionTitle: loc?.aboutSection ?? '<About>',
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.new_releases_outlined),
              title: Text(loc?.whatsNew ?? "<What's new>"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showDialog<void>(
                context: context,
                builder: (BuildContext context) => WhatsNewDialog(
                  highlights: WhatsNewController.recentHighlights(appInfo.version),
                  currentVersion: appInfo.version,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.explore_outlined),
              title: Text(loc?.gettingStarted ?? '<Getting started>'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final OnboardingController controller = OnboardingController(
                  storage: context
                      .read<KeyValues>()
                      .storedEntries,
                );
                await showDialog<void>(
                  context: context,
                  builder: (BuildContext context) => const WelcomeDialog(),
                );
                if (context.mounted) await controller.acknowledge();
              },
            ),
            Tooltip(
              message: contactUri.toString(),
              child: ListTile(
                leading: const Icon(Icons.email_outlined),
                title: Text(loc?.contact ?? '<Contact>'),
                subtitle: const Text('wi42.dev@gmail.com'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => launchUrl(contactUri),
              ),
            ),
            Tooltip(
              message: privacyUri.toString(),
              child: ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(loc?.privacyPolicy ?? '<Privacy Policy>'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => launchUrl(privacyUri),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'v${appInfo.version}',
          textAlign: TextAlign.center,
          style: Theme
              .of(context)
              .textTheme
              .bodySmall,
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String sectionTitle;
  final List<Widget> children;
  final bool addDividerBetweenChildren;

  final Widget divider = const Divider(height: 1, indent: 56, endIndent: 16);

  const _SettingsSection({
    required this.sectionTitle,
    required this.children,
    this.addDividerBetweenChildren = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            sectionTitle,
            style: Theme
                .of(context)
                .textTheme
                .titleSmall
                ?.copyWith(
              color: Theme
                  .of(context)
                  .colorScheme
                  .primary,
            ),
          ),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: addDividerBetweenChildren ? children.withWidgetBetween(divider) : children,
          ),
        ),
      ],
    );
  }
}
