# Project decisions

This record explains important choices in the current implementation. Keep proposed changes in
GitHub issues and update this file when a decision changes. Working conventions are in
[AGENTS.md](../AGENTS.md).

## Local storage and portable backups

Application data is accessed through
the [persistent storage interface](../lib/persistent_storage/persistent_storage_interface.dart),
currently implemented with Isar. The storage boundary allows a future database change without
coupling the UI to a particular database.

JSON backups have their own format version, independent of the app version and database schema.
Preserve the ability to read published backup formats when evolving storage, including for users
who skip releases. Backups contain entries, including the trash, and categories; settings and
running tracker sessions are excluded. They are user-initiated files, with no built-in cloud sync.
See [PRIVACY.md](../PRIVACY.md) for the public description of data handling and system backups.

Entry categories are embedded snapshots and may outlive categories in the editable category list.
Live categories and embedded snapshots are distinct equality types; assignment matching compares
their local IDs explicitly.
Their numeric IDs belong to the local dataset and backup snapshot; they are not global identifiers
for cross-device merging. A future relational schema or synchronization feature needs an explicit
identity and relationship design rather than treating backup import as a merge operation.

Sources: [backup model](../lib/export_import/work_data.dart),
[category model](../lib/data_model/work_category.dart).

## Atomic replacement and temporary undo

Backup import replaces entries and categories together through `replaceWorkData`. Publish the new
in-memory data only after the storage transaction commits, so a failed replacement preserves the
previous dataset. Successful import cancels a running tracker without creating an entry.

Undo uses an independent in-memory snapshot and is offered temporarily. If data changed afterward
or another tracker started, ask before discarding those changes or cancelling tracking. Undo also
uses atomic replacement and does not restart previously cancelled tracker sessions. Preserve entry
IDs and stored fields when copying records or changing trash status; entry edits advance `lastEdit`.

Export files are generated when Save or Share is pressed, keeping exports current even when the
export page has remained open while data changed.

Sources: [import service](../lib/export_import/import_service.dart),
[export card](../lib/export_import/export_entries_card.dart),
[entry model](../lib/data_model/work_entry.dart).

## Startup dialogs and onboarding completion

One [startup gate](../lib/app/startup_dialogs_gate.dart) runs after the initial frame and presents
either onboarding or release highlights over the existing screen. It checks once per startup to
avoid duplicate dialogs during rebuilds.

Initialization deliberately persists `isFirstRun = false` while retaining the first-run value in
the startup snapshot. Onboarding therefore needs a separate completion flag: save it as pending
before clearing `isFirstRun`. This lets an interrupted first launch retry onboarding. Existing
installations without the completion flag are not automatically enrolled.

A button, outside tap, or Back dismissal acknowledges a dialog. Closing the app while it remains
open leaves acknowledgement pending. Fresh installations establish the current What's New baseline
while onboarding is pending, preventing historical announcements on subsequent launches.

Sources: [initialization](../lib/app/app_initialization.dart),
[onboarding controller](../lib/onboarding/onboarding_controller.dart).

## Curated release highlights

Startup combines unseen highlights from missed releases into one dialog, selecting at most five
with the newest versions first. Use semantic version comparisons, ignore build metadata, and retain
the highest acknowledged version across downgrades. A missing acknowledgement is not enough to
identify a fresh install: existing users without tracking still receive relevant highlights.

Settings shows the most recent highlights up to the installed version, including acknowledged ones,
without changing startup acknowledgement. Opening the full release notes keeps the dialog open.
Language-independent highlight IDs are mapped to ARB translations at display time. Curation rules
in [AGENTS.md](../AGENTS.md#whats-new-highlights) keep announcements focused on feature discovery.

Source: [What's New controller](../lib/whats_new/whats_new_controller.dart).

## Stable release-note links

[CHANGELOG.md](../CHANGELOG.md) holds the release history. The app links to explicit version anchors
such as `#v0.4.1`, stripping build metadata. These anchors keep links independent of GitHub's
generated
heading identifiers.

Older app versions contain URLs pointing to README version headings. Keep the compatibility stubs
there so moving the release history does not break those installed versions. The in-app link was
introduced in version 0.3.4; earlier versions do not need stubs for app compatibility.

Source: [release-note URL helper](../lib/utils/helpers.dart).
