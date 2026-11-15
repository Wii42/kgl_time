import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/export_import/export_service.dart';
import 'package:kgl_time/export_import/work_data.dart';

import '../support/backup_fixture.dart';

void main() {
  test('version 1 JSON round trip preserves all fields and historical categories', () {
    final Map<String, dynamic> json = backupFixture();
    final WorkData data = WorkData.fromJson(json);

    expect(jsonDecode(jsonEncode(data.toJson())), json);
    expect(data.workEntries.last.lastEdit, isNull);
    expect(data.workEntries.last.isInTrash, isTrue);
    expect(data.workEntries.first.categories[1].id, 99);
    expect(data.workEntries.first.categories.last.id, isNull);
  });

  test(
    'JSON export matches the version 1 snapshot contract including trash and category order',
    () {
      final Map<String, dynamic> json = backupFixture();
      final WorkData data = WorkData.fromJson(json);
      final String exported = withClock(
        Clock.fixed(data.exportedAt),
        () => const ExportService().dataToJson(data.workEntries, data.workCategories),
      );

      expect(jsonDecode(exported), json);
    },
  );

  for (final int version in <int>[-1, 0, 2]) {
    test('rejects unsupported backup format version $version', () {
      final Map<String, dynamic> json = backupFixture()..['backupFormatVersion'] = version;
      expect(
        () => WorkData.fromJson(json),
        throwsA(isA<UnsupportedBackupFormatException>()),
      );
      expect(WorkData.tryFromJson(json), isNull);
    });
  }

  for (final String collection in <String>['workEntries', 'workCategories']) {
    for (final Object? invalidId in <Object?>[null, 1.5, -1, '7']) {
      test('rejects invalid ID $invalidId in $collection without truncating it', () {
        final Map<String, dynamic> json = backupFixture();
        final List<Map<String, dynamic>> records = json[collection] as List<Map<String, dynamic>>;
        records.first['id'] = invalidId;
        expect(WorkData.tryFromJson(json), isNull);
      });
    }
    test('rejects duplicate IDs in $collection', () {
      final Map<String, dynamic> json = backupFixture();
      final List<Map<String, dynamic>> records = json[collection] as List<Map<String, dynamic>>;
      records[1]['id'] = records.first['id'];
      expect(WorkData.tryFromJson(json), isNull);
    });
  }

  for (final Object? duration in <Object?>[null, 1.5, -1]) {
    test('rejects invalid work duration $duration', () {
      final Map<String, dynamic> json = backupFixture();
      (json['workEntries'] as List<Map<String, dynamic>>).first['workDurationInSeconds'] = duration;
      expect(WorkData.tryFromJson(json), isNull);
    });
  }

  for (final Object? date in <Object?>['not a date', 0]) {
    test('rejects invalid entry date $date', () {
      final Map<String, dynamic> json = backupFixture();
      (json['workEntries'] as List<Map<String, dynamic>>).first['date'] = date;
      expect(WorkData.tryFromJson(json), isNull);
    });
  }

  test('an explicitly stored epoch date remains valid', () {
    final Map<String, dynamic> json = backupFixture();
    (json['workEntries'] as List<Map<String, dynamic>>).first['date'] = '1970-01-01T00:00:00.000Z';
    expect(WorkData.fromJson(json).workEntries.first.date, DateTime.utc(1970));
  });

  test('entry and category IDs have separate namespaces', () {
    final Map<String, dynamic> json = backupFixture();
    (json['workEntries'] as List<Map<String, dynamic>>).first['id'] = 7;
    expect(WorkData.tryFromJson(json), isNotNull);
  });

  for (final bool missing in <bool>[true, false]) {
    test('rejects a ${missing ? 'missing' : 'null'} entry date instead of inventing one', () {
      final Map<String, dynamic> json = backupFixture();
      final List<Map<String, dynamic>> records = json['workEntries'] as List<Map<String, dynamic>>;
      if (missing) {
        records.first.remove('date');
      } else {
        records.first['date'] = null;
      }
      expect(WorkData.tryFromJson(json), isNull);
    });
  }

  for (final Object? invalid in <Object?>[null, <Object?>[], <String, dynamic>{}]) {
    test('rejects malformed document $invalid', () {
      expect(WorkData.tryFromJson(invalid), isNull);
    });
  }
}
