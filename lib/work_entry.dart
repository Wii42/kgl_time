class WorkEntry {
  String id;
  Duration workDuration;
  DateTime date;
  String? description;
  List<WorkCategory> categories;
  DateTime? startTime;
  DateTime? endTime;

  WorkEntry(
      {required this.id,
      required this.workDuration,
      required this.date,
      this.description,
      this.categories = const [],
      this.startTime,
      this.endTime});
}

enum WorkCategory {
  phoneCall('Telefonanruf'),
  ;
  final String displayName;

  const WorkCategory(this.displayName);
}
