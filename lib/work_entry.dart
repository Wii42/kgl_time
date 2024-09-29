import 'package:isar/isar.dart';

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

enum WorkCategory {
  phoneCall('Telefonanruf'),
  category2('Kategorie 2'),
  category3('Kategorie 3'),
  category4('Kategorie 4'),
  category5('Kategorie 5'),
  ;

  final String displayName;

  const WorkCategory(this.displayName);
}
