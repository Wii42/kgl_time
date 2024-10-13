import 'package:isar/isar.dart';
import 'package:kgl_time/data_model/work_category.dart';

import '../isar_icon_data.dart';
import 'isar_storable.dart';

part 'work_entry.g.dart';

@collection
class WorkEntry implements IsarStorable {
  @override
  Id id = Isar.autoIncrement;
  int workDurationInSeconds;
  DateTime date;
  String? description;
  @enumerated
  List<EmbeddedWorkCategory> categories;
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
