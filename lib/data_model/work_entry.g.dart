// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWorkEntryCollection on Isar {
  IsarCollection<WorkEntry> get workEntries => this.collection();
}

const WorkEntrySchema = CollectionSchema(
  name: r'WorkEntry',
  id: 4479961749987691035,
  properties: {
    r'categories': PropertySchema(
      id: 0,
      name: r'categories',
      type: IsarType.objectList,
      target: r'EmbeddedWorkCategory',
    ),
    r'createType': PropertySchema(
      id: 1,
      name: r'createType',
      type: IsarType.int,
      enumMap: _WorkEntrycreateTypeEnumValueMap,
    ),
    r'date': PropertySchema(
      id: 2,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 3,
      name: r'description',
      type: IsarType.string,
    ),
    r'endTime': PropertySchema(
      id: 4,
      name: r'endTime',
      type: IsarType.dateTime,
    ),
    r'lastEdit': PropertySchema(
      id: 5,
      name: r'lastEdit',
      type: IsarType.dateTime,
    ),
    r'startTime': PropertySchema(
      id: 6,
      name: r'startTime',
      type: IsarType.dateTime,
    ),
    r'tickedOff': PropertySchema(
      id: 7,
      name: r'tickedOff',
      type: IsarType.bool,
    ),
    r'wasEdited': PropertySchema(
      id: 8,
      name: r'wasEdited',
      type: IsarType.bool,
    ),
    r'wasMovedToTrashAt': PropertySchema(
      id: 9,
      name: r'wasMovedToTrashAt',
      type: IsarType.dateTime,
    ),
    r'workDurationInSeconds': PropertySchema(
      id: 10,
      name: r'workDurationInSeconds',
      type: IsarType.long,
    )
  },
  estimateSize: _workEntryEstimateSize,
  serialize: _workEntrySerialize,
  deserialize: _workEntryDeserialize,
  deserializeProp: _workEntryDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'EmbeddedWorkCategory': EmbeddedWorkCategorySchema},
  getId: _workEntryGetId,
  getLinks: _workEntryGetLinks,
  attach: _workEntryAttach,
  version: '3.3.0-dev.3',
);

int _workEntryEstimateSize(
  WorkEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.categories.length * 3;
  {
    final offsets = allOffsets[EmbeddedWorkCategory]!;
    for (var i = 0; i < object.categories.length; i++) {
      final value = object.categories[i];
      bytesCount +=
          EmbeddedWorkCategorySchema.estimateSize(value, offsets, allOffsets);
    }
  }
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _workEntrySerialize(
  WorkEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<EmbeddedWorkCategory>(
    offsets[0],
    allOffsets,
    EmbeddedWorkCategorySchema.serialize,
    object.categories,
  );
  writer.writeInt(offsets[1], object.createType?.index);
  writer.writeDateTime(offsets[2], object.date);
  writer.writeString(offsets[3], object.description);
  writer.writeDateTime(offsets[4], object.endTime);
  writer.writeDateTime(offsets[5], object.lastEdit);
  writer.writeDateTime(offsets[6], object.startTime);
  writer.writeBool(offsets[7], object.tickedOff);
  writer.writeBool(offsets[8], object.wasEdited);
  writer.writeDateTime(offsets[9], object.wasMovedToTrashAt);
  writer.writeLong(offsets[10], object.workDurationInSeconds);
}

WorkEntry _workEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WorkEntry(
    categories: reader.readObjectList<EmbeddedWorkCategory>(
          offsets[0],
          EmbeddedWorkCategorySchema.deserialize,
          allOffsets,
          EmbeddedWorkCategory(),
        ) ??
        const [],
    createType:
        _WorkEntrycreateTypeValueEnumMap[reader.readIntOrNull(offsets[1])],
    date: reader.readDateTime(offsets[2]),
    description: reader.readStringOrNull(offsets[3]),
    endTime: reader.readDateTimeOrNull(offsets[4]),
    lastEdit: reader.readDateTimeOrNull(offsets[5]),
    startTime: reader.readDateTimeOrNull(offsets[6]),
    tickedOff: reader.readBoolOrNull(offsets[7]) ?? false,
    wasEdited: reader.readBoolOrNull(offsets[8]) ?? false,
    wasMovedToTrashAt: reader.readDateTimeOrNull(offsets[9]),
    workDurationInSeconds: reader.readLong(offsets[10]),
  );
  object.id = id;
  return object;
}

