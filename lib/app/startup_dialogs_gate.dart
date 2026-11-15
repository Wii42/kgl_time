import 'dart:developer';

import 'package:material_ui/material_ui.dart';

import '../onboarding/onboarding_controller.dart';
import '../onboarding/welcome_dialog.dart';
import '../whats_new/release_highlight.dart';
import '../whats_new/whats_new_controller.dart';
import '../whats_new/whats_new_dialog.dart';

/// Keeps the routed screen mounted beneath either onboarding or release highlights.
class StartupDialogsGate extends StatefulWidget {
  final WhatsNewController whatsNewController;
  final OnboardingController onboardingController;
  final String currentVersion;
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  const StartupDialogsGate({
    super.key,
    required this.whatsNewController,
    required this.onboardingController,
    required this.currentVersion,
    required this.navigatorKey,
    required this.child,
  });

  @override
  State<StartupDialogsGate> createState() => _StartupDialogsGateState();
}

class _StartupDialogsGateState extends State<StartupDialogsGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted) _checkStartupDialogs();
    });
  }

  Future<void> _checkStartupDialogs() async {
    try {
      final bool showWelcome = await widget.onboardingController.isPending();
      final List<ReleaseHighlight> highlights;
      if (showWelcome) {
        // New users start at the installed version, including after an interrupted
        // welcome. Do not queue historical release highlights after onboarding.
        await widget.whatsNewController.acknowledge(widget.currentVersion);
        highlights = const <ReleaseHighlight>[];
      } else {
        highlights = await widget.whatsNewController.pendingHighlights(widget.currentVersion);
      }
      if (!mounted || (!showWelcome && highlights.isEmpty)) return;
      final BuildContext? navigatorContext = widget.navigatorKey.currentContext;
      if (navigatorContext == null || !navigatorContext.mounted) return;
      await showDialog<void>(
        context: navigatorContext,
        builder: (BuildContext context) => showWelcome
            ? const WelcomeDialog()
            : WhatsNewDialog(highlights: highlights, currentVersion: widget.currentVersion),
      );
      if (!mounted) return;
      if (showWelcome) {
        await widget.onboardingController.acknowledge();
      } else {
        await widget.whatsNewController.acknowledge(widget.currentVersion);
      }
    } catch (error, stackTrace) {
      // Announcements must not prevent normal startup if metadata or storage fails.
      log('Failed to show startup dialog', error: error, stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
