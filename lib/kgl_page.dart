import 'package:flutter/material.dart';

abstract class KglPage extends StatelessWidget {
  final String appTitle;

  Widget body(BuildContext context);
  String? get pageTitle => null;
  const KglPage({super.key, required this.appTitle});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: appbarTitle(context),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: body(context),
    );
  }

  Widget appbarTitle(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    String largeTitle = pageTitle ?? appTitle;
    String? smallTitle = pageTitle != null ? appTitle : null;
    return Column(
      children: [
        if (smallTitle != null)
          Text(smallTitle,
              style: textTheme.bodySmall?.apply(color: Colors.white)),
        Text(largeTitle),
      ],
    );
  }
}
