import 'package:pub_semver/pub_semver.dart';

import '../persistent_storage/persistent_storage_interface.dart';
import 'release_highlight.dart';

class WhatsNewController {
  static const String lastSeenVersionKey = 'lastSeenWhatsNewVersion';
  static const int maxHighlights = 5;

  final KeyValueStorage storage;
  final bool isFirstRun;
  final List<ReleaseHighlight> highlights;

  const WhatsNewController({
    required this.storage,
    required this.isFirstRun,
    this.highlights = releaseHighlights,
  });

  Future<List<ReleaseHighlight>> pendingHighlights(String currentVersion) async {
    final Version current = _version(currentVersion);
    final String? stored = await storage.get<String>(lastSeenVersionKey);
    if (stored == null && isFirstRun) {
      // Only fresh installations skip historical announcements. Existing users
      // without an acknowledgement should see the currently curated highlights.
      await acknowledge(currentVersion);
      return <ReleaseHighlight>[];
    }

    final Version? lastSeen = stored == null ? null : _version(stored);
    // Keep the highest acknowledged version across downgrades and reinstalls
    // over an existing installation, so returning to it cannot replay highlights.
    if (lastSeen != null && current <= lastSeen) return <ReleaseHighlight>[];

    final List<ReleaseHighlight> pending = highlights.where((ReleaseHighlight highlight) {
      final Version version = _version(highlight.version);
      return (lastSeen == null || lastSeen < version) && version <= current;
    }).toList();
    pending.sort(
      (ReleaseHighlight a, ReleaseHighlight b) =>
          _version(b.version).compareTo(_version(a.version)),
    );
    if (pending.isEmpty) await acknowledge(currentVersion);
    return pending.take(maxHighlights).toList();
  }

  /// Call only after dismissal, or when establishing/advancing an empty baseline.
  Future<void> acknowledge(String currentVersion) async {
    final Version current = _version(currentVersion);
    final String? stored = await storage.get<String>(lastSeenVersionKey);
    if (stored == null || _version(stored) < current) {
      await storage.set<String>(lastSeenVersionKey, current.toString());
    }
  }

  // Build numbers do not announce new features. Keep prerelease identifiers so
  // a stable release still sorts after its prereleases.
  static Version _version(String version) => Version.parse(version.split('+').first);
}
