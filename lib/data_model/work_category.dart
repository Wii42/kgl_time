import 'package:isar/isar.dart';

import '../isar_icon_data.dart';
import 'isar_storable.dart';

part 'work_category.g.dart';

abstract class IWorkCategory {
  String displayName;

  IsarIconData? icon;

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
}

@Collection(accessor: 'workCategories', inheritance: true)
class WorkCategory extends IWorkCategory implements IsarStorable {
  @override
  Id id = Isar.autoIncrement;
  int listIndex;
  WorkCategory(super.displayName, {super.icon, this.listIndex = -1});

  EmbeddedWorkCategory toEmbedded() {
    return EmbeddedWorkCategory(displayName: displayName, icon: icon, id: id);
  }

  @override
  String toString() {
    return 'WorkCategory{id: $id, displayName: $displayName, icon: $icon, listIndex: $listIndex}';
  }
}

@embedded
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
}
