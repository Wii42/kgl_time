import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'isar_icon_data.g.dart';

@embedded
class IsarIconData extends IconData {
  @override
  const IsarIconData({
    int codePoint = 61183, // Icons.broken_image_outlined.codePoint
    super.fontFamily,
    super.fontPackage,
    super.matchTextDirection = false,
    super.fontFamilyFallback,
  }) : super(codePoint);

  factory IsarIconData.fromIconData(IconData iconData) {
    return IsarIconData(
      codePoint: iconData.codePoint,
      fontFamily: iconData.fontFamily,
      fontPackage: iconData.fontPackage,
      matchTextDirection: iconData.matchTextDirection,
      fontFamilyFallback: iconData.fontFamilyFallback,
    );
  }

  IconData toIconData() {
    return IconData(
      codePoint,
      fontFamily: fontFamily,
      fontPackage: fontPackage,
      matchTextDirection: matchTextDirection,
      fontFamilyFallback: fontFamilyFallback,
    );
  }
}
