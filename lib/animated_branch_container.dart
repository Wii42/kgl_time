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
  const AnimatedBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
    this.duration = const Duration(milliseconds: 180),
    this.curve = Curves.easeInOut,
    this.transitionBuilder = _defaultTransition,
  });

  final Duration duration;
  final Curve curve;

  /// Receives visibility from 0 (hidden) to 1 (active), and a directional offset.
  final Widget Function(BuildContext, Animation<double>, Animation<Offset>, Widget)
  transitionBuilder;

  static Widget _defaultTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<Offset> position,
    Widget child,
  ) => FadeTransition(
    opacity: animation,
    child: SlideTransition(position: position, child: child),
  );

  /// The index (in [children]) of the branch Navigator to display.
  final int currentIndex;

  /// The children (branch Navigators) to display in this container.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: children.mapIndexed((int index, Widget navigator) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: index == currentIndex ? 1 : 0,
            end: index == currentIndex ? 1 : 0,
          ),
          duration: duration,
          curve: curve,
          builder: (context, value, child) => TweenAnimationBuilder<Offset>(
            tween: Tween<Offset>(
              begin: index == currentIndex
                  ? Offset.zero
                  : Offset(index < currentIndex ? -0.04 : 0.04, 0),
              end: index == currentIndex
                  ? Offset.zero
                  : Offset(index < currentIndex ? -0.04 : 0.04, 0),
            ),
            duration: duration,
            curve: curve,
            builder: (context, offset, child) => Offstage(
              offstage: value == 0,
              child: transitionBuilder(
                context,
                AlwaysStoppedAnimation<double>(value),
                AlwaysStoppedAnimation<Offset>(offset),
                child!,
              ),
            ),
            child: child,
          ),
          child: _branchNavigatorWrapper(index, navigator),
        );
      }).toList(),
    );
  }

  Widget _branchNavigatorWrapper(int index, Widget navigator) => IgnorePointer(
    ignoring: index != currentIndex,
    child: TickerMode(enabled: index == currentIndex, child: navigator),
  );
}
