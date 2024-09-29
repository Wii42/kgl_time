class WorkEntry {
  int id;
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
  category2('Kategorie 2'),
  category3('Kategorie 3'),
  category4('Kategorie 4'),
  category5('Kategorie 5'),
  ;

  final String displayName;

  const WorkCategory(this.displayName);
}
