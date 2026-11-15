enum HighlightId { jsonBackups, backupRestore, settingsSections }

class ReleaseHighlight {
  final String version;
  final HighlightId id;

  const ReleaseHighlight({required this.version, required this.id});
}

/// Curated announcements, independent of the database schema and UI language.
/// Add highlights with their first released app version. Remove obsolete highlights
/// and their localization keys together; this list is not a complete changelog.
const List<ReleaseHighlight> releaseHighlights = <ReleaseHighlight>[
  ReleaseHighlight(version: '0.4.0', id: HighlightId.jsonBackups),
  ReleaseHighlight(version: '0.4.0', id: HighlightId.backupRestore),
  ReleaseHighlight(version: '0.4.0', id: HighlightId.settingsSections),
];
