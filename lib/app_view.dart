import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'app_route.dart';

class AppView extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppView({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    AppLocalizations? loc = AppLocalizations.of(context);

    return Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (newIndex) {
            // go to the initial Location of the branch, if active destination is clicked again.
            bool goToInitialLocation = newIndex == navigationShell.currentIndex;
            navigationShell.goBranch(newIndex,
                initialLocation: goToInitialLocation);
          },
          destinations: [
            for (NavBarAppRoute item in NavBarAppRoute.navBarItems)
              item.navigationDestination(loc)
          ],
        ));
  }
}
