# Release notes

- When implementing a user-visible feature or fixing a user-visible bug, update the **Unreleased**
  section of the changelog in `README.md` in the same change.
- Describe the resulting behavior in concise, user-facing language. Use Added, Changed, Fixed, or
  Removed headings as appropriate; omit empty headings.
- Include changes users can notice or need to know about: features, UI changes, bug fixes,
  meaningful performance or reliability improvements, compatibility requirements, and changes to
  stored data, exports, or privacy.
- Omit behavior-preserving refactorings, lint and formatting changes, added tests, and routine
  dependency updates. When a dependency update affects users, describe its observable effect rather
  than the package or version change.
- Consolidate related work into an existing bullet instead of recording every implementation step.
  Do not add a developer-only Maintenance section.
- If developer setup or build requirements change, update the relevant README instructions directly
  rather than adding them to the release notes.
- Document only implemented changes. Do not describe proposed or unresolved fixes as completed, and
  do not rewrite notes for released versions.
- When preparing a release, move the Unreleased notes under the actual version and create a fresh
  Unreleased section. Do not choose or increment a release version unless the task calls for it.
