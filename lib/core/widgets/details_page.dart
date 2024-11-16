// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/mobile.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'post_details_page_view.dart';

part 'details_page_controller.dart';

double getTopActionIconAlignValue() => hasStatusBar() ? -0.92 : -1;

class DetailsPageMobile<T> extends StatefulWidget {
  const DetailsPageMobile({
    super.key,
    required this.currentSettings,
    required this.controller,
    required this.info,
    required this.itemBuilder,
    required this.itemCount,
    this.onExpanded,
    required this.onExit,
    this.onSwipeDownThresholdReached,
    this.bottomSheet,
    required this.topRightButtons,
  });

  final DetailsPageMobileController controller;

  final Widget topRightButtons;
  final Widget info;
  final Widget? bottomSheet;

  final void Function()? onExpanded;
  final void Function() onExit;
  final void Function()? onSwipeDownThresholdReached;

  final Settings Function() currentSettings;

  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;

  @override
  State<DetailsPageMobile> createState() => _DetailsPageMobileState();
}

class _DetailsPageMobileState<T> extends State<DetailsPageMobile<T>>
    with AutomaticSlideMixin {
  late final _controller = widget.controller;

  @override
  PageController get pageController => _pageController.pageController;

  PostDetailsPageViewController get _pageController =>
      _controller._pageViewController;

  late StreamSubscription<PageDirection> pageSubscription;

  @override
  void initState() {
    _controller.slideshow.addListener(_onSlideShowChanged);

    _pageController.expandedNotifier.addListener(_onExpanded);

    pageSubscription = _controller.pageStream.listen((event) async {
      // if expanding, shrunk the viewport first
      if (_pageController.isExpanded) {
        await _pageController.resetSheet(
          duration: const Duration(milliseconds: 300),
        );
      }

      if (event == PageDirection.next) {
        // if last page, do nothing
        if (_pageController.currentPage == widget.itemCount - 1) return;

        _pageController.nextPage(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      } else {
        // if first page, do nothing
        if (_pageController.currentPage == 0) return;

        _pageController.previousPage(
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
      if (_pageController.isExpanded) {
        await _pageController.resetSheet(
          duration: const Duration(milliseconds: 300),
        );
      }

      final settings = widget.currentSettings();

      startAutoSlide(
        _pageController.currentPage,
        widget.itemCount,
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

  void _onExpanded() {
    if (widget.onExpanded != null) {
      widget.onExpanded!();
    }

    if (_pageController.isExpanded) {
      showSystemStatus();
      _controller.setHideOverlay(false);
    }
  }

  @override
  void dispose() {
    _pageController.expandedNotifier.removeListener(_onExpanded);

    _controller.slideshow.removeListener(_onSlideShowChanged);
    stopAutoSlide();

    pageSubscription.cancel();

    super.dispose();
  }

  void _onBackButtonPressed(bool didPop) {
    _controller.restoreSystemStatus();
    if (!didPop) {
      context.navigator.pop();
    }
    widget.onExit();
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
        body: Stack(
          children: [
            PostDetailsPageView(
              maxChildSize: 0.9,
              controller: _pageController,
              onSwipeDownThresholdReached: widget.onSwipeDownThresholdReached ??
                  () {
                    widget.onExit();
                    _onBackButtonPressed(false);
                  },
              sheet: Builder(
                builder: (context) {
                  final scrollController =
                      PostDetailsSheetScrollController.of(context);

                  return Scaffold(
                    floatingActionButton: ScrollToTop(
                      scrollController: scrollController,
                      child: BooruScrollToTopButton(
                        onPressed: () {
                          _pageController.resetSheet(
                            duration: const Duration(milliseconds: 250),
                          );
                        },
                      ),
                    ),
                    body: Stack(
                      children: [
                        Positioned.fill(
                          child: widget.info,
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: ValueListenableBuilder(
                            valueListenable: _pageController.expandedNotifier,
                            builder: (context, expanded, child) =>
                                expanded ? child! : const SizedBox.shrink(),
                            child: const Padding(
                              padding: EdgeInsets.only(
                                top: 8,
                              ),
                              child: DragLine(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              itemCount: widget.itemCount,
              itemBuilder: widget.itemBuilder,
            ),
            if (widget.bottomSheet != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: UIOverlayVisibility(
                  controller: _controller,
                  pageController: _pageController,
                  child: ValueListenableBuilder(
                    valueListenable: _pageController.expandedNotifier,
                    builder: (context, expanded, _) {
                      return !expanded
                          ? HideUIOverlayTransition(
                              controller: _pageController,
                              child: widget.bottomSheet!,
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            Align(
              alignment: Alignment(
                0.9,
                getTopActionIconAlignValue(),
              ),
              child: UIOverlayVisibility(
                controller: _controller,
                pageController: _pageController,
                child: ValueListenableBuilder(
                  valueListenable: _pageController.expandedNotifier,
                  builder: (_, expanded, child) => ConditionalParentWidget(
                    condition: !expanded,
                    conditionalBuilder: (child) => HideUIOverlayTransition(
                      controller: _pageController,
                      slideDown: false,
                      child: child,
                    ),
                    child: child!,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: widget.topRightButtons,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment(
                -0.75,
                getTopActionIconAlignValue(),
              ),
              child: UIOverlayVisibility(
                controller: _controller,
                pageController: _pageController,
                child: ValueListenableBuilder(
                  valueListenable: _pageController.expandedNotifier,
                  builder: (_, expanded, child) => ConditionalParentWidget(
                    condition: !expanded,
                    conditionalBuilder: (child) => HideUIOverlayTransition(
                      controller: _pageController,
                      slideDown: false,
                      child: child,
                    ),
                    child: child!,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: _NavigationButtonBar(
                      onBack: () => _onBackButtonPressed(false),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class UIOverlayVisibility extends StatelessWidget {
  const UIOverlayVisibility({
    super.key,
    required this.pageController,
    required this.controller,
    required this.child,
  });

  final PostDetailsPageViewController pageController;
  final DetailsPageMobileController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.hideOverlay,
      builder: (_, hide, __) => hide ? const SizedBox.shrink() : child,
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
            fill: 1,
          ),
          onPressed: () => goToHomePage(context),
        ),
      ],
    );
  }
}

class HideUIOverlayTransition extends StatelessWidget {
  const HideUIOverlayTransition({
    super.key,
    required this.controller,
    required this.child,
    this.slideDown = true,
  });

  final bool slideDown;
  final PostDetailsPageViewController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.topDisplacement,
      builder: (_, topDis, child) => topDis > 0
          ? Transform.translate(
              offset: slideDown ? Offset(0, topDis) : Offset(0, -topDis),
              child: Opacity(
                opacity: 1.0 - (topDis / 100).clamp(0.0, 1.0),
                child: child,
              ),
            )
          : ValueListenableBuilder(
              valueListenable: controller.displacement,
              builder: (context, dis, _) => Transform.translate(
                offset:
                    slideDown ? Offset(0, dis * 0.5) : Offset(0, -dis * 0.5),
                child: child,
              ),
              child: child,
            ),
      child: child,
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
