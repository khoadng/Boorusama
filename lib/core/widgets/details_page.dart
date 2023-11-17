// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/router.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

part 'details_page_controller.dart';

double getTopActionIconAlignValue() => hasStatusBar() ? -0.92 : -1;

class DetailsPage<T> extends ConsumerStatefulWidget {
  const DetailsPage({
    super.key,
    this.onPageChanged,
    required this.intitialIndex,
    required this.targetSwipeDownBuilder,
    required this.expandedBuilder,
    required this.pageCount,
    required this.topRightButtonsBuilder,
    this.onExpanded,
    this.bottomSheet,
    required this.onExit,
    this.controller,
  });

  final void Function(int page)? onPageChanged;
  final int intitialIndex;
  final Widget Function(BuildContext context, int index) targetSwipeDownBuilder;
  final Widget Function(BuildContext context, int page, int currentPage,
      bool expanded, bool enableSwipe) expandedBuilder;
  final int pageCount;
  final List<Widget> Function(int currentPage, bool expanded)
      topRightButtonsBuilder;
  final void Function(int currentPage)? onExpanded;
  final Widget? Function(int currentPage)? bottomSheet;
  final void Function(int index) onExit;
  final DetailsPageController? controller;

  @override
  ConsumerState<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState<T> extends ConsumerState<DetailsPage<T>>
    with
        TickerProviderStateMixin,
        SwipeDownToDismissMixin<DetailsPage<T>>,
        AutomaticSlideMixin {
  late final controller = ExprollablePageController(
    initialPage: widget.intitialIndex,
    viewportConfiguration: ViewportConfiguration(
      minFraction: 0.99,
    ),
  );
  var isExpanded = ValueNotifier(false);
  late final _shouldSlideDownNotifier = ValueNotifier(false);
  final _scrollNotification = ValueNotifier<ScrollNotification?>(null);

  //details page contorller
  late final _controller = widget.controller ?? DetailsPageController();

  @override
  PageController get pageController => controller;

  @override
  Function() get popper => () => _onBackButtonPressed();
  bool get _isSwiping {
    if (!controller.hasClients) return false;
    return controller.page != controller.page?.round();
  }

  final _keepBottomSheetDown = ValueNotifier(false);
  var _pageSwipe = true;

  @override
  void initState() {
    isSwipingDown.addListener(_updateShouldSlideDown);
    isExpanded.addListener(_updateShouldSlideDown);

    _controller.addListener(_onPageDetailsChanged);

    super.initState();
  }

  void _onPageDetailsChanged() {
    _updateShouldSlideDown();
    if (_controller.pageSwipe != _pageSwipe) {
      setState(() {
        _pageSwipe = _controller.pageSwipe;
      });
    }

    final (slideShow, skipIndexes) = _controller.slideShow.value;

    if (slideShow) {
      startAutoSlide(
        controller.currentPage.value,
        widget.pageCount,
        skipIndexes: skipIndexes,
      );
    } else {
      stopAutoSlide();
    }
  }

  @override
  void didUpdateWidget(DetailsPage<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    _updateShouldSlideDown();
  }

  void _updateShouldSlideDown() {
    if (_keepBottomSheetDown.value) return;
    _shouldSlideDownNotifier.value = isSwipingDown.value ||
        isExpanded.value ||
        _controller.hideOverlay.value;
  }

  @override
  void dispose() {
    controller.dispose();

    isSwipingDown.removeListener(_updateShouldSlideDown);
    isExpanded.removeListener(_updateShouldSlideDown);

    _controller.removeListener(_onPageDetailsChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handlePointerMove(PointerMoveEvent event, bool expanded) {
    if (!_controller.pageSwipe ||
        !_controller.swipeDownToDismiss ||
        expanded ||
        _controller.slideShow.value.$1 ||
        _isSwiping) {
      return;
    }

    handlePointerMove(event);
  }

  void _handlePointerUp(PointerUpEvent event, bool expanded) {
    if (expanded || !_controller.pageSwipe || !_controller.swipeDownToDismiss) {
      return;
    }

    handlePointerUp(event);
  }

  void _onBackButtonPressed() {
    _keepBottomSheetDown.value = true;
    context.navigator.pop();
    widget.onExit(controller.currentPage.value);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) return;
        _onBackButtonPressed();
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // set the scroll notification to the value notifier on next frame
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if (!mounted) return;
            _scrollNotification.value = notification;
          });
          return false;
        },
        child: Scaffold(
          floatingActionButton: ValueListenableBuilder(
            valueListenable: isExpanded,
            builder: (context, expanded, child) => expanded
                ? ValueListenableBuilder(
                    valueListenable: _scrollNotification,
                    builder: (_, notification, __) => HideOnScroll(
                      scrollNotification: notification,
                      child: FloatingActionButton.small(
                        onPressed: () {
                          controller.animateViewportInsetTo(
                              ViewportInset.shrunk,
                              curve: Curves.easeOut,
                              duration: const Duration(milliseconds: 150));
                        },
                        child: const Icon(Icons.keyboard_arrow_up),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          body: Stack(
            children: [
              _buildScrollContent(),
              _buildNavigationButtonGroup(context),
              _buildTopRightButtonGroup(),
              _buildBottomSheet(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: widget.bottomSheet != null
          ? ValueListenableBuilder(
              valueListenable: _shouldSlideDownNotifier,
              builder: (context, shouldSlideDown, _) => ValueListenableBuilder(
                valueListenable: controller.currentPage,
                builder: (_, page, __) => _BottomSheet(
                  shouldSlideDown: shouldSlideDown,
                  bottomSheet: widget.bottomSheet,
                  page: page,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildScrollContent() {
    return ValueListenableBuilder(
      valueListenable: controller.currentPage,
      builder: (context, currentPage, _) => ValueListenableBuilder(
        valueListenable: isSwipingDown,
        builder: (_, swipingDown, __) => ValueListenableBuilder(
          valueListenable: isExpanded,
          builder: (context, expanded, _) {
            final offstage = swipingDown && !expanded;
            return ValueListenableBuilder(
              valueListenable: _keepBottomSheetDown,
              builder: (_, keepDown, __) => Stack(
                children: [
                  ValueListenableBuilder(
                    valueListenable: dragDistance,
                    builder: (_, drag, __) => drag > 0 && keepDown
                        ? const SizedBox.shrink()
                        : Offstage(
                            offstage: offstage,
                            child: _buildPageView(expanded, currentPage),
                          ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: dragDistance,
                    builder: (_, drag, __) => drag > 0
                        ? ConditionalParentWidget(
                            condition: !keepDown,
                            conditionalBuilder: (child) => Offstage(
                              offstage: !offstage,
                              child: child,
                            ),
                            child: _buildSwipeTarget(expanded, currentPage),
                          )
                        : Offstage(
                            offstage: !offstage,
                            child: _buildSwipeTarget(expanded, currentPage),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPageView(bool expanded, int currentPage) {
    return Listener(
      onPointerMove: (event) => _handlePointerMove(event, expanded),
      onPointerUp: (event) => _handlePointerUp(event, expanded),
      child: ExprollablePageView(
        controller: controller,
        onViewportChanged: (metrics) {
          if (metrics.isPageExpanded == isExpanded.value) {
            return;
          }

          isExpanded.value = metrics.isPageExpanded;
          if (isExpanded.value) {
            widget.onExpanded?.call(currentPage);
          }
        },
        onPageChanged: widget.onPageChanged,
        physics: _pageSwipe
            ? const DefaultPageViewScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemCount: widget.pageCount,
        itemBuilder: (context, page) {
          return ValueListenableBuilder(
            valueListenable: isExpanded,
            builder: (context, value, child) => widget.expandedBuilder(
              context,
              page,
              currentPage,
              value,
              _pageSwipe,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwipeTarget(bool expanded, int currentPage) {
    return ValueListenableBuilder(
      valueListenable: dragDistance,
      builder: (context, dd, child) => ValueListenableBuilder(
        valueListenable: dragDistanceX,
        builder: (context, ddx, child) => Transform.translate(
          offset: Offset(ddx, dd),
          child: Listener(
            onPointerMove: (event) => _handlePointerMove(event, expanded),
            onPointerUp: (event) => _handlePointerUp(event, expanded),
            child: Transform.scale(
              scale: scale,
              child: widget.targetSwipeDownBuilder(
                context,
                currentPage,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtonGroup(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isExpanded,
      builder: (_, expanded, __) => ValueListenableBuilder(
        valueListenable: _controller.hideOverlay,
        builder: (_, hide, __) => !hide
            ? Align(
                alignment: Alignment(
                  -0.75,
                  getTopActionIconAlignValue(),
                ),
                child: ValueListenableBuilder(
                  valueListenable: _shouldSlideDownNotifier,
                  builder: (context, value, child) => _SlideUpContainer(
                    shouldSlideUp: value && !expanded,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: _NavigationButtonBar(
                        onBack: _onBackButtonPressed,
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildTopRightButtonGroup() {
    return ValueListenableBuilder(
      valueListenable: isExpanded,
      builder: (_, expanded, __) => ValueListenableBuilder(
        valueListenable: _controller.hideOverlay,
        builder: (_, hide, __) => !hide
            ? Align(
                alignment: Alignment(
                  0.9,
                  getTopActionIconAlignValue(),
                ),
                child: ValueListenableBuilder(
                    valueListenable: _shouldSlideDownNotifier,
                    builder: (context, value, child) => _SlideUpContainer(
                          shouldSlideUp: value && !expanded,
                          child: ValueListenableBuilder(
                            valueListenable: controller.currentPage,
                            builder: (_, page, __) => ButtonBar(
                              children: [
                                ...widget.topRightButtonsBuilder(
                                    page, expanded),
                              ],
                            ),
                          ),
                        )),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _NavigationButtonBar extends StatelessWidget {
  const _NavigationButtonBar({
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircularIconButton(
          icon: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: !context.themeMode.isDark
                ? Icon(
                    Icons.arrow_back_ios,
                    color: context.colorScheme.onPrimary,
                  )
                : const Icon(Icons.arrow_back_ios),
          ),
          onPressed: onBack,
        ),
        const SizedBox(
          width: 4,
        ),
        CircularIconButton(
          icon: !context.themeMode.isDark
              ? Icon(
                  Icons.home,
                  color: context.colorScheme.onPrimary,
                )
              : const Icon(Icons.home),
          onPressed: () => goToHomePage(context),
        ),
      ],
    );
  }
}

class _BottomSheet extends StatefulWidget {
  const _BottomSheet({
    this.bottomSheet,
    required this.shouldSlideDown,
    required this.page,
  });

  final Widget? Function(int page)? bottomSheet;
  final bool shouldSlideDown;
  final int page;

  @override
  __BottomSheetState createState() => __BottomSheetState();
}

class __BottomSheetState extends State<_BottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      value: 1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animController.dispose();
  }

  @override
  void didUpdateWidget(covariant _BottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.shouldSlideDown != widget.shouldSlideDown) {
      _animController.animateTo(
        widget.shouldSlideDown ? 0 : 1,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween(
        begin: const Offset(0, 1),
        end: widget.shouldSlideDown ? const Offset(0, 1) : const Offset(0, 0),
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Curves.easeOut,
        ),
      ),
      child: widget.bottomSheet?.call(widget.page) ?? const SizedBox.shrink(),
    );
  }
}

class _SlideUpContainer extends StatefulWidget {
  const _SlideUpContainer({
    required this.shouldSlideUp,
    required this.child,
  });

  final Widget child;
  final bool shouldSlideUp;

  @override
  _SlideUpContainerState createState() => _SlideUpContainerState();
}

class _SlideUpContainerState extends State<_SlideUpContainer>
    with TickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      value: 0,
      vsync: this,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animController.dispose();
  }

  @override
  void didUpdateWidget(covariant _SlideUpContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.shouldSlideUp != widget.shouldSlideUp) {
      _animController.animateTo(
        widget.shouldSlideUp ? 1 : 0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween(
        begin: const Offset(0, 0),
        end: const Offset(0, -1.5),
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Curves.easeIn,
        ),
      ),
      child: widget.child,
    );
  }
}

class DefaultPageViewScrollPhysics extends ScrollPhysics {
  const DefaultPageViewScrollPhysics({super.parent});

  @override
  DefaultPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return DefaultPageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 1,
      );
}
