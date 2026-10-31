import 'package:go_router/go_router.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:material_navigation/material_navigation.dart';
import 'package:material_ui/material_ui.dart' hide NavigationBar, NavigationDestination;

import 'app_route.dart';

class AppView extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppView({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final List<NavBarAppRoute> navBarItems = NavBarAppRoute.navBarItems;
    AppLocalizations? loc = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxHeight < 500;
        final bool showLabels = !compact || constraints.maxWidth > navBarItems.length * 160;
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: AnimatedSize(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            alignment: Alignment.bottomCenter,
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (newIndex) {
                // go to the initial Location of the branch, if active destination is clicked again.
                bool goToInitialLocation = newIndex == navigationShell.currentIndex;
                navigationShell.goBranch(newIndex, initialLocation: goToInitialLocation);
              },
              destinations: [
                for (NavBarAppRoute item in NavBarAppRoute.navBarItems)
                  navigationDestination(loc, item),
              ],
              height: compact ? 48 : null,
              labelBehavior: showLabels
                  ? NavigationLabelBehavior.all
                  : NavigationLabelBehavior.none,
              layoutDirection: compact ? Axis.horizontal : Axis.vertical,
            ),
          ),
        );
      },
    );
  }

  // ignore: many_lints/avoid_returning_widgets
  NavigationDestination navigationDestination(AppLocalizations? loc, NavBarAppRoute route) {
    return NavigationDestination(icon: Icon(route.icon), label: route.title(loc));
  }
}
