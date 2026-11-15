import 'dart:developer';

import '../data_model/work_category.dart';
import '../data_model/work_entry.dart';

class WorkData {
  /// Each supported version must have a corresponding reader below.
  static bool isSupportedVersion(int version) => version == 1;

  final List<WorkEntry> workEntries;
  final List<WorkCategory> workCategories;
  final int backupFormatVersion;
  final DateTime exportedAt;

  const WorkData({
    required this.workEntries,
    required this.workCategories,
    required this.backupFormatVersion,
    required this.exportedAt,
  });

  Map<String, dynamic> toJson() => {
    'backupFormatVersion': backupFormatVersion,
    'exportedAt': exportedAt.toIso8601String(),
    'workEntries': workEntries.map((e) => e.toJson()).toList(),
    'workCategories': workCategories.map((c) => c.toJson()).toList(),
  };

  factory WorkData.fromJson(Map<String, dynamic> json) {
    final int version = _integer(json['backupFormatVersion'], 'backupFormatVersion');
    if (!isSupportedVersion(version)) {
      throw FormatException('Unsupported backup format version: $version');
    }
    final WorkData data = WorkData(
      backupFormatVersion: version,
      exportedAt: _date(json['exportedAt'], 'exportedAt'),
      workEntries: (json['workEntries'] as List<dynamic>).map((dynamic value) {
        final Map<String, dynamic> entry = value as Map<String, dynamic>;
        _id(entry['id'], 'workEntries.id');
        _integer(entry['workDurationInSeconds'], 'workDurationInSeconds');
        _date(entry['date'], 'date');
        for (final dynamic category in entry['categories'] as List<dynamic>? ?? <dynamic>[]) {
          final Map<String, dynamic> embedded = category as Map<String, dynamic>;
          if (embedded['id'] != null) _id(embedded['id'], 'embedded category.id');
        }
        return WorkEntry.fromJson(entry);
      }).toList(),
      workCategories: (json['workCategories'] as List<dynamic>).map((dynamic value) {
        final Map<String, dynamic> category = value as Map<String, dynamic>;
        _id(category['id'], 'workCategories.id');
        _integer(category['listIndex'], 'listIndex');
        return WorkCategory.fromJson(category);
      }).toList(),
    );
    data.validate();
    return data;
  }

  /// Checks data constructed directly as well as data read from JSON.
  void validate() {
    if (!isSupportedVersion(backupFormatVersion)) {
      throw FormatException('Unsupported backup format version: $backupFormatVersion');
    }
    final Set<int> entryIds = <int>{};
    for (final WorkEntry entry in workEntries) {
      _id(entry.id, 'workEntries.id');
      if (!entryIds.add(entry.id)) throw FormatException('Duplicate entry ID: ${entry.id}');
      if (entry.workDurationInSeconds < 0) {
        throw const FormatException('Work duration must not be negative');
      }
      for (final EmbeddedWorkCategory category in entry.categories) {
        if (category.id != null) _id(category.id, 'embedded category.id');
      }
    }
    final Set<int> categoryIds = <int>{};
    for (final WorkCategory category in workCategories) {
      _id(category.id, 'workCategories.id');
      if (!categoryIds.add(category.id)) {
        throw FormatException('Duplicate category ID: ${category.id}');
      }
    }
  }

  static int _integer(Object? value, String field) {
    if (value is! int) throw FormatException('$field must be an integer');
    return value;
  }

  static int _id(Object? value, String field) {
    final int id = _integer(value, field);
    if (id < 0) throw FormatException('$field must be a stored, non-negative ID');
    return id;
  }

  static DateTime _date(Object? value, String field) {
    final DateTime? date = value is String ? DateTime.tryParse(value) : null;
    if (date == null) throw FormatException('$field must contain a valid date');
    return date;
  }

  static WorkData? tryFromJson(dynamic json) {
    try {
      return WorkData.fromJson(json);
    } catch (e) {
      log(
        "Failed to parse WorkData from JSON",
        error: e,
      );
      return null;
    }
  }
}
