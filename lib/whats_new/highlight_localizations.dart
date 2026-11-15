import '../l10n/generated/app_localizations.dart';
import 'release_highlight.dart';

extension HighlightLocalizations on HighlightId {
  String title(AppLocalizations loc) => switch (this) {
    HighlightId.jsonBackups => loc.highlightJsonBackupsTitle,
    HighlightId.backupRestore => loc.highlightBackupRestoreTitle,
    HighlightId.settingsSections => loc.highlightSettingsSectionsTitle,
  };

  String description(AppLocalizations loc) => switch (this) {
    HighlightId.jsonBackups => loc.highlightJsonBackupsDescription,
    HighlightId.backupRestore => loc.highlightBackupRestoreDescription,
    HighlightId.settingsSections => loc.highlightSettingsSectionsDescription,
  };
}
