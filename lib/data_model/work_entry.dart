import 'package:isar_community/isar.dart';
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
  DateTime? wasMovedToTrashAt;

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
      this.wasEdited = false,
      this.wasMovedToTrashAt});

  @ignore
  Duration get workDuration => Duration(seconds: workDurationInSeconds);

  @ignore
  bool get isInTrash => wasMovedToTrashAt != null;

  factory WorkEntry.fromDuration({
    required Duration duration,
    required DateTime date,
    String? description,
    List<EmbeddedWorkCategory> categories = const [],
    DateTime? lastEdit,
    bool tickedOff = false,
    CreateWorkEntryType? createType,
    bool wasEdited = false,
    DateTime? wasMovedToTrashAt,
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
      wasMovedToTrashAt: wasMovedToTrashAt,
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
    DateTime? wasMovedToTrashAt,
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
      wasMovedToTrashAt: wasMovedToTrashAt,
    );
  }

  WorkEntry withTrashStatus(DateTime? movedToTrashAt, {bool? tickedOff}) {
    return WorkEntry(
      workDurationInSeconds: workDurationInSeconds,
      date: date,
      description: description,
      categories: categories,
      startTime: startTime,
      endTime: endTime,
      lastEdit: lastEdit,
      tickedOff: tickedOff ?? this.tickedOff,
      createType: createType,
      wasEdited: wasEdited,
      wasMovedToTrashAt: movedToTrashAt,
    );
  }

  @override
  String toString() {
    return 'WorkEntry{id: $id, workDurationInSeconds: $workDurationInSeconds, date: $date, description: $description, categories: $categories, startTime: $startTime, endTime: $endTime, lastEdit: $lastEdit, tickedOff: $tickedOff, createType: $createType, wasEdited: $wasEdited, wasMovedToTrashAt: $wasMovedToTrashAt, isInTrash: $isInTrash}';
  }
}

enum CreateWorkEntryType { timeTracker, manualDuration, manualStartAndEndTime }
