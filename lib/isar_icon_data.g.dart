// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_icon_data.dart';

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const IsarIconDataSchema = Schema(
  name: r'IsarIconData',
  id: 7259529122159568570,
  properties: {
    r'codePoint': PropertySchema(
      id: 0,
      name: r'codePoint',
      type: IsarType.long,
    ),
    r'fontFamily': PropertySchema(
      id: 1,
      name: r'fontFamily',
      type: IsarType.string,
    ),
    r'fontFamilyFallback': PropertySchema(
      id: 2,
      name: r'fontFamilyFallback',
      type: IsarType.stringList,
    ),
    r'fontPackage': PropertySchema(
      id: 3,
      name: r'fontPackage',
      type: IsarType.string,
    ),
    r'hashCode': PropertySchema(
      id: 4,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'matchTextDirection': PropertySchema(
      id: 5,
      name: r'matchTextDirection',
      type: IsarType.bool,
    )
  },
  estimateSize: _isarIconDataEstimateSize,
  serialize: _isarIconDataSerialize,
  deserialize: _isarIconDataDeserialize,
  deserializeProp: _isarIconDataDeserializeProp,
);

int _isarIconDataEstimateSize(
  IsarIconData object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.fontFamily;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.fontFamilyFallback;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.fontPackage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _isarIconDataSerialize(
  IsarIconData object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.codePoint);
  writer.writeString(offsets[1], object.fontFamily);
  writer.writeStringList(offsets[2], object.fontFamilyFallback);
  writer.writeString(offsets[3], object.fontPackage);
  writer.writeLong(offsets[4], object.hashCode);
  writer.writeBool(offsets[5], object.matchTextDirection);
}

IsarIconData _isarIconDataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarIconData(
    codePoint: reader.readLongOrNull(offsets[0]) ?? 61183,
    fontFamily: reader.readStringOrNull(offsets[1]),
    fontFamilyFallback: reader.readStringList(offsets[2]),
    fontPackage: reader.readStringOrNull(offsets[3]),
    matchTextDirection: reader.readBoolOrNull(offsets[5]) ?? false,
  );
  return object;
}

P _isarIconDataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 61183) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringList(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension IsarIconDataQueryFilter
    on QueryBuilder<IsarIconData, IsarIconData, QFilterCondition> {
  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      codePointEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codePoint',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      codePointGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'codePoint',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      codePointLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'codePoint',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      codePointBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'codePoint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fontFamily',
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fontFamily',
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fontFamily',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fontFamily',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fontFamily',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fontFamily',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyFallbackIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fontFamilyFallback',
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyFallbackIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fontFamilyFallback',
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyFallbackElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fontFamilyFallback',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyFallbackElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fontFamilyFallback',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyFallbackElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fontFamilyFallback',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyFallbackElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fontFamilyFallback',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyFallbackElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fontFamilyFallback',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyFallbackElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fontFamilyFallback',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyFallbackElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fontFamilyFallback',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyFallbackElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fontFamilyFallback',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyFallbackElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fontFamilyFallback',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyFallbackElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fontFamilyFallback',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyFallbackLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fontFamilyFallback',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyFallbackIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fontFamilyFallback',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyFallbackIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fontFamilyFallback',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyFallbackLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fontFamilyFallback',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyFallbackLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fontFamilyFallback',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontFamilyFallbackLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fontFamilyFallback',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontPackageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fontPackage',
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontPackageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fontPackage',
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontPackageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fontPackage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontPackageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fontPackage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontPackageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fontPackage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontPackageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fontPackage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontPackageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fontPackage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontPackageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fontPackage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontPackageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fontPackage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontPackageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fontPackage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontPackageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fontPackage',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      fontPackageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fontPackage',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      hashCodeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      hashCodeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      hashCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hashCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarIconData, IsarIconData, QAfterFilterCondition>
      matchTextDirectionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'matchTextDirection',
        value: value,
      ));
    });
  }
}

extension IsarIconDataQueryObject
    on QueryBuilder<IsarIconData, IsarIconData, QFilterCondition> {}
