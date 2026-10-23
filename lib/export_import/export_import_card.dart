import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

class ImportExportCard extends StatelessWidget {
  const ImportExportCard({
    super.key,
    required this.title,
    this.actions = const [],
    this.explanationLabel,
  });

  final Function(AppLocalizations? loc) title;
  final List<Widget> actions;
  final Function(AppLocalizations? loc)? explanationLabel;

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
          ],
        ),
      ),
    );
  }
}
