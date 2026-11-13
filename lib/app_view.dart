import 'package:go_router/go_router.dart';
import 'package:kgl_time/app_layout_constants.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:material_navigation/material_navigation.dart';
import 'package:material_ui/material_ui.dart' hide NavigationBar, NavigationDestination;

import 'app_route.dart';

class AppView extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppView({super.key, required this.navigationShell});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  double _horizontalDragDistance = 0;

  void _onHorizontalDragEnd(DragEndDetails details) {
    final double velocity = details.primaryVelocity ?? 0;
    final double distance = _horizontalDragDistance;
    _horizontalDragDistance = 0;
    if (distance.abs() < 64 && velocity.abs() < 500) return;
    final double direction = velocity.abs() >= 500 ? velocity : distance;
    final int nextIndex = widget.navigationShell.currentIndex + (direction < 0 ? 1 : -1);
    if (nextIndex >= 0 && nextIndex < NavBarAppRoute.navBarItems.length) {
      widget.navigationShell.goBranch(nextIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<NavBarAppRoute> navBarItems = NavBarAppRoute.navBarItems;
    AppLocalizations? loc = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxHeight < AppLayoutConstants.fullNavigationBarMinHeight;
        final bool showLabels = !compact || constraints.maxWidth > navBarItems.length * 160;
        return Scaffold(
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: (DragStartDetails details) => _horizontalDragDistance = 0,
            onHorizontalDragUpdate: (DragUpdateDetails details) {
              _horizontalDragDistance += details.primaryDelta ?? 0;
            },
            onHorizontalDragEnd: _onHorizontalDragEnd,
            onHorizontalDragCancel: () => _horizontalDragDistance = 0,
            child: widget.navigationShell,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: (newIndex) {
              // go to the initial Location of the branch, if active destination is clicked again.
              final bool goToInitialLocation = newIndex == widget.navigationShell.currentIndex;
              widget.navigationShell.goBranch(newIndex, initialLocation: goToInitialLocation);
            },
            destinations: [
              for (NavBarAppRoute item in NavBarAppRoute.navBarItems)
                NavigationDestination(icon: Icon(item.icon), label: item.title(loc)),
            ],
            height: compact ? 48 : null,
            labelBehavior: showLabels ? NavigationLabelBehavior.all : NavigationLabelBehavior.none,
            layoutDirection: compact ? Axis.horizontal : Axis.vertical,
          ),
        );
      },
    );
  }
}
