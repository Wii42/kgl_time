import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/l10n/app_locales.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/main.dart' as app;
import 'package:material_ui/material_ui.dart';

void main() {
  const List<String> english = ['Planning', 'Meetings', 'Administration'];
  const List<String> german = ['Planung', 'Besprechungen', 'Verwaltung'];

  for (final (List<Locale> preferences, Locale expectedLocale, List<String> names)
      in <(List<Locale>, Locale, List<String>)>[
        ([const Locale('en', 'US')], const Locale('en'), english),
        ([const Locale('de', 'DE')], const Locale('de'), german),
        ([const Locale('de', 'CH')], const Locale('de', 'CH'), german),
        ([const Locale('de', 'AT')], const Locale('de', 'AT'), german),
        ([const Locale('fr')], const Locale('en'), english),
        ([const Locale('fr'), const Locale('de')], const Locale('de'), german),
        ([], const Locale('en'), english),
      ]) {
    test('initial categories follow preferred languages $preferences', () async {
      final Locale locale = basicLocaleListResolution(preferences, supportedAppLocales);
      expect(locale, expectedLocale);
      final AppLocalizations loc = await AppLocalizations.delegate.load(locale);
      final List<WorkCategory> categories = app.createInitialCategories(loc);

      expect(categories.map((WorkCategory category) => category.displayName), names);
      expect(categories.map((WorkCategory category) => category.listIndex), [0, 1, 2]);
      expect(categories.map((WorkCategory category) => category.icon), everyElement(isNull));
    });
  }
}
