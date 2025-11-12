import 'dart:developer';

import '../data_model/work_category.dart';
import '../data_model/work_entry.dart';

class WorkData {
  final List<WorkEntry> workEntries;
  final List<WorkCategory> workCategories;
  final int schemaVersion;
  final DateTime exportedAt;

  const WorkData({
    required this.workEntries,
    required this.workCategories,
    required this.schemaVersion,
    required this.exportedAt,
  });

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'exportedAt': exportedAt.toIso8601String(),
    'workEntries': workEntries.map((e) => e.toJson()).toList(),
    'workCategories': workCategories.map((c) => c.toJson()).toList(),
  };

  factory WorkData.fromJson(Map<String, dynamic> json) {
    return WorkData(
      schemaVersion: json['schemaVersion'],
      exportedAt: DateTime.parse(json['exportedAt']),
      workEntries: (json['workEntries'] as List<dynamic>)
          .map((e) => WorkEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      workCategories: (json['workCategories'] as List<dynamic>)
          .map((c) => WorkCategory.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
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