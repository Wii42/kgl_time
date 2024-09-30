import 'package:isar/isar.dart';
import 'package:kgl_time/enums/work_category.dart';

part 'work_entry.g.dart';

@collection
class WorkEntry {
  Id id = Isar.autoIncrement;
  int workDurationInSeconds;
  DateTime date;
  String? description;
  @enumerated
  List<WorkCategory> categories;
  DateTime? startTime;
  DateTime? endTime;

  WorkEntry(
      {required this.workDurationInSeconds,
      required this.date,
      this.description,
      this.categories = const [],
      this.startTime,
      this.endTime});

  @ignore
  Duration get workDuration => Duration(seconds: workDurationInSeconds);
}
