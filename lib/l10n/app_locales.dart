import 'package:material_ui/material_ui.dart';

/// Shared by startup and MaterialApp so initial data uses the UI's language.
/// English is the fallback when no preferred language is supported.
const List<Locale> supportedAppLocales = [
  Locale('en'),
  Locale('de'),
  Locale('de', 'CH'),
  Locale('de', 'AT'),
];
