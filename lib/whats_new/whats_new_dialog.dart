import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import 'highlight_localizations.dart';
import 'release_highlight.dart';
import 'whats_new_controller.dart';

class WhatsNewDialog extends StatelessWidget {
  final List<ReleaseHighlight> highlights;

  const WhatsNewDialog({super.key, required this.highlights});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      scrollable: true,
      title: Text(loc.whatsNew),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final ReleaseHighlight highlight in highlights.take(
            WhatsNewController.maxHighlights,
          ))
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(highlight.id.title(loc), style: textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(highlight.id.description(loc)),
                ],
              ),
            ),
        ],
      ),
      actions: <Widget>[
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.whatsNewDismiss),
        ),
      ],
    );
  }
}
