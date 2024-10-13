import 'package:isar/isar.dart';

import '../isar_icon_data.dart';
import 'isar_storable.dart';

part 'work_category.g.dart';

abstract class IWorkCategory {
  final String displayName;

  final IsarIconData? icon;

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
  WorkCategory(super.displayName, {super.icon});

  EmbeddedWorkCategory toEmbedded() {
    return EmbeddedWorkCategory(displayName: displayName, icon: icon);
  }
}

@embedded
class EmbeddedWorkCategory extends IWorkCategory {
  EmbeddedWorkCategory({String displayName = '', super.icon})
      : super(displayName);
}