P _workEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<EmbeddedWorkCategory>(
            offset,
            EmbeddedWorkCategorySchema.deserialize,
            allOffsets,
            EmbeddedWorkCategory(),
          ) ??
          const []) as P;
    case 1:
      return (_WorkEntrycreateTypeValueEnumMap[reader.readIntOrNull(offset)])
          as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 8:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _WorkEntrycreateTypeEnumValueMap = {
  'timeTracker': 0,
  'manualDuration': 1,
  'manualStartAndEndTime': 2,
};
const _WorkEntrycreateTypeValueEnumMap = {
  0: CreateWorkEntryType.timeTracker,
  1: CreateWorkEntryType.manualDuration,
  2: CreateWorkEntryType.manualStartAndEndTime,
};

Id _workEntryGetId(WorkEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _workEntryGetLinks(WorkEntry object) {
  return [];
}

void _workEntryAttach(IsarCollection<dynamic> col, Id id, WorkEntry object) {
  object.id = id;
}

extension WorkEntryQueryWhereSort
    on QueryBuilder<WorkEntry, WorkEntry, QWhere> {
  QueryBuilder<WorkEntry, WorkEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension WorkEntryQueryWhere
    on QueryBuilder<WorkEntry, WorkEntry, QWhereClause> {
  QueryBuilder<WorkEntry, WorkEntry, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WorkEntryQueryFilter
    on QueryBuilder<WorkEntry, WorkEntry, QFilterCondition> {
  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      categoriesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'categories',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      categoriesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'categories',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      categoriesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'categories',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      categoriesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'categories',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      categoriesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'categories',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      categoriesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'categories',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> createTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createType',
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      createTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createType',
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> createTypeEqualTo(
      CreateWorkEntryType? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createType',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      createTypeGreaterThan(
    CreateWorkEntryType? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createType',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> createTypeLessThan(
    CreateWorkEntryType? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createType',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> createTypeBetween(
    CreateWorkEntryType? lower,
    CreateWorkEntryType? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> descriptionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> descriptionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> endTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endTime',
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> endTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endTime',
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> endTimeEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> endTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> endTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> endTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> lastEditIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastEdit',
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      lastEditIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastEdit',
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> lastEditEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastEdit',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> lastEditGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastEdit',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> lastEditLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastEdit',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> lastEditBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastEdit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> startTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startTime',
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      startTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startTime',
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> startTimeEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      startTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> startTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> startTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> tickedOffEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tickedOff',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> wasEditedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wasEdited',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      wasMovedToTrashAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'wasMovedToTrashAt',
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      wasMovedToTrashAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'wasMovedToTrashAt',
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      wasMovedToTrashAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wasMovedToTrashAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      wasMovedToTrashAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wasMovedToTrashAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      wasMovedToTrashAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wasMovedToTrashAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      wasMovedToTrashAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wasMovedToTrashAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      workDurationInSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'workDurationInSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      workDurationInSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'workDurationInSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      workDurationInSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'workDurationInSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition>
      workDurationInSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'workDurationInSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WorkEntryQueryObject
    on QueryBuilder<WorkEntry, WorkEntry, QFilterCondition> {
  QueryBuilder<WorkEntry, WorkEntry, QAfterFilterCondition> categoriesElement(
      FilterQuery<EmbeddedWorkCategory> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'categories');
    });
  }
}

extension WorkEntryQueryLinks
    on QueryBuilder<WorkEntry, WorkEntry, QFilterCondition> {}

extension WorkEntryQuerySortBy on QueryBuilder<WorkEntry, WorkEntry, QSortBy> {
  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> sortByCreateType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createType', Sort.asc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> sortByCreateTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createType', Sort.desc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> sortByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> sortByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> sortByLastEdit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEdit', Sort.asc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> sortByLastEditDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEdit', Sort.desc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> sortByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> sortByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> sortByTickedOff() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tickedOff', Sort.asc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> sortByTickedOffDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tickedOff', Sort.desc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> sortByWasEdited() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasEdited', Sort.asc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> sortByWasEditedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasEdited', Sort.desc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> sortByWasMovedToTrashAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasMovedToTrashAt', Sort.asc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy>
      sortByWasMovedToTrashAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasMovedToTrashAt', Sort.desc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy>
      sortByWorkDurationInSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workDurationInSeconds', Sort.asc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy>
      sortByWorkDurationInSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workDurationInSeconds', Sort.desc);
    });
  }
}

