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

String formatDate(DateTime date) =>
    DateFormat('EE dd.MM.yyyy', 'de').format(date);

String formatTime(DateTime time) =>
    DateFormat('HH:mm', 'de').format(time);
