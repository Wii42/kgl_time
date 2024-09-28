import 'package:flutter/material.dart';
import 'package:kgl_time/work_entry.dart';

import 'kgl_page.dart';

void main() async {
  runApp(const MyApp(appTitle: 'KGL Time'));
}

class MyApp extends StatelessWidget {
  final String appTitle;

  const MyApp({super.key, required this.appTitle});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KGL Time',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(appTitle: appTitle),
    );
  }
}

class HomePage extends KglPage {
  const HomePage({super.key, required super.appTitle});

  @override
  Widget body(BuildContext context) {
    return Container();
  }
}
