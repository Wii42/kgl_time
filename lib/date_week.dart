import 'package:clock/clock.dart';

class DateWeek {
  final DateTime start;
  final DateTime end;

  DateWeek(this.start, this.end);

  factory DateWeek.from(DateTime dateTime) {
    // Calendar dates keep boundaries at midnight across daylight-saving changes.
    DateTime startOfWeek = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day - (dateTime.weekday - DateTime.monday),
    );
    DateTime endOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day + 7);
    return DateWeek(startOfWeek, endOfWeek);
  }

  factory DateWeek.current() {
    return DateWeek.from(clock.now());
  }

  bool contains(DateTime date) {
    return (date.isAtSameMomentAs(start) || date.isAfter(start)) && date.isBefore(end);
  }

  DateWeek next() {
    return DateWeek(end, DateTime(end.year, end.month, end.day + 7));
  }

  DateWeek previous() {
    return DateWeek(DateTime(start.year, start.month, start.day - 7), start);
  }
}
