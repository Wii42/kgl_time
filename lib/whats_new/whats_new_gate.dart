import 'dart:developer';

import 'package:material_ui/material_ui.dart';

import 'release_highlight.dart';
import 'whats_new_controller.dart';
import 'whats_new_dialog.dart';

/// Keeps the routed screen mounted underneath a single startup announcement.
class WhatsNewGate extends StatefulWidget {
  final WhatsNewController controller;
  final String currentVersion;
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  const WhatsNewGate({
    super.key,
    required this.controller,
    required this.currentVersion,
    required this.navigatorKey,
    required this.child,
  });

  @override
  State<WhatsNewGate> createState() => _WhatsNewGateState();
}

class _WhatsNewGateState extends State<WhatsNewGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted) _checkForHighlights();
    });
  }

  Future<void> _checkForHighlights() async {
    try {
      final List<ReleaseHighlight> highlights = await widget.controller.pendingHighlights(
        widget.currentVersion,
      );
      if (!mounted || highlights.isEmpty) return;
      final BuildContext? navigatorContext = widget.navigatorKey.currentContext;
      if (navigatorContext == null || !navigatorContext.mounted) return;
      await showDialog<void>(
        context: navigatorContext,
        builder: (BuildContext context) => WhatsNewDialog(
          highlights: highlights,
          currentVersion: widget.currentVersion,
        ),
      );
      if (mounted) await widget.controller.acknowledge(widget.currentVersion);
    } catch (error, stackTrace) {
      // Announcements must not prevent normal startup if metadata or storage fails.
      log('Failed to show release highlights', error: error, stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
