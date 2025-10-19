import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('de', 'AT'),
    Locale('de', 'CH'),
    Locale('en')
  ];

  /// No description provided for @allEntries.
  ///
  /// In en, this message translates to:
  /// **'All Entries'**
  String get allEntries;

  /// No description provided for @newEntry.
  ///
  /// In en, this message translates to:
  /// **'New Entry'**
  String get newEntry;

  /// No description provided for @editEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit Entry'**
  String get editEntry;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @groupByWeek.
  ///
  /// In en, this message translates to:
  /// **'By Week'**
  String get groupByWeek;

  /// No description provided for @groupByMonth.
  ///
  /// In en, this message translates to:
  /// **'By Month'**
  String get groupByMonth;

  /// No description provided for @calendarWeek.
  ///
  /// In en, this message translates to:
  /// **'Calendar Week'**
  String get calendarWeek;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @noInputError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a duration.\nOnly digits allowed'**
  String get noInputError;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @entrySaved.
  ///
  /// In en, this message translates to:
  /// **'Entry saved'**
  String get entrySaved;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error'**
  String get unexpectedError;

  /// No description provided for @inputTooLargeOrNanException.
  ///
  /// In en, this message translates to:
  /// **'Input value is too large or not an integer'**
  String get inputTooLargeOrNanException;

  /// No description provided for @inputTooLargeException.
  ///
  /// In en, this message translates to:
  /// **'Input value is too large'**
  String get inputTooLargeException;

  /// No description provided for @inputSumTooLargeException.
  ///
  /// In en, this message translates to:
  /// **'Sum of both values is too large'**
  String get inputSumTooLargeException;

  /// No description provided for @inputInvalidException.
  ///
  /// In en, this message translates to:
  /// **'Input value is invalid'**
  String get inputInvalidException;

  /// No description provided for @createNewEntry.
  ///
  /// In en, this message translates to:
  /// **'Create new entry'**
  String get createNewEntry;

  /// No description provided for @recentEntries.
  ///
  /// In en, this message translates to:
  /// **'Recent entries'**
  String get recentEntries;

  /// No description provided for @showAllEntries.
  ///
  /// In en, this message translates to:
  /// **'Show all entries'**
  String get showAllEntries;

  /// No description provided for @noExistingEntries.
  ///
  /// In en, this message translates to:
  /// **'No existing entries yet'**
  String get noExistingEntries;

  /// No description provided for @currentWeek.
  ///
  /// In en, this message translates to:
  /// **'Current week'**
  String get currentWeek;

  /// No description provided for @currentMonth.
  ///
  /// In en, this message translates to:
  /// **'Current month'**
  String get currentMonth;

  /// No description provided for @systemBrightness.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemBrightness;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightMode;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @deleteCategoryConfirmationDialog.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete the category {category}?\n\nEntries assigned to this category will not be changed.'**
  String deleteCategoryConfirmationDialog(Object category);

  /// No description provided for @noExistingCategories.
  ///
  /// In en, this message translates to:
  /// **'No existing categories yet'**
  String get noExistingCategories;

  /// No description provided for @addNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Add new category'**
  String get addNewCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @editCategories.
  ///
  /// In en, this message translates to:
  /// **'Edit categories'**
  String get editCategories;

  /// No description provided for @emptyCategoryNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get emptyCategoryNameError;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyUrlFragment.
  ///
  /// In en, this message translates to:
  /// **'privacy-policy-for-kgl-time'**
  String get privacyPolicyUrlFragment;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm delete'**
  String get confirmDelete;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirmDeleteDialog.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete the entry?'**
  String get confirmDeleteDialog;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategory;

  /// No description provided for @runningForDuration.
  ///
  /// In en, this message translates to:
  /// **'running for {duration}'**
  String runningForDuration(Object duration);

  /// No description provided for @trackTime.
  ///
  /// In en, this message translates to:
  /// **'Track time'**
  String get trackTime;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @openTrashBin.
  ///
  /// In en, this message translates to:
  /// **'Open Trash Bin'**
  String get openTrashBin;

  /// No description provided for @restoreEntry.
  ///
  /// In en, this message translates to:
  /// **'Restore Entry'**
  String get restoreEntry;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'de':
      {
        switch (locale.countryCode) {
          case 'AT':
            return AppLocalizationsDeAt();
          case 'CH':
            return AppLocalizationsDeCh();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
