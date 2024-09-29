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
}
