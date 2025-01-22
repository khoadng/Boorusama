// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/mobile.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';

part 'details_page_controller.dart';

double getTopActionIconAlignValue() => hasStatusBar() ? -0.92 : -1;

class DetailsPage<T> extends ConsumerStatefulWidget {
  const DetailsPage({
    super.key,
    required this.intitialIndex,
    required this.targetSwipeDown,
    required this.expandedBuilder,
    required this.pageCount,
    required this.topRightButtonsBuilder,
    this.onExpanded,
    this.onShrink,
    this.bottomSheet,
    required this.onExit,
    this.controller,
    this.onSwipeDownEnd,
    required this.currentSettings,
  });

  final int intitialIndex;
  final Widget targetSwipeDown;
  final Widget Function(
    BuildContext context,
    int page,
    bool expanded,
    bool enableSwipe,
  ) expandedBuilder;
  final int pageCount;
  final List<Widget> Function(bool expanded) topRightButtonsBuilder;
  final void Function()? onExpanded;
  final void Function()? onShrink;
  final Widget? bottomSheet;
  final void Function(int index) onExit;
  final DetailsPageController? controller;
  final void Function(int currentPage)? onSwipeDownEnd;
  final Settings Function() currentSettings;

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
      minFraction: 1.0,
      maxFraction: 1.01,
      extendPage: true,
    ),
  );
  var isExpanded = ValueNotifier(false);
  late final _shouldSlideDownNotifier = ValueNotifier(false);

  //details page contorller
  late final _controller = widget.controller ?? DetailsPageController();

  @override
  PageController get pageController => controller;

  late StreamSubscription<PageDirection> pageSubscription;

  @override
  Function() get popper => () {
        if (widget.onSwipeDownEnd != null) {
          widget.onSwipeDownEnd!(controller.currentPage.value);
        } else {
          _onBackButtonPressed(false);
        }
      };

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
    isExpanded.addListener(_showSystemStatusOnExpanded);

    if (_controller._hideOverlay.value) {
      _shouldSlideDownNotifier.value = true;
    }
    _controller.addListener(_onPageDetailsChanged);
    _controller.slideshow.addListener(_onSlideShowChanged);

    controller.currentPage.addListener(_onPageChanged);

    pageSubscription = _controller.pageStream.listen((event) async {
      // if expanding, shrunk the viewport first
      if (isExpanded.value) {
        await controller.animateViewportInsetTo(
          ViewportInset.shrunk,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 150),
        );
      }

      if (event == PageDirection.next) {
        // if last page, do nothing
        if (controller.page == widget.pageCount - 1) return;

        controller.nextPage(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      } else {
        // if first page, do nothing
        if (controller.page == 0) return;

        controller.previousPage(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }
    });

    super.initState();
  }

  Future<void> _onSlideShowChanged() async {
    final slideShow = _controller.slideshow.value;

    if (slideShow) {
      // if in expanded mode, scroll to top to exit expanded mode first
      if (isExpanded.value) {
        await controller.animateViewportInsetTo(
          ViewportInset.shrunk,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 150),
        );
      }

      final settings = widget.currentSettings();

      startAutoSlide(
        controller.currentPage.value,
        widget.pageCount,
        skipAnimation: settings.skipSlideshowTransition,
        direction: switch (settings.slideshowDirection) {
          SlideshowDirection.forward => SlideDirection.forward,
          SlideshowDirection.backward => SlideDirection.backward,
          SlideshowDirection.random => SlideDirection.random,
        },
        duration: settings.slideshowDuration,
      );
    } else {
      stopAutoSlide();
    }
  }

  void _onPageChanged() {
    _controller.currentPage.value = controller.currentPage.value;
  }

  void _onPageDetailsChanged() {
    _updateShouldSlideDown();
    if (_controller.pageSwipe != _pageSwipe) {
      setState(() {
        _pageSwipe = _controller.pageSwipe;
      });
    }
  }

  @override
  void didUpdateWidget(DetailsPage<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    _updateShouldSlideDown();
  }

  void _showSystemStatusOnExpanded() {
    if (isExpanded.value) {
      showSystemStatus();
    }
  }

  void _updateShouldSlideDown() {
    if (_keepBottomSheetDown.value) return;
    _shouldSlideDownNotifier.value = isSwipingDown.value ||
        isExpanded.value ||
        _controller.hideOverlay.value;
  }

  @override
  void dispose() {
    controller.currentPage.removeListener(_onPageChanged);
    controller.dispose();

    isSwipingDown.removeListener(_updateShouldSlideDown);
    isExpanded.removeListener(_updateShouldSlideDown);
    isExpanded.removeListener(_showSystemStatusOnExpanded);

    _controller.removeListener(_onPageDetailsChanged);

    _controller.slideshow.removeListener(_onSlideShowChanged);
    stopAutoSlide();

    if (widget.controller == null) {
      _controller.dispose();
    }

    pageSubscription.cancel();

    super.dispose();
  }

  void _handlePointerMove(PointerMoveEvent event, bool expanded) {
    if (_controller.blockSwipe ||
        expanded ||
        context.maybeNavigator?.userGestureInProgress == true ||
        _controller.slideshow.value ||
        _isSwiping) {
      return;
    }

    handlePointerMove(event);
  }

  void _handlePointerUp(PointerUpEvent event, bool expanded) {
    if (expanded || _controller.blockSwipe) {
      return;
    }

    handlePointerUp(event);
  }

  void _onBackButtonPressed(bool didPop) {
    _keepBottomSheetDown.value = true;
    _controller.restoreSystemStatus();
    if (!didPop) {
      context.navigator.pop();
    }
    widget.onExit(controller.currentPage.value);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _onBackButtonPressed(didPop);
          return;
        }

        _onBackButtonPressed(didPop);
      },
      child: Scaffold(
        body: ValueListenableBuilder(
          valueListenable: isExpanded,
          builder: (context, expanded, navButtonGroup) => Stack(
            children: [
              _buildScrollContent(expanded),
              navButtonGroup!,
              _buildBottomSheet(),
              _buildTopRightButtonGroup(expanded),
            ],
          ),
          child: _buildNavigationButtonGroup(context),
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
              builder: (context, shouldSlideDown, _) => _BottomSheet(
                shouldSlideDown: shouldSlideDown,
                bottomSheet: widget.bottomSheet,
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildScrollContent(
    bool expanded,
  ) {
    return ValueListenableBuilder(
      valueListenable: isSwipingDown,
      builder: (_, swipingDown, __) => Builder(
        builder: (context) {
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
                          child: _buildPageView(
                            expanded,
                          ),
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
                          child: _buildSwipeTarget(expanded),
                        )
                      : Offstage(
                          offstage: !offstage,
                          child: _buildSwipeTarget(expanded),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageView(
    bool expanded,
  ) {
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
          _controller.setExpanded(metrics.isPageExpanded);
          if (isExpanded.value) {
            widget.onExpanded?.call();
          } else {
            widget.onShrink?.call();
          }
        },
        physics: _pageSwipe
            ? const DefaultPageViewScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemCount: widget.pageCount,
        itemBuilder: (context, page) => Scaffold(
          floatingActionButton: ScrollToTop(
            scrollController: PageContentScrollController.of(context),
            child: BooruScrollToTopButton(
              onPressed: () {
                controller.animateViewportInsetTo(ViewportInset.shrunk,
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 150));
              },
            ),
          ),
          body: widget.expandedBuilder(
            context,
            page,
            expanded,
            _pageSwipe,
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeTarget(bool expanded) {
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
              child: widget.targetSwipeDown,
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
        builder: (_, hide, __) => AnimatedSwitcher(
          duration: Durations.long2,
          child: !hide
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
                          onBack: () => _onBackButtonPressed(false),
                        ),
                      ),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildTopRightButtonGroup(bool expanded) {
    return ValueListenableBuilder(
      valueListenable: _controller.hideOverlay,
      builder: (_, hide, __) => AnimatedSwitcher(
        duration: Durations.long2,
        child: !hide
            ? Align(
                alignment: Alignment(
                  0.9,
                  getTopActionIconAlignValue(),
                ),
                child: ValueListenableBuilder(
                    valueListenable: _shouldSlideDownNotifier,
                    builder: (context, value, child) => _SlideUpContainer(
                          shouldSlideUp: value && !expanded,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: OverflowBar(
                              alignment: MainAxisAlignment.end,
                              spacing: 4,
                              children: [
                                ...widget.topRightButtonsBuilder(
                                  expanded,
                                ),
                              ],
                            ),
                          ),
                        )),
              )
            : null,
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
          icon: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(
              Symbols.arrow_back_ios,
              color: Colors.white,
            ),
          ),
          onPressed: onBack,
        ),
        const SizedBox(
          width: 4,
        ),
        CircularIconButton(
          icon: const Icon(
            Symbols.home,
            color: Colors.white,
            fill: 1,
          ),
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
  });

  final Widget? bottomSheet;
  final bool shouldSlideDown;

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
        end: widget.shouldSlideDown ? const Offset(0, 1) : Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Curves.easeOut,
        ),
      ),
      child: widget.bottomSheet ?? const SizedBox.shrink(),
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
        begin: Offset.zero,
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
        mass: 50,
        stiffness: 80,
        damping: 0.8,
      );
}
