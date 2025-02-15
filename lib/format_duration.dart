import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

String formatDuration(Duration duration) {
  List<String> parts = [];
  if (duration.inHours > 0) {
    parts.add('${duration.inHours}h');
  }
  if (duration.inMinutes.remainder(60) > 0 || parts.isEmpty) {
    parts.add('${duration.inMinutes.remainder(60)} min');
  }
  return parts.join(' ');
}

String formatDate(DateTime date, AppLocalizations? loc) =>
    DateFormat('EE dd.MM.yyyy', loc?.localeName).format(date);

String formatTime(DateTime time) => DateFormat('HH:mm').format(time);
