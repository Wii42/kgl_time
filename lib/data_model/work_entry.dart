import 'package:isar_community/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:kgl_time/data_model/value.dart';
import 'package:kgl_time/data_model/work_category.dart';

import '../utils/format_duration.dart';
import 'isar_storable.dart';

part 'work_entry.g.dart';

@Collection(accessor: 'workEntries')
@JsonSerializable()
class WorkEntry implements IsarStorable {
  @override
  Id id = Isar.autoIncrement;
  int workDurationInSeconds;
  @JsonKey(defaultValue: dateTimeEpoch)
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

  WorkEntry({
    required this.workDurationInSeconds,
    required this.date,
    this.description,
    this.categories = const [],
    this.startTime,
    this.endTime,
    this.lastEdit,
    this.tickedOff = false,
    this.createType,
    this.wasEdited = false,
    this.wasMovedToTrashAt,
  });

  @ignore
  Duration get workDuration => Duration(seconds: workDurationInSeconds);

  @ignore
  bool get isInTrash => wasMovedToTrashAt != null;

  Map<String, dynamic> toJson() => _$WorkEntryToJson(this);

  factory WorkEntry.fromJson(Map<String, dynamic> json) => _$WorkEntryFromJson(json);

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
    return copyWith(
      tickedOff: tickedOff ?? this.tickedOff,
      wasMovedToTrashAt: Value<DateTime?>(movedToTrashAt),
    );
  }

  WorkEntry copyWith({
    int? workDurationInSeconds,
    DateTime? date,
    Value<String?>? description,
    List<EmbeddedWorkCategory>? categories,
    Value<DateTime?>? startTime,
    Value<DateTime?>? endTime,
    Value<DateTime?>? lastEdit,
    bool? tickedOff,
    Value<CreateWorkEntryType?>? createType,
    bool? wasEdited,
    Value<DateTime?>? wasMovedToTrashAt,
  }) {
    return WorkEntry(
      workDurationInSeconds: workDurationInSeconds ?? this.workDurationInSeconds,
      date: date ?? this.date,
      description: description == null ? this.description : description.value,
      categories: categories ?? this.categories,
      startTime: startTime == null ? this.startTime : startTime.value,
      endTime: endTime == null ? this.endTime : endTime.value,
      lastEdit: lastEdit == null ? this.lastEdit : lastEdit.value,
      tickedOff: tickedOff ?? this.tickedOff,
      createType: createType == null ? this.createType : createType.value,
      wasEdited: wasEdited ?? this.wasEdited,
      wasMovedToTrashAt: wasMovedToTrashAt == null
          ? this.wasMovedToTrashAt
          : wasMovedToTrashAt.value,
    )..id = id;
  }

  @override
  String toString() {
    return 'WorkEntry{id: $id, workDurationInSeconds: $workDurationInSeconds, date: $date, description: $description, categories: $categories, startTime: $startTime, endTime: $endTime, lastEdit: $lastEdit, tickedOff: $tickedOff, createType: $createType, wasEdited: $wasEdited, wasMovedToTrashAt: $wasMovedToTrashAt, isInTrash: $isInTrash}';
  }
}

enum CreateWorkEntryType { timeTracker, manualDuration, manualStartAndEndTime }
