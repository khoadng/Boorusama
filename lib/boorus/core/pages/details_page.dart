// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/pages/auto_slide_mixin.dart';
import 'package:boorusama/boorus/core/pages/swipe_down_to_dismiss_mixin.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme_mode.dart';
import 'package:boorusama/widgets/widgets.dart';

double getTopActionIconAlignValue() => hasStatusBar() ? -0.92 : -1;

class DetailsPageController extends ChangeNotifier {
  DetailsPageController({
    bool swipeDownToDismiss = true,
  }) : _enableSwipeDownToDismiss = swipeDownToDismiss;

  var _enableSwipeDownToDismiss = false;
  var _enablePageSwipe = true;
  final _slideShow = ValueNotifier((false, <int>[]));
  final _hideOverlay = ValueNotifier(false);

  bool get swipeDownToDismiss => _enableSwipeDownToDismiss;
  bool get pageSwipe => _enablePageSwipe;
  ValueNotifier<bool> get hideOverlay => _hideOverlay;
  ValueNotifier<(bool, List<int>)> get slideShow => _slideShow;

  void toggleSlideShow() {
    if (_slideShow.value.$1) {
      stopSlideShow();
    } else {
      startSlideShow();
    }
  }

  void startSlideShow({
    List<int>? skipIndexes,
  }) {
    _slideShow.value = (true, skipIndexes ?? <int>[]);
    disablePageSwipe();
    disableSwipeDownToDismiss();
    if (!_hideOverlay.value) setHideOverlay(true);
    notifyListeners();
  }

  void stopSlideShow() {
    _slideShow.value = (false, <int>[]);
    enablePageSwipe();
    enableSwipeDownToDismiss();
    setHideOverlay(false);

    notifyListeners();
  }

  void enableSwipeDownToDismiss() {
    _enableSwipeDownToDismiss = true;
    notifyListeners();
  }

  void disableSwipeDownToDismiss() {
    _enableSwipeDownToDismiss = false;
    notifyListeners();
  }

  void enablePageSwipe() {
    _enablePageSwipe = true;
    notifyListeners();
  }

  void disablePageSwipe() {
    _enablePageSwipe = false;
    notifyListeners();
  }

  // set overlay value
  void setHideOverlay(bool value) {
    _hideOverlay.value = value;
    notifyListeners();
  }

  // set enable swipe page
  void setEnablePageSwipe(bool value) {
    _enablePageSwipe = value;
    notifyListeners();
  }

  void toggleOverlay() {
    _hideOverlay.value = !_hideOverlay.value;
    notifyListeners();
  }
}

class DetailsPage<T> extends ConsumerStatefulWidget {
  const DetailsPage({
    Key? key,
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
  }) : super(key: key);

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
      extraSnapInsets: [
        ViewportInset.shrunk,
      ],
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

  double _navigationButtonGroupOffset = 0.0;
  double _topRightButtonGroupOffset = 0.0;
  var _keepBottomSheetDown = false;
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
    if (_keepBottomSheetDown) return;
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

    //TODO: opmitize this
    if (isSwipingDown.value) {
      setState(() {
        _navigationButtonGroupOffset =
            -dragDistance.value > 0 ? 0 : -dragDistance.value;
        _topRightButtonGroupOffset =
            -dragDistance.value > 0 ? 0 : -dragDistance.value;
      });
    }
  }

  void _handlePointerUp(PointerUpEvent event, bool expanded) {
    if (expanded || !_controller.pageSwipe || !_controller.swipeDownToDismiss) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      if (!controller.hasClients) return;
      if (controller.currentPage.value != widget.intitialIndex &&
          controller.page == widget.intitialIndex) {
        controller.jumpToPage(controller.currentPage.value);
      }
    });

    handlePointerUp(event);
  }

  Future<void> _onBackButtonPressed() async {
    _keepBottomSheetDown = true;
    Navigator.of(context).pop();
    widget.onExit(controller.currentPage.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return WillPopScope(
      onWillPop: () async {
        await _onBackButtonPressed();
        return false;
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
          floatingActionButton: ValueListenableBuilder<bool>(
            valueListenable: isExpanded,
            builder: (context, expanded, child) => expanded
                ? ValueListenableBuilder<ScrollNotification?>(
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
              _buildNavigationButtonGroup(theme, context),
              _buildTopRightButtonGroup(theme),
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
              builder: (context, shouldSlideDown, _) =>
                  ValueListenableBuilder<int>(
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
    return ValueListenableBuilder<int>(
      valueListenable: controller.currentPage,
      builder: (context, currentPage, _) => ValueListenableBuilder<bool>(
        valueListenable: isExpanded,
        builder: (context, expanded, _) {
          if (isSwipingDown.value && !expanded) {
            return ValueListenableBuilder<double>(
              valueListenable: dragDistance,
              builder: (context, dd, child) => ValueListenableBuilder<double>(
                valueListenable: dragDistanceX,
                builder: (context, ddx, child) => Transform.translate(
                  offset: Offset(ddx, dd),
                  child: Listener(
                    onPointerMove: (event) =>
                        _handlePointerMove(event, expanded),
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
          } else {
            return ValueListenableBuilder<double>(
              valueListenable: dragDistance,
              builder: (context, dd, child) => ValueListenableBuilder<double>(
                valueListenable: dragDistanceX,
                builder: (context, ddx, child) => Transform.translate(
                  offset: Offset(ddx, dd),
                  child: Listener(
                    onPointerMove: (event) =>
                        _handlePointerMove(event, expanded),
                    onPointerUp: (event) => _handlePointerUp(event, expanded),
                    child: ExprollablePageView(
                      controller: controller,
                      onViewportChanged: (metrics) {
                        if (metrics.isPageExpanded == isExpanded.value) return;

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
                        return ValueListenableBuilder<bool>(
                          valueListenable: isExpanded,
                          builder: (context, value, child) =>
                              widget.expandedBuilder(
                            context,
                            page,
                            currentPage,
                            value,
                            _pageSwipe,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildNavigationButtonGroup(ThemeMode theme, BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.hideOverlay,
      builder: (_, hide, __) => !hide
          ? Align(
              alignment: Alignment(
                -0.75,
                getTopActionIconAlignValue(),
              ),
              child: Transform.translate(
                offset: Offset(0, _navigationButtonGroupOffset),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      CircularIconButton(
                        icon: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: theme == ThemeMode.light
                              ? Icon(
                                  Icons.arrow_back_ios,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                )
                              : const Icon(Icons.arrow_back_ios),
                        ),
                        onPressed: () {
                          _onBackButtonPressed();
                        },
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      CircularIconButton(
                        icon: theme == ThemeMode.light
                            ? Icon(
                                Icons.home,
                                color: Theme.of(context).colorScheme.onPrimary,
                              )
                            : const Icon(Icons.home),
                        onPressed: () => goToHomePage(context),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildTopRightButtonGroup(ThemeMode theme) {
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.hideOverlay,
      builder: (_, hide, __) => !hide
          ? Align(
              alignment: Alignment(
                0.9,
                getTopActionIconAlignValue(),
              ),
              child: Transform.translate(
                offset: Offset(0, _topRightButtonGroupOffset),
                child: ValueListenableBuilder<int>(
                  valueListenable: controller.currentPage,
                  builder: (_, page, __) => ValueListenableBuilder<bool>(
                    valueListenable: isExpanded,
                    builder: (_, expanded, __) => ButtonBar(
                      children: [
                        ...widget.topRightButtonsBuilder(page, expanded),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
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
