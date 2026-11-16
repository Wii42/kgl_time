# Changelog

## Unreleased

### Added

- Display app copyright and GPL-3.0-or-later licensing information in the About dialog.

<a name="v0.4.1"></a>

## v0.4.1

### Added

- Add a short welcome guide on first launch, also available in Settings → Getting started.
- Show release highlights after updates; revisit recent highlights and access the full release notes
  from Settings → What's new.

<a name="v0.4.0"></a>

## v0.4.0

### Added

- Save or share JSON backups of all work entries, including the trash, and categories.
  Settings and running tracker sessions are excluded.
- Restore entries and categories from a JSON backup, with clear replacement warnings and actions,
  validation, a preview, and a temporary Undo option. Preserve existing data on failure and warn
  before discarding changes or cancelling time tracking.

### Changed

- Group settings into sections for appearance, data, and app information, with tappable rows for
  navigation, contact, privacy, and release notes.

### Fixed

- CSV exports use the latest data when saving or sharing.

<a name="v0.3.6"></a>

## v0.3.6

### Added

- Swipe left or right to switch between Home, All Entries, and Categories.

### Changed

- New installations start with Planning, Meetings, and Administration categories, translated into
  the app's language.
- Keep the app bar visible when content fits or there is enough vertical space. On smaller screens,
  it hides while scrolling and reappears when switching tabs or returning to a page.

### Fixed

- Prevent scroll jumps and content being hidden behind the app bar. Keep the scroll position when
  rotating the device or resizing the window.
- Explain unavailable save and share actions, disable their buttons, and remove misleading sharing
  success messages.
- Keep status bar text and icons white for both dark and light mode.

<a name="v0.3.5"></a>

## v0.3.5

### Changed

- More room for content on small devices, in landscape, and in split-screen mode: the top bar hides
  while scrolling and returns when scrolling back up, and the bottom navigation becomes more compact
  when space is limited.
- Smoother transitions between Home, All Entries, and Categories.
- Helpful hints when lists are empty, explaining how to create entries, adjust filters, or restore
  deleted entries from the trash.

<a name="v0.3.4"></a>

## v0.3.4

### Added

- Today's work total on Home, with totals updating at midnight and when returning to the app.
- Daily grouping in All Entries.
- A "What's new" link in Settings to the installed version's release notes.

### Changed

- Clearer grouping controls and improved category selection in light and dark mode.

### Fixed

- Fixed the time tracker indicator appearing squashed after resizing or rotating the screen.
- Aligned work entry card widths across Home, All Entries, and Categories.
- Prevented entries from being hidden behind filters.

<a name="v0.3.3"></a>

## v0.3.3

- Added a filter for work entries without a category
- Fixed week grouping around New Year and week boundaries during daylight-saving changes
- Improved validation and error messages when entering work durations
- Minor bug fixes and improvements

<a name="v0.3.2"></a>

## v0.3.2

- Added CSV export of work entries, with options to save or share the file
- Exported tables include working time, date, description, start/end times, and categories

<a name="v0.3.1"></a>

## v0.3.1

- Added trash bin, allowing users to recover deleted work entries for 30 days
- Added animations on adding/deleting work entries, to give better visual feedback to the user
- Minor bug fixes and improvements

<a name="v0.3.0"></a>

## v0.3.0

- Added a navigation bar
- Minor bug fixes and adjustments

<a name="v0.2.3"></a>

## v0.2.3

- Improved the error message text for excessively large numbers (see v0.2.2)

<a name="v0.2.2"></a>

## v0.2.2

- Fixed an issue where very large numbers entered for work duration on the “New Entry” page appeared
  as negative values

<a name="v0.2.0"></a>

## v0.2.0

- Categories can now be added directly in the time entry slider

<a name="v0.1.1"></a>

## v0.1.1

- Minor UI improvements

<a name="v0.1.0"></a>

## v0.1.0

- Initial release
