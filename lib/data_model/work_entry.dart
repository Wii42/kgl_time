import 'package:isar_community/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:uuid/uuid.dart';

import '../format_duration.dart';
import 'isar_storable.dart';

part 'work_entry.g.dart';

@Collection(accessor: 'workEntries')
@JsonSerializable()
class WorkEntry implements IsarStorable {
  @override
  Id id = Isar.autoIncrement;
  @JsonKey(defaultValue: "")
  final String uuid;
  int workDurationInSeconds;
  @JsonKey(defaultValue: dateTimeEpoch)
  DateTime date;
  String? description;
  List<EmbeddedWorkCategory> categories;
  DateTime? startTime;
  DateTime? endTime;
  DateTime lastEdit;
  bool tickedOff;
  @Enumerated(EnumType.ordinal32)
  CreateWorkEntryType? createType;
  bool wasEdited;
  DateTime? wasMovedToTrashAt;

  WorkEntry(
      {required this.uuid,
        required this.workDurationInSeconds,
      required this.date,
      this.description,
      this.categories = const [],
      this.startTime,
      this.endTime,
      required this.lastEdit,
      this.tickedOff = false,
      this.createType,
      this.wasEdited = false,
      this.wasMovedToTrashAt,});

  @ignore
  Duration get workDuration => Duration(seconds: workDurationInSeconds);

  @ignore
  bool get isInTrash => wasMovedToTrashAt != null;

  Map<String, dynamic> toJson() => _$WorkEntryToJson(this);

  factory WorkEntry.fromJson(Map<String, dynamic> json) =>
      _$WorkEntryFromJson(json);

  factory WorkEntry.fromDuration({
    required Duration duration,
    required DateTime date,
    String? description,
    List<EmbeddedWorkCategory> categories = const [],
    bool tickedOff = false,
    CreateWorkEntryType? createType,
    DateTime? wasMovedToTrashAt,
  }) {
    return WorkEntry(
      uuid: generateUuid(),
      workDurationInSeconds: duration.inSeconds,
      date: date,
      description: description,
      categories: categories,
      lastEdit: DateTime.now(),
      tickedOff: tickedOff,
      createType: createType,
      wasEdited: false,
      wasMovedToTrashAt: wasMovedToTrashAt,
    );
  }

  factory WorkEntry.fromStartAndEndTime({
    required DateTime startTime,
    required DateTime endTime,
    String? description,
    List<EmbeddedWorkCategory> categories = const [],
    bool tickedOff = false,
    CreateWorkEntryType? createType,
    DateTime? wasMovedToTrashAt,
  }) {
    return WorkEntry(
      uuid: generateUuid(),
      workDurationInSeconds: endTime.difference(startTime).inSeconds,
      date: startTime,
      description: description,
      categories: categories,
      startTime: startTime,
      endTime: endTime,
      lastEdit: DateTime.now(),
      tickedOff: tickedOff,
      createType: createType,
      wasEdited: false,
      wasMovedToTrashAt: wasMovedToTrashAt,
    );
  }

  WorkEntry withTrashStatus(DateTime? movedToTrashAt, {bool? tickedOff}) {
    return copyWith(
      tickedOff: tickedOff ?? this.tickedOff,
      wasMovedToTrashAt: movedToTrashAt,
    );
  }

  WorkEntry copyWith({
    String? uuid,
    int? workDurationInSeconds,
    DateTime? date,
    String? description,
    List<EmbeddedWorkCategory>? categories,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? lastEdit,
    bool? tickedOff,
    CreateWorkEntryType? createType,
    bool? wasEdited,
    DateTime? wasMovedToTrashAt,
  }) {
    return WorkEntry(
      uuid: uuid ?? this.uuid,
      workDurationInSeconds: workDurationInSeconds ?? this.workDurationInSeconds,
      date: date ?? this.date,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      lastEdit: lastEdit ?? this.lastEdit,
      tickedOff: tickedOff ?? this.tickedOff,
      createType: createType ?? this.createType,
      wasEdited: wasEdited ?? this.wasEdited,
      wasMovedToTrashAt: wasMovedToTrashAt ?? this.wasMovedToTrashAt,
    )..id = id;
  }

  @override
  String toString() {
    return 'WorkEntry{id: $id, uuid: $uuid, workDurationInSeconds: $workDurationInSeconds, date: $date, description: $description, categories: $categories, startTime: $startTime, endTime: $endTime, lastEdit: $lastEdit, tickedOff: $tickedOff, createType: $createType, wasEdited: $wasEdited, wasMovedToTrashAt: $wasMovedToTrashAt, isInTrash: $isInTrash}';
  }

  static String generateUuid() {
    return Uuid().v4();
  }
}

enum CreateWorkEntryType { timeTracker, manualDuration, manualStartAndEndTime }
