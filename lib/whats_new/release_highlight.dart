enum HighlightId { jsonBackups }

class ReleaseHighlight {
  final String version;
  final HighlightId id;

  const ReleaseHighlight({required this.version, required this.id});
}

/// Curated announcements, independent of the database schema and UI language.
/// Add highlights with their first released app version. Remove obsolete highlights
/// and their localization keys together; this list is not a complete changelog.
/// Focus on features users may miss and where to find them, rather than usage
/// instructions or routine visual changes.
const List<ReleaseHighlight> releaseHighlights = <ReleaseHighlight>[
  ReleaseHighlight(version: '0.4.0', id: HighlightId.jsonBackups),
];
