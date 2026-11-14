/// A version 1 backup written independently of the production serializer.
Map<String, dynamic> backupFixture() => <String, dynamic>{
  'backupFormatVersion': 1,
  'exportedAt': '2026-11-14T12:00:00.000Z',
  'workEntries': <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 42,
      'workDurationInSeconds': 5400,
      'date': '2026-10-23T00:00:00.000',
      'description': 'Planning, "Büro"\nGrüsse 👋',
      'categories': <Map<String, dynamic>>[
        <String, dynamic>{'displayName': 'Planning', 'icon': 'work', 'id': 7},
        // A deleted live category and a historical category without an ID are valid snapshots.
        <String, dynamic>{'displayName': 'Deleted category', 'icon': 'phone', 'id': 99},
        <String, dynamic>{'displayName': 'Historical category', 'icon': null, 'id': null},
      ],
      'startTime': '2026-10-23T08:00:00.000Z',
      'endTime': '2026-10-23T09:30:00.000Z',
      'lastEdit': '2026-10-23T10:00:00.000Z',
      'tickedOff': true,
      'createType': 'manualStartAndEndTime',
      'wasEdited': true,
      'wasMovedToTrashAt': null,
    },
    <String, dynamic>{
      'id': 43,
      'workDurationInSeconds': 0,
      'date': '2026-10-24T00:00:00.000Z',
      'description': null,
      'categories': <Map<String, dynamic>>[],
      'startTime': null,
      'endTime': null,
      'lastEdit': null,
      'tickedOff': false,
      'createType': null,
      'wasEdited': false,
      'wasMovedToTrashAt': '2026-11-13T12:00:00.000Z',
    },
  ],
  'workCategories': <Map<String, dynamic>>[
    <String, dynamic>{'displayName': 'Planning', 'icon': 'work', 'id': 7, 'listIndex': 0},
    <String, dynamic>{'displayName': 'Meetings', 'icon': null, 'id': 8, 'listIndex': 1},
  ],
};
