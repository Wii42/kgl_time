import 'package:material_ui/material_ui.dart';

class ColorThemeExtension extends ThemeExtension<ColorThemeExtension> {
  final Color primaryColor;
  final Color actionColor;

  new({
    required this.primaryColor,
    required this.actionColor,
  });

  @override
  ColorThemeExtension copyWith({Color? primaryColor, Color? actionColor}) {
    return ColorThemeExtension(
      primaryColor: primaryColor ?? this.primaryColor,
      actionColor: actionColor ?? this.actionColor,
    );
  }

  @override
  ColorThemeExtension lerp(covariant ThemeExtension<ColorThemeExtension>? other, double t) {
    if (other is! ColorThemeExtension) {
      return this;
    }
    return ColorThemeExtension(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      actionColor: Color.lerp(actionColor, other.actionColor, t)!,
    );
  }
}
