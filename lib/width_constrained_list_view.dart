import 'package:flutter/material.dart';

import 'kgl_time_app.dart';

class WidthConstrainedListView extends ListView {
  WidthConstrainedListView({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    EdgeInsetsGeometry? padding,
    super.itemExtent,
    super.itemExtentBuilder,
    super.prototypeItem,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
    super.cacheExtent,
    List<Widget> children = const <Widget>[],
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
    super.hitTestBehavior,
  }) : super(
          padding: addHorizontalPadding(padding),
          children: constrainWidthOfListItems(children),
        );

  WidthConstrainedListView.builder({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    EdgeInsetsGeometry? padding,
    super.itemExtent,
    super.itemExtentBuilder,
    super.prototypeItem,
    required NullableIndexedWidgetBuilder itemBuilder,
    super.findChildIndexCallback,
    super.itemCount,
    super.addAutomaticKeepAlives = true,
    super.addRepaintBoundaries = true,
    super.addSemanticIndexes = true,
    super.cacheExtent,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
    super.hitTestBehavior,
  }) : super.builder(
            padding: addHorizontalPadding(padding),
            itemBuilder: (context, index) {
              Widget? child = itemBuilder(context, index);
              return child == null ? null : constrainWidthOfWidget(child);
            });

  /// Adds horizontal padding of 16 to the given padding.
  static EdgeInsetsGeometry addHorizontalPadding(
          [EdgeInsetsGeometry? padding]) =>
      EdgeInsets.symmetric(horizontal: 16).add(padding ?? EdgeInsets.zero);

  /// Constrains the width of the item to [KglTimeApp.maxPageWidth], if smaller than the available width, and centers it.
  static Widget constrainWidthOfWidget(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: KglTimeApp.maxPageWidth,
        ),
        child: child,
      ),
    );
  }

  /// Constrains the width of the list items to [KglTimeApp.maxPageWidth], if smaller than the available width.
  static List<Widget> constrainWidthOfListItems(List<Widget> children) {
    return children.map(constrainWidthOfWidget).toList();
  }
}
