import 'dart:math' as math;

import 'package:flutter/gestures.dart';

/// Gives vertical scrolling priority unless a drag starts within 20 degrees
/// of horizontal. Once a direction wins, it stays locked for that gesture.
class TabSwipeGestureRecognizer extends HorizontalDragGestureRecognizer {
  TabSwipeGestureRecognizer({super.debugOwner});

  static final double _maxSlope = math.tan(20 * math.pi / 180);
  final Map<int, Offset> _pendingDisplacements = <int, Offset>{};

  @override
  void addAllowedPointer(PointerDownEvent event) {
    _pendingDisplacements[event.pointer] = Offset.zero;
    super.addAllowedPointer(event);
  }

  @override
  void addAllowedPointerPanZoom(PointerPanZoomStartEvent event) {
    _pendingDisplacements[event.pointer] = Offset.zero;
    super.addAllowedPointerPanZoom(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    final Offset? pending = _pendingDisplacements[event.pointer];
    final Offset? delta = switch (event) {
      PointerMoveEvent() => event.delta,
      PointerPanZoomUpdateEvent() => event.panDelta,
      _ => null,
    };
    if (pending != null && delta != null) {
      final Offset displacement = pending + delta;
      _pendingDisplacements[event.pointer] = displacement;
      // Ignore initial finger jitter, using the same device slop as Flutter.
      if (displacement.distance > computeHitSlop(event.kind, gestureSettings)) {
        _pendingDisplacements.remove(event.pointer);
        if (displacement.dy.abs() > displacement.dx.abs() * _maxSlope) {
          resolvePointer(event.pointer, GestureDisposition.rejected);
          return;
        }
      }
    }
    if (event is PointerUpEvent || event is PointerCancelEvent || event is PointerPanZoomEndEvent) {
      _pendingDisplacements.remove(event.pointer);
    }
    super.handleEvent(event);
  }

  @override
  void acceptGesture(int pointer) {
    _pendingDisplacements.remove(pointer);
    super.acceptGesture(pointer);
  }

  @override
  void rejectGesture(int pointer) {
    _pendingDisplacements.remove(pointer);
    super.rejectGesture(pointer);
  }

  @override
  void dispose() {
    _pendingDisplacements.clear();
    super.dispose();
  }
}
