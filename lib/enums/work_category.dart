import 'package:flutter/material.dart';

enum WorkCategory {
  phoneCall('Telefonanruf', icon: Icons.phone),
  category2('Kategorie 2'),
  category3('Kategorie 3'),
  category4('Kategorie 4'),
  category5('Kategorie 5'),
  ;

  final String displayName;

  final IconData? icon;

  const WorkCategory(this.displayName,{this.icon});
}