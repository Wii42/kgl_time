import 'package:flutter/material.dart';

class OriginalTextTheme extends ThemeExtension<OriginalTextTheme> {
  final TextTheme textTheme;

  OriginalTextTheme({required this.textTheme});

  @override
  ThemeExtension<OriginalTextTheme> copyWith({TextTheme? textTheme}) {
    return OriginalTextTheme(textTheme: textTheme ?? this.textTheme);
  }

  @override
  ThemeExtension<OriginalTextTheme> lerp(
      covariant ThemeExtension<OriginalTextTheme>? other, double t) {
    if (other is! OriginalTextTheme) {
      return this;
    }
    return OriginalTextTheme(
      textTheme: TextTheme.lerp(textTheme, other.textTheme, t),
    );
  }
}
