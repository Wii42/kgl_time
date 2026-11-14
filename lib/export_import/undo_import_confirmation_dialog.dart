import 'dart:developer';

import 'package:flutter/foundation.dart' show AsyncCallback;
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';

class UndoImportConfirmationDialog extends StatefulWidget {
  const UndoImportConfirmationDialog({super.key, required this.onUndo});

  final AsyncCallback onUndo;

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
      if (mounted) Navigator.of(context).pop();
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
    return PopScope(
      canPop: !_isUndoing,
      child: AlertDialog(
        title: Text(loc?.undoImportTitle ?? '<Undo backup import?>'),
        content: Text(loc?.undoImportChangesWarning ?? '<Changes since the import will be lost.>'),
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
