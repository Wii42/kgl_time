import 'dart:convert';
import 'dart:typed_data';

import 'package:kgl_time/always_filling_scroll_view.dart';
import 'package:kgl_time/data_model/work_entries.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:kgl_time/pages/kgl_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../data_model/work_entry.dart';
import '../export_import/export_entries_card.dart';
import '../export_import/export_service.dart';
import '../kgl_time_app.dart';

class ExportImportPage extends KglPage {
  const ExportImportPage({super.key, required super.appTitle});

  @override
  String? pageTitle(AppLocalizations? loc) => loc?.exportEntries ?? "<Export / Import Data>";

  @override
  bool get showSettingsButton => false;

  @override
  Widget body(BuildContext context) {
    return AlwaysFillingScrollView(
      maxWidth: KglTimeApp.maxPageWidth,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExportEntriesCard(
              title: (loc) => loc?.exportTable ?? "<export as table>",
              fileContent: csvFileContent(context),
              fileName: ExportService().csvFileName(),
              mimeType: 'text/csv; charset=utf-8',
              explanationLabel: (loc) => loc?.exportCsvExplanation,
            ),
          ],
        ),
      ),
    );
  }

  Uint8List csvFileContent(BuildContext context) {
    List<WorkEntry> entries = context.read<WorkEntries>().entries;
    AppLocalizations? loc = AppLocalizations.of(context);
    String csvData = ExportService().entriesToCsv(entries, loc);
    Uint8List fileContent = utf8.encode(csvData);
    return fileContent;
  }
}
