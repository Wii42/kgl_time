import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kgl_time/app_layout_constants.dart';
import 'package:kgl_time/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../app_route.dart';

abstract class KglPage extends StatelessWidget {
  final String appTitle;

  Widget body(BuildContext context);

  // Null means this page uses the app title; subclasses may provide a title.
  // ignore: many_lints/function_always_returns_null
  String? pageTitle(AppLocalizations? loc) => null;

  bool get showSettingsButton => true;

  const KglPage({super.key, required this.appTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StatusBarSafeArea(
        child: _ContentAwareAppBar(
          title: _AppBarTitle(appTitle: appTitle, pageTitle: pageTitle),
          fixedAppBarMinHeight: AppLayoutConstants.fixedAppBarMinHeight,
          actions: [
            if (showSettingsButton)
              IconButton(
                icon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.settings),
                ),
                onPressed: () => context.push(AppRoute.settings.path),
              ),
          ],
          child: SafeArea(top: false, bottom: false, child: body(context)),
        ),
      ),
    );
  }
}

class _ContentAwareAppBar extends StatefulWidget {
  final Widget title;
  final List<Widget> actions;
  final Widget child;
  final double? fixedAppBarMinHeight;

  const _ContentAwareAppBar({
    required this.title,
    required this.actions,
    required this.child,
    this.fixedAppBarMinHeight,
  });

  @override
  State<_ContentAwareAppBar> createState() => _ContentAwareAppBarState();
}

class _ContentAwareAppBarState extends State<_ContentAwareAppBar> {
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _controller.hasClients && _controller.offset > 0) _controller.jumpTo(0);
          });
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

class _AppBarTitle extends StatelessWidget {
  final String appTitle;
  final String? Function(AppLocalizations? loc) pageTitle;

  const new({
    required this.appTitle,
    required this.pageTitle,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations? localizations = AppLocalizations.of(context);
    TextTheme textTheme = theme.textTheme;
    String? pageTitle = this.pageTitle(localizations);
    String largeTitle = pageTitle ?? appTitle;
    String? smallTitle = pageTitle != null ? appTitle : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (smallTitle != null)
          Text(
            smallTitle,
            style: textTheme.bodySmall?.copyWith(color: theme.appBarTheme.foregroundColor),
          ),
        Text(largeTitle),
      ],
    );
  }
}

/// Makes sure that the status bar area is filled with a background color, even when the app bar scrolls out of view.
class StatusBarSafeArea extends StatelessWidget {
  final Widget? child;

  const new({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color:
            Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
        child: SafeArea(
          left: false,
          right: false,
          bottom: false,
          child: ColoredBox(color: Theme.of(context).scaffoldBackgroundColor, child: child),
        ),
      ),
    );
  }
}
