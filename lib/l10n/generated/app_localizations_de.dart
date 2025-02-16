// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get allEntries => 'Alle Einträge';

  @override
  String get newEntry => 'Neuer Eintrag';

  @override
  String get editEntry => 'Eintrag Bearbeiten';

  @override
  String get settings => 'Einstellungen';

  @override
  String get groupByWeek => 'Nach Woche';

  @override
  String get groupByMonth => 'Nach Monat';

  @override
  String get calendarWeek => 'Kalenderwoche';

  @override
  String get hours => 'Stunden';

  @override
  String get minutes => 'Minuten';

  @override
  String get noInputError => 'Bitte geben Sie eine Dauer ein.\nNur Ziffern erlaubt';

  @override
  String get description => 'Beschreibung';

  @override
  String get date => 'Datum';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get entrySaved => 'Eintrag gespeichert';

  @override
  String get unexpectedError => 'Unerwarteter Fehler';

  @override
  String get inputTooLargeOrNanException => 'Eingegebener Wert ist zu groß oder keine ganze Zahl';

  @override
  String get inputTooLargeException => 'Eingegebener Wert ist zu groß';

  @override
  String get inputSumTooLargeException => 'Summe der beiden Werte ist zu groß';

  @override
  String get inputInvalidException => 'Eingegebener Wert ist ungültig';

  @override
  String get createNewEntry => 'Neuen Eintrag erfassen';

  @override
  String get recentEntries => 'Letzte Einträge';

  @override
  String get showAllEntries => 'Alle Einträge anzeigen';

  @override
  String get noExistingEntries => 'Noch keine Einträge vorhanden';

  @override
  String get currentWeek => 'Aktuelle Woche';

  @override
  String get currentMonth => 'Aktueller Monat';

  @override
  String get systemBrightness => 'System';

  @override
  String get darkMode => 'Dunkel';

  @override
  String get lightMode => 'Hell';

  @override
  String get appearance => 'Darstellung';

  @override
  String get categories => 'Kategorien';

  @override
  String deleteCategoryConfirmationDialog(Object category) {
    return 'Wollen Sie die Kategorie $category wirklich löschen?\n\nEinträge, die dieser Kategorie zugeordnet sind, werden nicht verändert.';
  }

  @override
  String get noExistingCategories => 'Noch keine Kategorien vorhanden';

  @override
  String get addNewCategory => 'Neue Kategorie hinzufügen';

  @override
  String get editCategory => 'Kategorie bearbeiten';

  @override
  String get editCategories => 'Kategorien bearbeiten';

  @override
  String get emptyCategoryNameError => 'Bitte geben Sie einen Namen ein';

  @override
  String get category => 'Kategorie';

  @override
  String get add => 'Hinzufügen';

  @override
  String get contact => 'Kontakt';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get privacyPolicyUrlFragment => 'datenschutzrichtlinie-für-kgl-time';

  @override
  String get confirmDelete => 'Löschen bestätigen';

  @override
  String get delete => 'Löschen';

  @override
  String get confirmDeleteDialog => 'Wollen Sie den Eintrag wirklich löschen?';

  @override
  String get selectCategory => 'Kategorie wählen';

  @override
  String runningForDuration(Object duration) {
    return 'läuft seit $duration';
  }

  @override
  String get trackTime => 'Zeit erfassen';

  @override
  String get start => 'Start';

  @override
  String get stop => 'Stopp';

  @override
  String get home => 'Startseite';
}

/// The translations for German, as used in Austria (`de_AT`).
class AppLocalizationsDeAt extends AppLocalizationsDe {
  AppLocalizationsDeAt(): super('de_AT');


}

/// The translations for German, as used in Switzerland (`de_CH`).
class AppLocalizationsDeCh extends AppLocalizationsDe {
  AppLocalizationsDeCh(): super('de_CH');

  @override
  String get inputTooLargeOrNanException => 'Eingegebener Wert ist zu gross oder keine ganze Zahl';

  @override
  String get inputTooLargeException => 'Eingegebener Wert ist zu gross';

  @override
  String get inputSumTooLargeException => 'Summe der beiden Werte ist zu gross';

  @override
  String get stop => 'Stop';
}
