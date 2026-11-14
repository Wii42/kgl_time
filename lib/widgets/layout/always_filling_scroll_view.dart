import 'package:material_ui/material_ui.dart';

class AlwaysFillingScrollView extends StatelessWidget {
  final Widget? child;
  final Widget Function(BuildContext, BoxConstraints)? builder;
  final double maxWidth;

  const new({
    super.key,
    this.child,
    this.builder,
    this.maxWidth = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    assert(child != null || builder != null);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                maxWidth: maxWidth,
              ),
              child: child ?? builder?.call(context, constraints),
            ),
          ),
        );
      },
    );
  }
}
