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
      onTap: () => showAboutDialog(
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

class _AboutProjectLinks extends StatelessWidget {
  const _AboutProjectLinks();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;
    final TextStyle linkStyle = TextStyle(
      color: Theme.of(context).colorScheme.primary,
    );

    WidgetSpan link(String label, String url) => WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: Link(
        uri: Uri.parse(url),
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
          link(loc.aboutSourceCode, 'https://github.com/Wii42/kgl_time'),
          TextSpan(text: loc.aboutProjectLinksSeparator),
          link(loc.aboutAppLicense, 'https://github.com/Wii42/kgl_time/blob/main/LICENSE'),
          TextSpan(text: loc.aboutProjectLinksSuffix),
        ],
      ),
    );
  }
}
