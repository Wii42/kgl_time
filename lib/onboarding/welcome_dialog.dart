import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';

class WelcomeDialog extends StatelessWidget {
  const WelcomeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      scrollable: true,
      title: Row(
        children: <Widget>[
          Icon(Icons.waving_hand_outlined, color: colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(child: Text(loc.welcomeTitle)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.timer_outlined, color: colorScheme.primary),
            title: Text(loc.welcomeTrackTimeTitle),
            subtitle: Text(loc.welcomeTrackTimeDescription),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.category_outlined, color: colorScheme.primary),
            title: Text(loc.welcomeCategoriesTitle),
            subtitle: Text(loc.welcomeCategoriesDescription),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.backup_outlined, color: colorScheme.primary),
            title: Text(loc.welcomeBackupsTitle),
            subtitle: Text(loc.welcomeBackupsDescription),
          ),
        ],
      ),
      actions: <Widget>[
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.welcomeDismiss),
        ),
      ],
    );
  }
}
