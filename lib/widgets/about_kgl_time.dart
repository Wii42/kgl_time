import 'package:kgl_time/app/external_links.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/main.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/link.dart';

class AboutKglTimeListTile extends StatelessWidget {
  final String appName;

  const new({super.key, required this.appName});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? loc = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: Text(MaterialLocalizations.of(context).aboutListTileTitle(appName)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => AboutKglTimeDialog.showAboutDialog(
        context: context,
        applicationVersion: "v${appInfo.version}",
        applicationName: appName,
        applicationIcon: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset('assets/playstore-icon.png', width: 64),
        ),
        applicationLegalese: loc?.aboutCopyrightAndLicense ?? '<Copyright and license>',
        children: <Widget>[
          const SizedBox(height: 12),
          const _AboutProjectLinks(),
        ],
      ),
    );
  }
}

class AboutKglTimeDialog extends StatelessWidget {
  final String? applicationName;
  final String? applicationVersion;
  final Widget? applicationIcon;
  final String? applicationLegalese;
  final List<Widget>? children;

  const new({
    super.key,
    this.applicationName,
    this.applicationVersion,
    this.applicationIcon,
    this.applicationLegalese,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final String name = applicationName ?? "";
    final String version = applicationVersion ?? "";
    final Widget? icon = applicationIcon;
    final ThemeData themeData = Theme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    return AlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListBody(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (icon != null) IconTheme(data: themeData.iconTheme, child: icon),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 4),
                        Text(name, style: themeData.textTheme.headlineSmall),
                        Text(version, style: themeData.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(applicationLegalese ?? '', style: themeData.textTheme.bodySmall),
            ...?children,
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(localizations.viewLicensesButtonLabel),
          onPressed: () {
            showLicensePage(
              context: context,
              applicationName: applicationName,
              applicationVersion: applicationVersion,
              applicationIcon: applicationIcon,
              applicationLegalese: applicationLegalese,
            );
          },
        ),
        TextButton(
          child: Text(localizations.closeButtonLabel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
      scrollable: true,
    );
  }

  static void showAboutDialog({
    required BuildContext context,
    String? applicationName,
    String? applicationVersion,
    Widget? applicationIcon,
    String? applicationLegalese,
    List<Widget>? children,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useRootNavigator: useRootNavigator,
      builder: (BuildContext context) {
        return AboutKglTimeDialog(
          applicationName: applicationName,
          applicationVersion: applicationVersion,
          applicationIcon: applicationIcon,
          applicationLegalese: applicationLegalese,
          children: children,
        );
      },
      routeSettings: routeSettings,
      anchorPoint: anchorPoint,
    );
  }
}

class _AboutProjectLinks extends StatelessWidget {
  const _AboutProjectLinks();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;
    final TextStyle linkStyle = TextStyle(
      color: Theme.of(context).colorScheme.primary,
    );

    WidgetSpan link(String label, Uri url) => WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: Link(
        uri: url,
        target: LinkTarget.blank,
        builder: (BuildContext context, FollowLink? followLink) => InkWell(
          onTap: followLink,
          child: Text(label, style: linkStyle),
        ),
      ),
    );

    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(text: loc.aboutProjectLinksPrefix),
          link(loc.aboutSourceCode, ExternalLinks.githubRepo),
          TextSpan(text: loc.aboutProjectLinksSeparator),
          link(loc.aboutAppLicense, ExternalLinks.license),
          TextSpan(text: loc.aboutProjectLinksSuffix),
        ],
      ),
    );
  }
}
