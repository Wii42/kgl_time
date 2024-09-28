String formatDuration(Duration duration) {
  List<String> parts = [];
  if (duration.inHours > 0) {
    parts.add('${duration.inHours}h');
  }
  if (duration.inMinutes.remainder(60) > 0) {
    parts.add('${duration.inMinutes.remainder(60)} min');
  }
  return parts.join(' ');
}