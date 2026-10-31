import 'package:material_ui/material_ui.dart';

class HoverControls extends StatefulWidget {
  final GlobalKey controlsKey;
  final Widget hoveringControls;
  final Widget Function(BuildContext context, double controlsHeight) builder;

  const HoverControls({
    super.key,
    required this.hoveringControls,
    required this.builder,
    required this.controlsKey,
  });

  @override
  State<HoverControls> createState() => _HoverControlsState();
}

class _HoverControlsState extends State<HoverControls> {
  double _controlsHeight = 0;
  bool _measurementScheduled = false;

  @override
  void initState() {
    super.initState();
    _updateControlsHeight();
  }

  void _updateControlsHeight() {
    if (_measurementScheduled) return;
    _measurementScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measurementScheduled = false;
      if (mounted) _getControlsHeight();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: widget.builder(context, _controlsHeight)),
        NotificationListener<SizeChangedLayoutNotification>(
          onNotification: (notification) {
            _updateControlsHeight();
            return false;
          },
          child: Align(
            alignment: Alignment.topCenter,
            child: SizeChangedLayoutNotifier(child: widget.hoveringControls),
          ),
        ),
      ],
    );
  }

  void _getControlsHeight() {
    // Use the key to get the RenderBox of the button and measure its height
    final RenderObject? renderObject = widget.controlsKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;
    final RenderBox renderBox = renderObject;
    final double height = renderBox.size.height;
    if (height != _controlsHeight) {
      setState(() {
        _controlsHeight = height; // Update the button height
      });
    }
  }
}
