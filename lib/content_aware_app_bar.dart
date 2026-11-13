import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

class ContentAwareAppBar extends StatefulWidget {
  final Widget title;
  final List<Widget> actions;
  final Widget child;
  final double? fixedAppBarMinHeight;

  const ContentAwareAppBar({
    super.key,
    required this.title,
    required this.actions,
    required this.child,
    this.fixedAppBarMinHeight,
  });

  @override
  State<ContentAwareAppBar> createState() => _ContentAwareAppBarState();
}

class _ContentAwareAppBarState extends State<ContentAwareAppBar> {
  final ScrollController _controller = ScrollController();
  bool _overflows = false;
  bool _updateScheduled = false;
  bool _active = false;
  ScrollMetrics? _metrics;

  Size? _size;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_scheduleUpdate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The branch container and Navigator disable tickers for hidden pages.
    final bool active =
        TickerMode.valuesOf(context).enabled && (ModalRoute.isCurrentOf(context) ?? true);
    if (active && !_active) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _revealAppBar());
    }
    _active = active;
  }

  void _revealAppBar() {
    if (!mounted || !_active || !_controller.hasClients) return;
    final ScrollPosition position = _controller.position;
    if (!position.hasContentDimensions) return;
    final double hiddenExtent = position.pixels - position.minScrollExtent;
    if (hiddenExtent <= 0) return;
    // With floatHeaderSlivers, a reverse scroll reveals the outer header first.
    // Consume exactly its hidden extent so the inner content keeps its offset.
    // jumpTo/animateTo would also reset the inner scroll position.
    position.pointerScroll(-hiddenExtent);
  }

  void _scheduleUpdate() {
    if (_updateScheduled) return;
    _updateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScheduled = false;
      if (!mounted || _metrics == null) return;
      // Measure overflow only with the toolbar visible. Hiding it enlarges the
      // body's viewport and must not change the decision that allowed it to hide.
      if (_controller.hasClients && _controller.offset > 0) return;
      final ScrollMetrics metrics = _metrics!;
      final bool overflows = metrics.maxScrollExtent - metrics.minScrollExtent > 0.5;
      if (_overflows != overflows) setState(() => _overflows = overflows);
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  bool _onMetrics(ScrollMetricsNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) return false;
    // Lazy lists revise their extent estimates while scrolling. These updates
    // must never reset the coordinated inner and outer scroll positions.
    _metrics = notification.metrics;
    _scheduleUpdate();
    return false;
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller.removeListener(_scheduleUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size size = constraints.biggest;
        final bool hideAppBar = widget.fixedAppBarMinHeight != null
            ? _overflows && size.height < widget.fixedAppBarMinHeight!
            : _overflows;
        if (_size != size) {
          _size = size;
          WidgetsBinding.instance.addPostFrameCallback((_) => _revealAppBar());
        }
        final AppBar fixedAppBar = AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          primary: false,
          scrolledUnderElevation: 0,
          title: widget.title,
          actions: widget.actions,
        );
        // Keep the body in the same scroll container in both modes. A fixed
        // toolbar gets its own space so it cannot overlap the body's viewport.
        return Column(
          children: [
            SizedBox(
              height: hideAppBar
                  ? 0
                  : AppBar.preferredHeightFor(context, fixedAppBar.preferredSize),
              child: Offstage(offstage: hideAppBar, child: fixedAppBar),
            ),
            Expanded(
              child: NestedScrollView(
                controller: _controller,
                physics: _overflows ? null : const NeverScrollableScrollPhysics(),
                floatHeaderSlivers: true,
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  if (hideAppBar)
                    SliverAppBar(
                      systemOverlayStyle: SystemUiOverlayStyle.light,
                      floating: true,
                      scrolledUnderElevation: 0,
                      title: widget.title,
                      actions: widget.actions,
                    ),
                ],
                body: NotificationListener<ScrollMetricsNotification>(
                  onNotification: _onMetrics,
                  child: widget.child,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
