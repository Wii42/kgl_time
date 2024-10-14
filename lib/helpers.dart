import 'package:flutter/material.dart';

ThemeMode? parseThemeMode(String? themeMode) {
  switch (themeMode) {
    case 'dark':
      return ThemeMode.dark;
    case 'light':
      return ThemeMode.light;
    case 'system':
      return ThemeMode.system;
    default:
      return null;
  }
}

extension SpacedList on List<Widget> {
  List<Widget> withSpaceBetween({double? height, double? width}) {
    List<Widget> result = [];
    for (int i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) {
        result.add(SizedBox(height: height, width: width));
      }
    }
    return result;
  }
}
