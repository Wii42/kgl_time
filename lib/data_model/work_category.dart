import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:json_annotation/json_annotation.dart';

import 'isar_storable.dart';

part 'work_category.g.dart';
abstract class IWorkCategory {
  String displayName;

  @Enumerated(EnumType.name)
  CategoryIcon? icon;

  IWorkCategory(this.displayName, {this.icon});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is IWorkCategory &&
        other.displayName == displayName &&
        other.icon == icon;
  }

  @override
  int get hashCode => Object.hash(displayName, icon);

  Map<String,dynamic> toJson();
}

@Collection(accessor: 'workCategories', inheritance: true)
@JsonSerializable()
class WorkCategory extends IWorkCategory implements IsarStorable {
  @override
  Id id = Isar.autoIncrement;
  int listIndex;

  WorkCategory(super.displayName, {super.icon, this.listIndex = -1});

  EmbeddedWorkCategory toEmbedded() {
    return EmbeddedWorkCategory(displayName: displayName, icon: icon, id: id);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WorkCategory &&
        other.id == id &&
        other.displayName == displayName &&
        other.icon == icon &&
        other.listIndex == listIndex;
  }

  @override
  String toString() {
    return 'WorkCategory{id: $id, displayName: $displayName, icon: $icon, listIndex: $listIndex}';
  }

  @override
  int get hashCode => Object.hash(id, displayName, icon, listIndex);

  @override
  Map<String, dynamic> toJson() => _$WorkCategoryToJson(this);

  factory WorkCategory.fromJson(Map<String, dynamic> json) =>
      _$WorkCategoryFromJson(json);
}

@embedded
@JsonSerializable()
class EmbeddedWorkCategory extends IWorkCategory {
  int? id;

  EmbeddedWorkCategory({String displayName = '', super.icon, this.id})
      : super(displayName);

  WorkCategory toWorkCategory() {
    WorkCategory category = WorkCategory(displayName, icon: icon);
    if (id != null) {
      category.id = id!;
    }
    return category;
  }

  @override
  Map<String, dynamic> toJson() => _$EmbeddedWorkCategoryToJson(this);

  factory EmbeddedWorkCategory.fromJson(Map<String, dynamic> json) =>
      _$EmbeddedWorkCategoryFromJson(json);
}

enum CategoryIcon {
  phone(Icons.phone),
  work(Icons.work),
  home(Icons.home),
  school(Icons.school),
  shopping(Icons.shopping_cart),
  sport(Icons.sports),
  transport(Icons.directions_bus),
  ;

  const CategoryIcon(IconData icon);
}
