import 'package:flutter/material.dart';
import 'package:kgl_time/kgl_page.dart';
import 'package:kgl_time/work_entry.dart';

class NewEntryPage extends KglPage {


  /// The existing entry to edit, or null if a new entry should be created.
  final WorkEntry? existingEntry;
  const NewEntryPage({super.key, required super.appTitle, this.existingEntry});

  @override
  Widget body(BuildContext context) {
    return Text('New Entry Page');
  }

  @override
  String get pageTitle => existingEntry == null ? 'Neuer Eintrag' : 'Eintrag bearbeiten';
}
