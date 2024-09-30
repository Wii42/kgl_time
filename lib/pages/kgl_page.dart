import 'package:flutter/material.dart';

abstract class KglPage extends StatelessWidget {
  final String appTitle;

  Widget body(BuildContext context);
  String? get pageTitle => null;
  const KglPage({super.key, required this.appTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appbarTitle(context),
      ),
      body: body(context),
    );
  }

  Widget appbarTitle(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    String largeTitle = pageTitle ?? appTitle;
    String? smallTitle = pageTitle != null ? appTitle : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (smallTitle != null)
          Text(smallTitle,
              style: textTheme.bodySmall?.copyWith(color: theme.appBarTheme.foregroundColor)),
        Text(largeTitle),
      ],
    );
  }

  /// Widget which assures the child uses all available space when smaller than
  /// the available space, else scrolls vertically. Must not contain [Spacer]
  /// widgets in Columns.
  /// Either [child] or [builder] must be set.
  ///
  /// Note the provided [constraints] in [builder] are measured before the
  /// ScrollView is applied, e.g. the visible available space, not the space
  /// inside the ScrollView.
  Widget alwaysFillingScrollView(
      {Widget? child, Widget Function(BuildContext, BoxConstraints)? builder}) {
    assert(child != null || builder != null);
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
          ),
          child: child ?? builder?.call(context, constraints),
        ),
      );
    });
  }
}
