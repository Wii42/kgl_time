import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import 'export_import_card.dart';
import 'export_service.dart';

class ExportEntriesCard extends StatelessWidget {
  final Function(AppLocalizations? loc) title;
  final Uint8List fileContent;
  final String fileName;
  final String? mimeType;
  final Function(AppLocalizations? loc)? explanationLabel;

  const ExportEntriesCard({
    super.key,
    required this.title,
    required this.fileContent,
    required this.fileName,
    this.mimeType,
    this.explanationLabel,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations? loc = AppLocalizations.of(context);
    return ImportExportCard(
      title: title,
      explanationLabel: explanationLabel,
      actions: [
        TextButton.icon(
          label: Text(loc?.saveLocally ?? "<save locally>"),
          icon: Icon(Icons.save_alt_outlined),
          onPressed: (Platform.isAndroid | Platform.isIOS)
              ? onSave(
                  fileContent: fileContent,
                  fileName: fileName,
                  context: context,
                  mimeTypesFilter: mimeType != null ? [mimeType!] : null,
                )
              : null,
        ),

        TextButton.icon(
          label: Text(loc?.share ?? "<share>"),
          icon: Icon(Icons.share),
          onPressed: !Platform.isLinux
              ? onShare(
                  fileContent: fileContent,
                  fileName: fileName,
                  context: context,
                  mimeType: mimeType,
                )
              : null,
        ),
      ],
    );
  }

  VoidCallback onSave({
    required Uint8List fileContent,
    required String fileName,
    required BuildContext context,
    List<String>? mimeTypesFilter,
  }) => () async {
    ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    AppLocalizations? loc = AppLocalizations.of(context);
    return ExportService().saveFileLocally(
      fileContent: fileContent,
      fileName: fileName,
      mimeTypesFilter: mimeTypesFilter,
      onSuccess: (path) => messenger.showSnackBar(
        SnackBar(
          content: Text(
            loc?.fileSavedSuccessfully ?? "<File saved successfully.>",
          ),
        ),
      ),
      onError: (error) => messenger.showSnackBar(
        SnackBar(
          content: Text(loc?.failedToSaveFile ?? "<Failed to save file.>"),
        ),
      ),
    );
  };

  VoidCallback onShare({
    required Uint8List fileContent,
    required String fileName,
    required BuildContext context,
    String? mimeType,
  }) => () async {
    AppLocalizations? loc = AppLocalizations.of(context);
    ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    return ExportService().shareFile(
      fileContent: fileContent,
      fileName: fileName,
      mimeType: mimeType,
      onSuccess: (result) => messenger.showSnackBar(
        SnackBar(
          content: Text(
            loc?.fileSharedSuccessfully ?? "<File shared successfully.>",
          ),
        ),
      ),
      onError: (error) => messenger.showSnackBar(
        SnackBar(
          content: Text(loc?.failedToShareFile ?? "<Failed to share file.>"),
        ),
      ),
    );
  };
}
