import 'dart:developer';
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import 'export_import_card.dart';
import 'export_service.dart';

typedef ExportFile = ({Uint8List content, String fileName});

class ExportEntriesCard extends StatelessWidget {
  final String Function(AppLocalizations? loc) title;
  final ExportFile Function() createFile;
  final String? mimeType;
  final String Function(AppLocalizations? loc)? explanationLabel;

  const ExportEntriesCard({
    super.key,
    required this.title,
    required this.createFile,
    this.mimeType,
    this.explanationLabel,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? loc = AppLocalizations.of(context);
    final bool canSave = ExportService().isSaveSupportedOnCurrentPlatform();
    final bool canShare = ExportService().isShareSupportedOnCurrentPlatform();
    return ImportExportCard(
      title: title,
      explanationLabel: explanationLabel,
      actions: [
        TextButton.icon(
          label: Text(loc?.saveLocally ?? "<save locally>"),
          icon: Icon(Icons.save_alt_outlined),
          onPressed: canSave ? () => _exportFile(context, share: false) : null,
        ),

        TextButton.icon(
          label: Text(loc?.share ?? "<share>"),
          icon: Icon(Icons.share),
          onPressed: canShare ? () => _exportFile(context, share: true) : null,
        ),
      ],
      warningLabels: [
        if (!canSave) (loc) => loc?.savingNotSupported ?? "<Saving not supported>",
        if (!canShare) (loc) => loc?.sharingNotSupported ?? "<Sharing not supported>",
      ],
    );
  }

  Future<void> _exportFile(BuildContext context, {required bool share}) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations? loc = AppLocalizations.of(context);
    void onError(Object error) {
      if (!messenger.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            share
                ? loc?.failedToShareFile ?? '<Failed to share file.>'
                : loc?.failedToSaveFile ?? '<Failed to save file.>',
          ),
        ),
      );
    }

    try {
      final ExportFile file = createFile();
      const ExportService service = ExportService();
      if (share) {
        await service.shareFile(
          fileContent: file.content,
          fileName: file.fileName,
          mimeType: mimeType,
          onError: onError,
        );
      } else {
        await service.saveFileLocally(
          fileContent: file.content,
          fileName: file.fileName,
          mimeTypesFilter: mimeType != null ? <String>[mimeType!] : null,
          onSuccess: (String path) {
            if (!messenger.mounted) return;
            messenger.showSnackBar(
              SnackBar(
                content: Text(loc?.fileSavedSuccessfully ?? '<File saved successfully.>'),
              ),
            );
          },
          onError: onError,
        );
      }
    } catch (error, stackTrace) {
      log('Failed to prepare export', error: error, stackTrace: stackTrace);
      onError(error);
    }
  }
}
