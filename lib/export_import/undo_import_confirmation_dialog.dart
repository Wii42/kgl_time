import 'dart:developer';

import 'package:flutter/foundation.dart' show AsyncCallback;
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../data_model/key_values.dart';
import '../l10n/generated/app_localizations.dart';

class UndoImportConfirmationDialog extends StatefulWidget {
  const UndoImportConfirmationDialog({super.key, required this.onUndo, this.hasChanges = true});

  final AsyncCallback onUndo;
  final bool hasChanges;

  @override
  State<UndoImportConfirmationDialog> createState() => _UndoImportConfirmationDialogState();
}

class _UndoImportConfirmationDialogState extends State<UndoImportConfirmationDialog> {
  bool _isUndoing = false;

  Future<void> _undo() async {
    if (_isUndoing) return;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations? loc = AppLocalizations.of(context);
    setState(() => _isUndoing = true);
    try {
      await widget.onUndo();
      if (mounted) Navigator.of(context).pop(true);
    } catch (error, stackTrace) {
      log('Failed to undo backup import', error: error, stackTrace: stackTrace);
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(loc?.undoImportFailed ?? '<Undo failed.>')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUndoing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? loc = AppLocalizations.of(context);
    final bool isTracking = context.select<KeyValues, bool>(
      (KeyValues settings) => settings.get<DateTime>(KeyValues.timeTrackerStartKey) != null,
    );
    return PopScope(
      canPop: !_isUndoing,
      child: AlertDialog(
        title: Text(loc?.undoImportTitle ?? '<Undo backup import?>'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (widget.hasChanges)
              Text(loc?.undoImportChangesWarning ?? '<Changes since the import will be lost.>'),
            if (widget.hasChanges && isTracking) const SizedBox(height: 12),
            if (isTracking)
              Text(
                loc?.undoImportCancelsTrackerWarning ?? '<Undo will cancel the running tracker.>',
              ),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: _isUndoing ? null : () => Navigator.of(context).pop(),
            child: Text(loc?.cancel ?? '<Cancel>'),
          ),
          TextButton(
            onPressed: _isUndoing ? null : _undo,
            child: Text(loc?.undo ?? '<Undo>'),
          ),
        ],
      ),
    );
  }
}
