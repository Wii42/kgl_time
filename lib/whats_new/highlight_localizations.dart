import '../l10n/generated/app_localizations.dart';
import 'release_highlight.dart';

extension HighlightLocalizations on HighlightId {
  String title(AppLocalizations loc) => switch (this) {
    HighlightId.jsonBackups => loc.highlightJsonBackupsTitle,
  };

  String description(AppLocalizations loc) => switch (this) {
    HighlightId.jsonBackups => loc.highlightJsonBackupsDescription,
  };
}
