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
    required this.enablePageSwipe,
    required this.hideOverlay,
    required this.onExit,
  }) : super(key: key);

  final void Function(int page)? onPageChanged;
  final int intitialIndex;
  final Widget Function(BuildContext context, int index) targetSwipeDownBuilder;
  final Widget Function(
          BuildContext context, int page, int currentPage, bool expanded)
      expandedBuilder;
  final int pageCount;
  final List<Widget> Function(int currentPage) topRightButtonsBuilder;
  final void Function(int currentPage)? onExpanded;
  final Widget? bottomSheet;
  final ValueNotifier<bool> enablePageSwipe;
  final ValueNotifier<bool> hideOverlay;
  final void Function(int index) onExit;

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

  @override
  Function() get popper => () => _onBackButtonPressed();

  double _navigationButtonGroupOffset = 0.0;
  double _topRightButtonGroupOffset = 0.0;
  late AnimationController _bottomSheetAnimationController;
  var _keepBottomSheetDown = false;

  @override
  void initState() {
    _bottomSheetAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    isSwipingDown.addListener(_updateShouldSlideDown);
    isExpanded.addListener(_updateShouldSlideDown);

    super.initState();
  }

  @override
  void didUpdateWidget(DetailsPage<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateShouldSlideDown();
  }

  void _updateShouldSlideDown() {
    if (_keepBottomSheetDown) return;
    _shouldSlideDownNotifier.value =
        isSwipingDown.value || isExpanded.value || widget.hideOverlay.value;
  }

  @override
  void dispose() {
    controller.dispose();
    _bottomSheetAnimationController.dispose();

    isSwipingDown.removeListener(_updateShouldSlideDown);
    isExpanded.removeListener(_updateShouldSlideDown);
    super.dispose();
  }

  void _handlePointerMove(PointerMoveEvent event, bool expanded) {
    if (expanded || _multiTouch || !widget.enablePageSwipe.value) {
      // Ignore the swipe down behavior when in expanded mode
      return;
    }

    handlePointerMove(event);

    if (isSwipingDown.value) {
      setState(() {
        _navigationButtonGroupOffset = -dragDistance > 0 ? 0 : -dragDistance;
        _topRightButtonGroupOffset = -dragDistance > 0 ? 0 : -dragDistance;
      });
    }
  }

  void _handlePointerUp(PointerUpEvent event, bool expanded) {
    if (expanded || _multiTouch || !widget.enablePageSwipe.value) {
      // Ignore the swipe down behavior when in expanded mode
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      if (!controller.hasClients) return;
      if (_currentPage != widget.intitialIndex &&
          controller.page == widget.intitialIndex) {
        controller.jumpToPage(_currentPage);
      }
    });

    handlePointerUp(event);
  }

  Future<void> _onBackButtonPressed() async {
    _keepBottomSheetDown = true;
    widget.onExit(_currentPage);
    Navigator.of(context).pop();
  }

  late var _currentPage = widget.intitialIndex;
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
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                      widget.onPageChanged?.call(page);
                    },
                    physics: widget.enablePageSwipe.value
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
    return Align(
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
                          color: Theme.of(context).colorScheme.onPrimary,
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
    );
  }

  Widget _buildTopRightButtonGroup() {
    return Align(
      alignment: Alignment(
        0.9,
        getTopActionIconAlignValue(),
      ),
      child: Transform.translate(
        offset: Offset(0, _topRightButtonGroupOffset),
        child: ButtonBar(
          children: widget.topRightButtonsBuilder(controller.currentPage.value),
        ),
      ),
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
                  child: widget.bottomSheet,
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
