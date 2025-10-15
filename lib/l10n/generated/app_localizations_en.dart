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
  String get groupByWeek => 'By Week';

  @override
  String get groupByMonth => 'By Month';

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
  String get inputTooLargeOrNanException =>
      'Input value is too large or not an integer';

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
  String get categories => 'Categories';

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
  String get confirmDeleteDialog => 'Do you really want to delete the entry?';

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
}
