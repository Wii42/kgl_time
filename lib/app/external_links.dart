class ExternalLinks {
  static final Uri releaseNotes = Uri.parse(
    'https://github.com/Wii42/kgl_time/blob/main/CHANGELOG.md',
  );

  static Uri releaseNotesForVersion(String version) => releaseNotes.replace(fragment: 'v$version');

  static final Uri emailContact = Uri.parse('mailto:wi42.dev@gmail.com');

  static final Uri privacy = Uri.parse('https://github.com/Wii42/kgl_time/blob/main/PRIVACY.md');

  static Uri privacyForLanguage(String? language) => privacy.replace(fragment: language);

  static final Uri githubRepo = Uri.parse('https://github.com/Wii42/kgl_time');

  static final Uri license = Uri.parse('https://github.com/Wii42/kgl_time/blob/main/LICENSE');
}
