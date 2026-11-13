import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';

class ImportExportCard extends StatelessWidget {
  const ImportExportCard({
    super.key,
    required this.title,
    this.actions = const [],
    this.explanationLabel,
    this.warningLabels = const [],
  });

  final String Function(AppLocalizations? loc) title;
  final List<Widget> actions;
  final String Function(AppLocalizations? loc)? explanationLabel;
  final List<Function(AppLocalizations? loc)> warningLabels;

  @override
  Widget build(BuildContext context) {
    AppLocalizations? loc = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              title(loc),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            Divider(height: 12),
            SizedBox(height: 4),
            if (explanationLabel != null) ...[
              Text(
                explanationLabel!(loc),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SizedBox(height: 4),
            ],
            Wrap(spacing: 8, runSpacing: 8, children: actions),
            if (warningLabels.isNotEmpty) SizedBox(height: 4),
            for (var label in warningLabels)
              Text(
                label(loc),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