extension WorkEntryQuerySortThenBy
    on QueryBuilder<WorkEntry, WorkEntry, QSortThenBy> {
  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> thenByCreateType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createType', Sort.asc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> thenByCreateTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createType', Sort.desc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> thenByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> thenByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> thenByLastEdit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEdit', Sort.asc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> thenByLastEditDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEdit', Sort.desc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> thenByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> thenByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> thenByTickedOff() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tickedOff', Sort.asc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> thenByTickedOffDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tickedOff', Sort.desc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> thenByWasEdited() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasEdited', Sort.asc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> thenByWasEditedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasEdited', Sort.desc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy> thenByWasMovedToTrashAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasMovedToTrashAt', Sort.asc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy>
      thenByWasMovedToTrashAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasMovedToTrashAt', Sort.desc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy>
      thenByWorkDurationInSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workDurationInSeconds', Sort.asc);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QAfterSortBy>
      thenByWorkDurationInSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workDurationInSeconds', Sort.desc);
    });
  }
}

extension WorkEntryQueryWhereDistinct
    on QueryBuilder<WorkEntry, WorkEntry, QDistinct> {
  QueryBuilder<WorkEntry, WorkEntry, QDistinct> distinctByCreateType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createType');
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QDistinct> distinctByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endTime');
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QDistinct> distinctByLastEdit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastEdit');
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QDistinct> distinctByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startTime');
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QDistinct> distinctByTickedOff() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tickedOff');
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QDistinct> distinctByWasEdited() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wasEdited');
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QDistinct> distinctByWasMovedToTrashAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wasMovedToTrashAt');
    });
  }

  QueryBuilder<WorkEntry, WorkEntry, QDistinct>
      distinctByWorkDurationInSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'workDurationInSeconds');
    });
  }
}

extension WorkEntryQueryProperty
    on QueryBuilder<WorkEntry, WorkEntry, QQueryProperty> {
  QueryBuilder<WorkEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WorkEntry, List<EmbeddedWorkCategory>, QQueryOperations>
      categoriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categories');
    });
  }

  QueryBuilder<WorkEntry, CreateWorkEntryType?, QQueryOperations>
      createTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createType');
    });
  }

  QueryBuilder<WorkEntry, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<WorkEntry, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<WorkEntry, DateTime?, QQueryOperations> endTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endTime');
    });
  }

  QueryBuilder<WorkEntry, DateTime?, QQueryOperations> lastEditProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastEdit');
    });
  }

  QueryBuilder<WorkEntry, DateTime?, QQueryOperations> startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startTime');
    });
  }

  QueryBuilder<WorkEntry, bool, QQueryOperations> tickedOffProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tickedOff');
    });
  }

  QueryBuilder<WorkEntry, bool, QQueryOperations> wasEditedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wasEdited');
    });
  }

  QueryBuilder<WorkEntry, DateTime?, QQueryOperations>
      wasMovedToTrashAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wasMovedToTrashAt');
    });
  }

  QueryBuilder<WorkEntry, int, QQueryOperations>
      workDurationInSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'workDurationInSeconds');
    });
  }
}
