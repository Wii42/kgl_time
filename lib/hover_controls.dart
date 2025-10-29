import 'package:flutter/material.dart';

class HoverControls extends StatefulWidget {
  final GlobalKey controlsKey;
  final Widget hoveringControls;
  final Widget Function(BuildContext context, double controlsHeight) builder;

  const HoverControls(
      {super.key,
      required this.hoveringControls,
      required this.builder,
      required this.controlsKey});

  @override
  State<HoverControls> createState() => _HoverControlsState();
}

class _HoverControlsState extends State<HoverControls> {
  double _controlsHeight = 0;

  @override
  void initState() {
    super.initState();
    _updateControlsHeight();
  }

  void _updateControlsHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getControlsHeight();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(child: widget.builder(context, _controlsHeight)),
      NotificationListener<LayoutChangedNotification>(
        onNotification: (notification) {
          _updateControlsHeight();
          return false;
        },
        child: Align(
          alignment: Alignment.topCenter,
          child: widget.hoveringControls,
        ),
      ),
    ]);
  }

  void _getControlsHeight() {
    // Use the key to get the RenderBox of the button and measure its height
    final RenderBox renderBox =
        widget.controlsKey.currentContext?.findRenderObject() as RenderBox;
    final double height = renderBox.size.height;
    if (height != _controlsHeight) {
      setState(() {
        _controlsHeight = height; // Update the button height
      });
    }
  }
}
