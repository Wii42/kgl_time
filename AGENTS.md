# Coding style

- Explicitly specify the type of every variable declaration, including local variables, fields,
  constants, and loop variables, even when the type can be inferred. Use `final Type name` or
  `const Type name` where appropriate instead of untyped `final`, `const` declarations. Never use
  `var` declarations.

- Set `scrollable: true` when creating an `AlertDialog`, unless explicitly instructed otherwise.

# Reuse existing code

- Check for existing widgets and functions in the project, Flutter, and current dependencies before
  implementing new ones. Reuse or compose them when appropriate instead of duplicating behavior
  from scratch.

# Release notes

- When implementing a user-visible feature or fixing a user-visible bug, update the **Unreleased**
  section of `CHANGELOG.md` in the same change.
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
- When preparing a release, move the Unreleased notes in `CHANGELOG.md` under the actual version and
  create a fresh Unreleased section. Do not choose or increment a release version unless the task
  calls for it.
- Give every released version heading in `CHANGELOG.md` an explicit anchor matching its version,
  e.g. `<a name="v0.4.1"></a>`, as the app links directly to these anchors.
- Preserve the compatibility version headings and links in `README.md` for older app versions.

# What's New highlights

- Before a release, review the curated highlights in `lib/whats_new/release_highlight.dart` and
  their
  ARB translations, updating them when necessary.
- Focus on new features users might otherwise miss or not realize are new. For features that are
  less discoverable, briefly say where to find them.
- Keep highlights concise. Avoid repeating usage instructions, warnings, or explanations already
  provided by the feature itself. Combine closely related capabilities into one highlight.
- Omit routine visual changes, such as settings layout updates, unless they help users discover a
  meaningful new capability.
- Keep all supported locales consistent. Remove obsolete highlights and their unused translation
  keys together; the popup should remain a curated selection rather than a complete changelog.
