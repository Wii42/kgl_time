import 'package:flutter/material.dart';

enum WorkCategory {
  phoneCall('Telefonanruf', icon: Icons.phone),
  category2('Kategorie 2', icon: Icons.onetwothree),
  category3('Kategorie 3', icon: Icons.onetwothree),
  category4('Kategorie 4', icon: Icons.onetwothree),
  category5('Kategorie 5', icon: Icons.onetwothree),
  ;

  final String displayName;

  final IconData? icon;

  const WorkCategory(this.displayName,{this.icon});
}