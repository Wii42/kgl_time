import 'dart:math';

import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import 'always_filling_scroll_view.dart';
import 'kgl_time_app.dart';

class NoContentWidget extends StatelessWidget {
  final IconData? icon;

  /// If null, "no existing entries" is used.
  final String? title;
  final String? hints;

  const NoContentWidget({super.key, this.icon, this.title, this.hints});

  @override
  Widget build(BuildContext context) {
    AppLocalizations? loc = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            ExcludeSemantics(
              child: Icon(
                icon,
                size: 80,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.18),
              ),
            ),
            const SizedBox(height: 20),
          ],
          Text(
            title ?? loc?.noExistingEntries ?? '<noEntries>',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          if (hints != null) ...[
            const SizedBox(height: 8),
            Text(
              hints!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  static Widget inAlwaysFillingScrollView({
    IconData? icon,
    String? title,
    String? hints,
    double maxWidth = KglTimeApp.maxPageWidth,
    double padding = 16,
    double saveAreaTopHeight = 0,
  }) {
    return AlwaysFillingScrollView(
      maxWidth: maxWidth,
      child: Padding(
        padding: EdgeInsets.all(padding).add(EdgeInsets.only(top: max(saveAreaTopHeight, 0))),
        child: NoContentWidget(icon: icon, title: title, hints: hints),
      ),
    );
  }
}
