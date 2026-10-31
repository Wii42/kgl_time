import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';

/// Custom branch Navigator container that provides animated transitions
/// when switching branches.
///
/// Adapted from [go_router](https://github.com/flutter/packages/tree/main/packages/go_router) <br>
/// Original file:
/// [packages/go_router/example/lib/others/custom_stateful_shell_route.dart at commit ed5bd29](https://github.com/flutter/packages/blob/4cb0506dddae4f9861145c48f4b27b17907fe251/packages/go_router/example/lib/others/custom_stateful_shell_route.dart#L314)
class AnimatedBranchContainer extends StatelessWidget {
  /// Creates a AnimatedBranchContainer
  const AnimatedBranchContainer({super.key, required this.currentIndex, required this.children});

  /// The index (in [children]) of the branch Navigator to display.
  final int currentIndex;

  /// The children (branch Navigators) to display in this container.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: children.mapIndexed((int index, Widget navigator) {
        return AnimatedScale(
          scale: index == currentIndex ? 1 : 1.5,
          duration: const Duration(milliseconds: 400),
          child: AnimatedOpacity(
            opacity: index == currentIndex ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            child: _branchNavigatorWrapper(index, navigator),
          ),
        );
      }).toList(),
    );
  }

  Widget _branchNavigatorWrapper(int index, Widget navigator) => IgnorePointer(
    ignoring: index != currentIndex,
    child: TickerMode(enabled: index == currentIndex, child: navigator),
  );
}
