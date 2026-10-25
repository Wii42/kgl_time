import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/data_model/value.dart';
import 'package:kgl_time/data_model/work_category.dart';
import 'package:kgl_time/data_model/work_entry.dart';

void main() {
  late WorkEntry original;

  Map<String, Object?> fields(WorkEntry entry) => {
    'id': entry.id,
    'uuid': entry.uuid,
    'workDurationInSeconds': entry.workDurationInSeconds,
    'date': entry.date,
    'description': entry.description,
    'categories': entry.categories,
    'startTime': entry.startTime,
    'endTime': entry.endTime,
    'lastEdit': entry.lastEdit,
    'tickedOff': entry.tickedOff,
    'createType': entry.createType,
    'wasEdited': entry.wasEdited,
    'wasMovedToTrashAt': entry.wasMovedToTrashAt,
  };

  setUp(() {
    original = WorkEntry(
      uuid: 'entry-uuid',
      workDurationInSeconds: 5400,
      date: DateTime.utc(2026, 10, 23),
      description: 'Planning',
      categories: [EmbeddedWorkCategory(displayName: 'Office', id: 7)],
      startTime: DateTime.utc(2026, 10, 23, 8),
      endTime: DateTime.utc(2026, 10, 23, 9, 30),
      lastEdit: DateTime.utc(2026, 10, 23, 10),
      tickedOff: true,
      createType: CreateWorkEntryType.timeTracker,
      wasEdited: true,
      wasMovedToTrashAt: DateTime.utc(2026, 10, 24),
    )..id = 42;
  });

  group('WorkEntry.copyWith', () {
    test('omitted arguments preserve all fields and identity', () {
      final WorkEntry copy = original.copyWith();
      expect(copy, isNot(same(original)));
      expect(fields(copy), fields(original));
    });

    test('absent wrappers preserve nullable fields', () {
      final WorkEntry copy = original.copyWith(
        description: null,
        startTime: null,
        endTime: null,
        createType: null,
        wasMovedToTrashAt: null,
      );
      expect(fields(copy), fields(original));
    });

    final Map<String, WorkEntry Function(WorkEntry)> clearField = {
      'description': (WorkEntry entry) => entry.copyWith(
        description: const Value<String?>(null),
      ),
      'startTime': (WorkEntry entry) => entry.copyWith(
        startTime: const Value<DateTime?>(null),
      ),
      'endTime': (WorkEntry entry) => entry.copyWith(
        endTime: const Value<DateTime?>(null),
      ),
      'createType': (WorkEntry entry) => entry.copyWith(
        createType: const Value<CreateWorkEntryType?>(null),
      ),
      'wasMovedToTrashAt': (WorkEntry entry) => entry.copyWith(
        wasMovedToTrashAt: const Value<DateTime?>(null),
      ),
    };

    for (final MapEntry<String, WorkEntry Function(WorkEntry)> update
        in clearField.entries) {
      test('wrapped null clears only ${update.key} without mutating original', () {
        final Map<String, Object?> before = fields(original);
        final WorkEntry copy = update.value(original);
        final Map<String, Object?> expected = Map.of(before)..[update.key] = null;
        expect(fields(copy), expected);
        expect(fields(original), before);
      });
    }

    test('wrapped values replace every nullable field', () {
      final Map<String, Object?> before = fields(original);
      final DateTime newStart = DateTime.utc(2026, 10, 25, 10);
      final DateTime newEnd = DateTime.utc(2026, 10, 25, 11);
      final DateTime newTrashDate = DateTime.utc(2026, 10, 26);
      final WorkEntry copy = original.copyWith(
        description: const Value<String?>(''),
        startTime: Value<DateTime?>(newStart),
        endTime: Value<DateTime?>(newEnd),
        createType: const Value<CreateWorkEntryType?>(CreateWorkEntryType.manualDuration),
        wasMovedToTrashAt: Value<DateTime?>(newTrashDate),
      );
      expect(fields(copy), {
        ...before,
        'description': '',
        'startTime': newStart,
        'endTime': newEnd,
        'createType': CreateWorkEntryType.manualDuration,
        'wasMovedToTrashAt': newTrashDate,
      });
      expect(fields(original), before);
    });

    test('non-nullable fields still accept plain values including false and zero', () {
      final DateTime date = DateTime.utc(2026, 10, 25);
      final DateTime edited = DateTime.utc(2026, 10, 25, 12);
      final WorkEntry copy = original.copyWith(
        uuid: 'replacement-uuid',
        workDurationInSeconds: 0,
        date: date,
        categories: [],
        lastEdit: edited,
        tickedOff: false,
        wasEdited: false,
      );
      expect(fields(copy), {
        ...fields(original),
        'uuid': 'replacement-uuid',
        'workDurationInSeconds': 0,
        'date': date,
        'categories': <EmbeddedWorkCategory>[],
        'lastEdit': edited,
        'tickedOff': false,
        'wasEdited': false,
      });
    });
  });

  test('withTrashStatus restores and retrashes while preserving identity', () {
    final WorkEntry restored = original.withTrashStatus(null);
    expect(restored.isInTrash, isFalse);
    expect(fields(restored), {...fields(original), 'wasMovedToTrashAt': null});
    final DateTime trashedAt = DateTime.utc(2026, 10, 26);
    final WorkEntry trashed = restored.withTrashStatus(trashedAt, tickedOff: false);
    expect(trashed.isInTrash, isTrue);
    expect(fields(trashed), {
      ...fields(original),
      'wasMovedToTrashAt': trashedAt,
      'tickedOff': false,
    });
  });
}
