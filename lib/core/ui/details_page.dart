// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/platform.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/circular_icon_button.dart';
import 'package:boorusama/core/ui/swipe_down_to_dismiss_mixin.dart';
import 'package:boorusama/core/ui/touch_count_recognizer.dart';

double getTopActionIconAlignValue() => hasStatusBar() ? -0.92 : -1;

class DetailsPageController extends ChangeNotifier {
  DetailsPageController({
    bool swipeDownToDismiss = true,
  }) : _enableSwipeDownToDismiss = swipeDownToDismiss;

  var _enableSwipeDownToDismiss = false;
  var _enablePageSwipe = true;
  final _hideOverlay = ValueNotifier(false);

  bool get swipeDownToDismiss => _enableSwipeDownToDismiss;
  bool get pageSwipe => _enablePageSwipe;
  ValueNotifier<bool> get hideOverlay => _hideOverlay;

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
  void setOverlay(bool value) {
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

class DetailsPage<T> extends StatefulWidget {
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
  final List<Widget> Function(int currentPage) topRightButtonsBuilder;
  final void Function(int currentPage)? onExpanded;
  final Widget? Function(int currentPage)? bottomSheet;
  final void Function(int index) onExit;
  final DetailsPageController? controller;

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState<T> extends State<DetailsPage<T>>
    with TickerProviderStateMixin, SwipeDownToDismissMixin<DetailsPage<T>> {
  late final controller = ExprollablePageController(
    initialPage: widget.intitialIndex,
    maxViewportOffset: ViewportOffset.shrunk,
    minViewportFraction: 0.999,
    snapViewportOffsets: [
      ViewportOffset.shrunk,
    ],
  );
  var isExpanded = ValueNotifier(false);
  late final _shouldSlideDownNotifier = ValueNotifier(false);

  //details page contorller
  late final _controller = widget.controller ?? DetailsPageController();

  @override
  Function() get popper => () => _onBackButtonPressed();

  double _navigationButtonGroupOffset = 0.0;
  double _topRightButtonGroupOffset = 0.0;
  late AnimationController _bottomSheetAnimationController;
  var _keepBottomSheetDown = false;
  var _pageSwipe = true;

  @override
  void initState() {
    _bottomSheetAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

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
    _bottomSheetAnimationController.dispose();

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
        _multiTouch) return;

    handlePointerMove(event);

    if (isSwipingDown.value) {
      setState(() {
        _navigationButtonGroupOffset = -dragDistance > 0 ? 0 : -dragDistance;
        _topRightButtonGroupOffset = -dragDistance > 0 ? 0 : -dragDistance;
      });
    }
  }

  void _handlePointerUp(PointerUpEvent event, bool expanded) {
    if (expanded ||
        _multiTouch ||
        !_controller.pageSwipe ||
        !_controller.swipeDownToDismiss) return;

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

  var _multiTouch = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

    return WillPopScope(
      onWillPop: () async {
        await _onBackButtonPressed();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(calculateBackgroundOpacity()),
        body: Stack(
          children: [
            _buildScrollContent(),
            _buildNavigationButtonGroup(theme, context),
            _buildTopRightButtonGroup(),
            _buildBottomSheet(),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollContent() {
    return ValueListenableBuilder<int>(
      valueListenable: controller.currentPage,
      builder: (context, currentPage, _) => ValueListenableBuilder<bool>(
        valueListenable: isExpanded,
        builder: (context, expanded, _) {
          if (isSwipingDown.value && !expanded) {
            return Transform.translate(
              offset: Offset(dragDistanceX, dragDistance),
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
            );
          } else {
            return Transform.translate(
              offset: Offset(dragDistanceX, dragDistance),
              child: RawGestureDetector(
                gestures: <Type, GestureRecognizerFactory>{
                  TouchCountRecognizer: GestureRecognizerFactoryWithHandlers<
                      TouchCountRecognizer>(
                    () => TouchCountRecognizer((multiTouch) {
                      setState(() {
                        _multiTouch = multiTouch;
                      });
                    }),
                    (TouchCountRecognizer instance) {},
                  ),
                },
                child: Listener(
                  onPointerMove: (event) => _handlePointerMove(event, expanded),
                  onPointerUp: (event) => _handlePointerUp(event, expanded),
                  child: ExprollablePageView(
                    controller: controller,
                    onViewportChanged: (metrics) {
                      isExpanded.value = metrics.isExpanded;
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

  Widget _buildTopRightButtonGroup() {
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
                child: ButtonBar(
                  children: widget
                      .topRightButtonsBuilder(controller.currentPage.value),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildBottomSheet() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: widget.bottomSheet != null
          ? ValueListenableBuilder<bool>(
              valueListenable: _shouldSlideDownNotifier,
              builder: (context, shouldSlideDown, _) {
                // If shouldSlideDown is true, slide down the bottom sheet, otherwise slide it up.
                final targetOffset =
                    shouldSlideDown ? const Offset(0, 1) : const Offset(0, 0);

                // Animate the bottom sheet to the target position.
                _bottomSheetAnimationController.animateTo(
                  shouldSlideDown ? 0 : 1,
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeInOut,
                );

                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: targetOffset,
                  ).animate(
                    CurvedAnimation(
                      parent: _bottomSheetAnimationController,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: ValueListenableBuilder<int>(
                    valueListenable: controller.currentPage,
                    builder: (context, page, child) =>
                        widget.bottomSheet?.call(page) ??
                        const SizedBox.shrink(),
                  ),
                );
              },
            )
          : const SizedBox.shrink(),
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
