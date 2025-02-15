import 'package:isar/isar.dart';
import 'package:kgl_time/data_model/work_category.dart';

import 'isar_storable.dart';

part 'work_entry.g.dart';

@Collection(accessor: 'workEntries')
class WorkEntry implements IsarStorable {
  @override
  Id id = Isar.autoIncrement;
  int workDurationInSeconds;
  DateTime date;
  String? description;
  List<EmbeddedWorkCategory> categories;
  DateTime? startTime;
  DateTime? endTime;
  DateTime? lastEdit;
  bool tickedOff;
  @Enumerated(EnumType.ordinal32)
  CreateWorkEntryType? createType;
  bool wasEdited;

  WorkEntry(
      {required this.workDurationInSeconds,
      required this.date,
      this.description,
      this.categories = const [],
      this.startTime,
      this.endTime,
      this.lastEdit,
      this.tickedOff = false,
      this.createType,
      this.wasEdited = false});

  @ignore
  Duration get workDuration => Duration(seconds: workDurationInSeconds);

  factory WorkEntry.fromDuration({
    required Duration duration,
    required DateTime date,
    String? description,
    List<EmbeddedWorkCategory> categories = const [],
    DateTime? lastEdit,
    bool tickedOff = false,
    CreateWorkEntryType? createType,
    bool wasEdited = false,
  }) {
    return WorkEntry(
      workDurationInSeconds: duration.inSeconds,
      date: date,
      description: description,
      categories: categories,
      lastEdit: lastEdit,
      tickedOff: tickedOff,
      createType: createType,
      wasEdited: wasEdited,
    );
  }

  factory WorkEntry.fromStartAndEndTime({
    required DateTime startTime,
    required DateTime endTime,
    String? description,
    List<EmbeddedWorkCategory> categories = const [],
    DateTime? lastEdit,
    bool tickedOff = false,
    CreateWorkEntryType? createType,
    bool wasEdited = false,
  }) {
    return WorkEntry(
      workDurationInSeconds: endTime.difference(startTime).inSeconds,
      date: startTime,
      description: description,
      categories: categories,
      startTime: startTime,
      endTime: endTime,
      lastEdit: lastEdit,
      tickedOff: tickedOff,
      createType: createType,
      wasEdited: wasEdited,
    );
  }
}

enum CreateWorkEntryType { timeTracker, manualDuration, manualStartAndEndTime }
