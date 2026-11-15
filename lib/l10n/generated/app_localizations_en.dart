// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get allEntries => 'All Entries';

  @override
  String get newEntry => 'New Entry';

  @override
  String get editEntry => 'Edit Entry';

  @override
  String get settings => 'Settings';

  @override
  String get settingsDataSectionTitle => 'Data';

  @override
  String get settingsExportImport => 'Export / Import';

  @override
  String get whatsNew => 'What\'s new';

  @override
  String get whatsNewDismiss => 'Got it';

  @override
  String get whatsNewReleaseNotes => 'Release notes';

  @override
  String get highlightJsonBackupsTitle => 'Backups for your work';

  @override
  String get highlightJsonBackupsDescription =>
      'You can now back up and restore your entries and categories in Settings → Export / Import.';

  @override
  String get groupBy => 'Group by';

  @override
  String get groupByDay => 'Day';

  @override
  String get groupByWeek => 'Week';

  @override
  String get groupByMonth => 'Month';

  @override
  String get calendarWeek => 'Calendar Week';

  @override
  String get hours => 'Hours';

  @override
  String get minutes => 'Minutes';

  @override
  String get noInputError => 'Please enter a duration.\nOnly digits allowed';

  @override
  String get description => 'Description';

  @override
  String get date => 'Date';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get entrySaved => 'Entry saved';

  @override
  String get unexpectedError => 'Unexpected error';

  @override
  String get inputTooLargeOrNanException => 'Input value is too large or not an integer';

  @override
  String get inputTooLargeException => 'Input value is too large';

  @override
  String get inputSumTooLargeException => 'Sum of both values is too large';

  @override
  String get inputInvalidException => 'Input value is invalid';

  @override
  String get createNewEntry => 'Create new entry';

  @override
  String get recentEntries => 'Recent entries';

  @override
  String get showAllEntries => 'Show all entries';

  @override
  String get noExistingEntries => 'No existing entries yet';

  @override
  String get createFirstEntryHint => 'Create your first entry on Home to see it here.';

  @override
  String get homeFirstEntryHint =>
      'Create an entry or start tracking your time using the controls above.';

  @override
  String get today => 'Today';

  @override
  String get currentWeek => 'Current week';

  @override
  String get currentMonth => 'Current month';

  @override
  String get systemBrightness => 'System';

  @override
  String get darkMode => 'Dark';

  @override
  String get lightMode => 'Light';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get aboutSection => 'About';

  @override
  String get categories => 'Categories';

  @override
  String get defaultCategoryPlanning => 'Planning';

  @override
  String get defaultCategoryMeetings => 'Meetings';

  @override
  String get defaultCategoryAdministration => 'Administration';

  @override
  String deleteCategoryConfirmationDialog(Object category) {
    return 'Do you really want to delete the category $category?\n\nEntries assigned to this category will not be changed.';
  }

  @override
  String get noExistingCategories => 'No existing categories yet';

  @override
  String get addNewCategory => 'Add new category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get editCategories => 'Edit categories';

  @override
  String get emptyCategoryNameError => 'Please enter a name';

  @override
  String get category => 'Category';

  @override
  String get add => 'Add';

  @override
  String get contact => 'Contact';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyUrlFragment => 'privacy-policy-for-kgl-time';

  @override
  String get confirmDelete => 'Confirm delete';

  @override
  String get delete => 'Delete';

  @override
  String get confirmDeleteDialog =>
      'Do you really want to delete the entry?\nThe entry will be moved to the trash bin and can be restored there for 30 days.';

  @override
  String get selectCategory => 'Select category';

  @override
  String runningForDuration(Object duration) {
    return 'running for $duration';
  }

  @override
  String get trackTime => 'Track time';

  @override
  String get start => 'Start';

  @override
  String get stop => 'Stop';

  @override
  String get home => 'Home';

  @override
  String get openTrashBin => 'Open Trash Bin';

  @override
  String get restoreEntry => 'Restore';

  @override
  String get trashBin => 'Trash Bin';

  @override
  String get noMatchingEntries => 'No matching entries found';

  @override
  String get adjustCategoryFilterHint =>
      'Try selecting more categories or include entries without a category.';

  @override
  String get trashBinEmpty => 'The trash bin is empty';

  @override
  String get trashBinHint =>
      'Deleted entries appear here. You can restore them for up to 30 days after deletion.';

  @override
  String get exportImportEntries => 'Export/Import Entries';

  @override
  String get share => 'Share';

  @override
  String get saveLocally => 'Save locally';

  @override
  String get savingNotSupported => 'Saving files is not supported on this platform.';

  @override
  String get sharingNotSupported => 'Sharing files is not supported on this platform.';

  @override
  String get importingNotSupported => 'Importing files is not supported on this platform.';

  @override
  String get workingTime => 'Working Time';

  @override
  String get fromTo => 'From-To';

  @override
  String get fileSavedSuccessfully => 'File saved successfully';

  @override
  String get failedToSaveFile => 'Failed to save file';

  @override
  String get fileSharedSuccessfully => 'File shared successfully';

  @override
  String get failedToShareFile => 'Failed to share file';

  @override
  String get exportTable => 'Export work entries as table';

  @override
  String get exportBackup => 'Export backup of work entries';

  @override
  String get exportCsvExplanation =>
      'Exports all work entries as a CSV file. The file can be opened with spreadsheet applications like Microsoft Excel or Google Sheets.';

  @override
  String get exportJsonExplanation =>
      'Creates a JSON backup of all work entries, including the trash, and categories, for restoring data or transferring it to another device. Settings and running tracker sessions are not included.';

  @override
  String get importBackup => 'Import backup';

  @override
  String get importBackupExplanation =>
      'Import a JSON backup to restore your work entries and categories. This replaces all existing entries and categories, including the trash.';

  @override
  String get replaceData => 'Replace data';

  @override
  String get importReplaceDialogTitle => 'Import backup and replace existing entries';

  @override
  String get importSuccess => 'Import successful';

  @override
  String get importFailed => 'Import failed';

  @override
  String get invalidBackupData => 'This backup contains invalid data and cannot be imported.';

  @override
  String get undo => 'Undo';

  @override
  String get undoImportTitle => 'Undo backup import?';

  @override
  String get undoImportChangesWarning =>
      'This will restore the data from before the import. Changes made since the import will be lost.';

  @override
  String get undoImportFailed => 'Failed to undo the backup import';

  @override
  String get undoImportSuccess => 'Backup import undone';

  @override
  String get importCancelsTrackerWarning =>
      'Importing this backup will cancel the current time tracker without saving the tracked time.';

  @override
  String get undoImportCancelsTrackerWarning =>
      'Undoing this import will cancel the current time tracker without saving the tracked time.';

  @override
  String dateOfBackup(Object date) {
    return 'Date of backup: $date';
  }

  @override
  String nrOfEntriesAndCategories(Object nrOfCategories, Object nrOfEntries) {
    return '$nrOfEntries entries, $nrOfCategories categories';
  }

  @override
  String get unsupportedBackupFormatTitle => 'Unsupported backup format';

  @override
  String get unsupportedBackupFormat =>
      'This backup format is not supported and cannot be imported. If it was created with a newer app version, update the app first.';

  @override
  String get importReplaceConfirmationDialog =>
      'This will replace all existing entries and categories, including the trash. You can undo this only while the confirmation message at the bottom of the screen is visible.';

  @override
  String get withoutCategory => 'Without Category';
}
