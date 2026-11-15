import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/whats_new/release_highlight.dart';
import 'package:kgl_time/whats_new/whats_new_controller.dart';

import '../support/memory_storage.dart';

void main() {
  late MemoryKeyValues storage;
  late WhatsNewController controller;

  setUp(() {
    storage = MemoryKeyValues();
    controller = WhatsNewController(storage: storage);
  });

  Future<void> setLastSeen(String version) => storage.set<String>(
    WhatsNewController.lastSeenVersionKey,
    version,
  );

  Future<String?> lastSeen() => storage.get<String>(WhatsNewController.lastSeenVersionKey);

  test('fresh installation establishes a baseline without historical highlights', () async {
    expect(await controller.pendingHighlights('0.4.0'), isEmpty);
    expect(await lastSeen(), '0.4.0');
  });

  test('same version has no highlights', () async {
    await setLastSeen('0.4.0');
    expect(await controller.pendingHighlights('0.4.0'), isEmpty);
    expect(await lastSeen(), '0.4.0');
  });

  test('an update returns its highlights without acknowledging them', () async {
    await setLastSeen('0.3.6');
    final List<ReleaseHighlight> pending = await controller.pendingHighlights('0.4.0');
    expect(pending.map((ReleaseHighlight highlight) => highlight.id), <HighlightId>[
      HighlightId.jsonBackups,
      HighlightId.backupRestore,
      HighlightId.settingsSections,
    ]);
    expect(await lastSeen(), '0.3.6');
  });

  test('skipped releases aggregate newest first and exclude seen and future highlights', () async {
    controller = WhatsNewController(
      storage: storage,
      highlights: const <ReleaseHighlight>[
        ReleaseHighlight(version: '0.5.0', id: HighlightId.settingsSections),
        ReleaseHighlight(version: '0.3.0', id: HighlightId.jsonBackups),
        ReleaseHighlight(version: '0.6.0', id: HighlightId.jsonBackups),
        ReleaseHighlight(version: '0.4.0', id: HighlightId.backupRestore),
      ],
    );
    await setLastSeen('0.3.0');
    final List<ReleaseHighlight> pending = await controller.pendingHighlights('0.5.0');
    expect(pending.map((ReleaseHighlight highlight) => highlight.version), <String>[
      '0.5.0',
      '0.4.0',
    ]);
    expect(await lastSeen(), '0.3.0');
  });

  test('an update without highlights advances the baseline', () async {
    await setLastSeen('0.4.0');
    expect(await controller.pendingHighlights('0.4.1'), isEmpty);
    expect(await lastSeen(), '0.4.1');
  });

  test('only the five most recent highlights are selected', () async {
    controller = WhatsNewController(
      storage: storage,
      highlights: <ReleaseHighlight>[
        for (final int minor in <int>[1, 5, 3, 6, 2, 4])
          ReleaseHighlight(version: '1.$minor.0', id: HighlightId.jsonBackups),
      ],
    );
    await setLastSeen('1.0.0');
    final List<ReleaseHighlight> pending = await controller.pendingHighlights('1.6.0');
    expect(pending.map((ReleaseHighlight highlight) => highlight.version), <String>[
      '1.6.0',
      '1.5.0',
      '1.4.0',
      '1.3.0',
      '1.2.0',
    ]);
  });

  test('semantic ordering puts 2.10.0 after 2.9.0', () async {
    controller = WhatsNewController(
      storage: storage,
      highlights: const <ReleaseHighlight>[
        ReleaseHighlight(version: '2.9.0', id: HighlightId.jsonBackups),
        ReleaseHighlight(version: '2.10.0', id: HighlightId.backupRestore),
      ],
    );
    await setLastSeen('2.8.0');
    final List<ReleaseHighlight> pending = await controller.pendingHighlights('2.10.0');
    expect(pending.map((ReleaseHighlight highlight) => highlight.version), <String>[
      '2.10.0',
      '2.9.0',
    ]);
    await setLastSeen('2.9.0');
    expect((await controller.pendingHighlights('2.10.0')).single.id, HighlightId.backupRestore);
  });

  test(
    'downgrade preserves the high water mark and does not replay after upgrading again',
    () async {
      await setLastSeen('0.4.0');
      expect(await controller.pendingHighlights('0.3.6'), isEmpty);
      expect(await lastSeen(), '0.4.0');
      expect(await controller.pendingHighlights('0.4.0'), isEmpty);
    },
  );

  test('acknowledgement persists the current version and prevents repeats', () async {
    await setLastSeen('0.3.6');
    expect(await controller.pendingHighlights('0.4.0'), isNotEmpty);
    await controller.acknowledge('0.4.0');
    expect(await lastSeen(), '0.4.0');
    expect(await controller.pendingHighlights('0.4.0'), isEmpty);
  });

  test('acknowledgement cannot lower the high water mark', () async {
    await setLastSeen('0.5.0');
    await controller.acknowledge('0.4.0');
    expect(await lastSeen(), '0.5.0');
  });

  test('without acknowledgement the next launch still has highlights', () async {
    await setLastSeen('0.3.6');
    expect(await controller.pendingHighlights('0.4.0'), isNotEmpty);
    final WhatsNewController nextLaunch = WhatsNewController(storage: storage);
    expect(await nextLaunch.pendingHighlights('0.4.0'), isNotEmpty);
    expect(await lastSeen(), '0.3.6');
  });

  test('build metadata is ignored for the app and highlight versions', () async {
    controller = WhatsNewController(
      storage: storage,
      highlights: const <ReleaseHighlight>[
        ReleaseHighlight(version: '0.4.0+18', id: HighlightId.jsonBackups),
      ],
    );
    await setLastSeen('0.3.6+17');
    expect(await controller.pendingHighlights('0.4.0+19'), hasLength(1));
    await controller.acknowledge('0.4.0+19');
    expect(await lastSeen(), '0.4.0');
    expect(await controller.pendingHighlights('0.4.0+20'), isEmpty);
  });

  test('stable highlights are withheld until after a prerelease', () async {
    await setLastSeen('0.3.6');
    expect(await controller.pendingHighlights('0.4.0-beta.1'), isEmpty);
    expect(await lastSeen(), '0.4.0-beta.1');
    expect(await controller.pendingHighlights('0.4.0'), hasLength(3));
  });

  test('obsolete removed highlights do not produce a popup after a long absence', () async {
    controller = WhatsNewController(storage: storage, highlights: const <ReleaseHighlight>[]);
    await setLastSeen('0.1.0');
    expect(await controller.pendingHighlights('0.4.0'), isEmpty);
    expect(await lastSeen(), '0.4.0');
  });
}
