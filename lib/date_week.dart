class DateWeek {
  final DateTime start;
  final DateTime end;

  static const Duration weekDuration = Duration(days: 7);

  DateWeek(this.start, this.end);

  factory DateWeek.from(DateTime dateTime) {
    DateTime date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    DateTime startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(weekDuration);
    return DateWeek(startOfWeek, endOfWeek);
  }

  factory DateWeek.current() {
    return DateWeek.from(DateTime.now());
  }

  bool contains(DateTime date) {
    return (date.isAtSameMomentAs(start) || date.isAfter(start)) &&
        date.isBefore(end);
  }

  DateWeek next() {
    return DateWeek(end, end.add(weekDuration));
  }

  DateWeek previous() {
    return DateWeek(start.subtract(Duration(days: 7)), start);
  }
}
