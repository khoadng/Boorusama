// Dart imports:
// ignore_for_file: prefer_int_literals

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../foundation/display.dart';
import '../../../../foundation/mobile.dart';
import '../../../../foundation/platform.dart';
import '../../../widgets/widgets.dart';
import 'constants.dart';
import 'drag_sheet.dart';
import 'page_nav_button.dart';
import 'pointer_count_on_screen.dart';
import 'post_details_page_view_controller.dart';
import 'sheet_state_storage.dart';
import 'side_sheet.dart';

class PostDetailsPageView extends StatefulWidget {
  const PostDetailsPageView({
    required this.sheetBuilder,
    required this.itemCount,
    required this.itemBuilder,
    required this.checkIfLargeScreen,
    super.key,
    this.maxSize = 0.7,
    this.controller,
    this.onSwipeDownThresholdReached,
    this.onExit,
    this.onExpanded,
    this.onShrink,
    this.onPageChanged,
    this.swipeDownThreshold = 20,
    this.actions = const [],
    this.leftActions = const [],
    this.bottomSheet,
    this.sheetStateStorage,
    this.disableAnimation = false,
  });

  final Widget Function(BuildContext, ScrollController? scrollController)
  sheetBuilder;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double maxSize;
  final double swipeDownThreshold;

  final List<Widget> actions;
  final List<Widget> leftActions;
  final Widget? bottomSheet;

  final void Function()? onSwipeDownThresholdReached;
  final void Function()? onExit;
  final void Function()? onExpanded;
  final void Function()? onShrink;
  final void Function(int page)? onPageChanged;

  final PostDetailsPageViewController? controller;
  final SheetStateStorage? sheetStateStorage;

  final bool disableAnimation;
  final bool Function() checkIfLargeScreen;

  @override
  State<PostDetailsPageView> createState() => _PostDetailsPageViewState();
}

class _PostDetailsPageViewState extends State<PostDetailsPageView>
    with TickerProviderStateMixin {
  final _pointerCount = ValueNotifier(0);
  final _interacting = ValueNotifier(false);
  var _freestyleMoveStartOffset = Offset.zero;
  var _freestyleMoveScale = 1.0;

  late final PostDetailsPageViewController _controller;

  late final _overlayAnimController = !widget.disableAnimation
      ? AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 150),
        )
      : null;

  late final _overlayCurvedAnimation = _overlayAnimController != null
      ? CurvedAnimation(
          parent: _overlayAnimController,
          curve: Curves.easeOutCirc,
        )
      : null;

  late final _bottomInfoAnimController = !widget.disableAnimation
      ? AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 150),
        )
      : null;

  late final _bottomInfoCurvedAnimation = _bottomInfoAnimController != null
      ? CurvedAnimation(
          parent: _bottomInfoAnimController,
          curve: Curves.easeOutCirc,
        )
      : null;

  final _hovering = ValueNotifier(false);

  final _isSheetAnimating = ValueNotifier(false);

  late AnimationController _sheetAnimController;
  late Animation<double> _displacementAnim;
  late Animation<Offset> _sideSheetSlideAnim;

  bool get isLargeScreen => widget.checkIfLargeScreen();

  @override
  void initState() {
    super.initState();

    // Single animation controller to sync displacement and side sheet slide
    _sheetAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Animate the displacement box width
    _displacementAnim =
        Tween<double>(
          begin: 0.0,
          end: kSideSheetWidth,
        ).animate(
          CurvedAnimation(
            parent: _sheetAnimController,
            curve: Curves.easeInOut,
          ),
        );

    // Animate the side sheet’s position from offscreen to onscreen
    _sideSheetSlideAnim =
        Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _sheetAnimController,
            curve: Curves.easeInOut,
          ),
        );

    _controller =
        widget.controller ??
        PostDetailsPageViewController(
          initialPage: 0,
          checkIfLargeScreen: widget.checkIfLargeScreen,
          totalPage: widget.itemCount,
        );

    _controller.pageController.addListener(_onPageChanged);
    _controller.sheetController.addListener(_onSheetChanged);
    _controller.verticalPosition.addListener(_onVerticalPositionChanged);
    _controller.sheetState.addListener(_onSheetStateChanged);
    _controller
      ..attachOverlayAnimController(_overlayAnimController)
      ..attachBottomSheetAnimController(_bottomInfoAnimController);

    _isSheetAnimating.addListener(_onSheetAnimatingChanged);

    final currentExpanded = _controller.sheetState.value.isExpanded;

    // auto expand side sheet if it was expanded before
    if (isLargeScreen && !currentExpanded) {
      final expanded = widget.sheetStateStorage?.loadExpandedState();

      if (expanded == true) {
        _controller.sheetState.value = SheetState.expanded;
        // Set the controller value immediately to skip the opening animation
        _sheetAnimController.value = 1;
      }
    }

    if (_controller.initialHideOverlay) {
      Future.delayed(
        const Duration(milliseconds: 250),
        () {
          if (!mounted) return;
          hideSystemStatus();
        },
      );
    }
  }

  void _onPop() {
    if (kEnableHeroTransition && !widget.disableAnimation) {
      _controller.forceHideOverlay.value = true;
      _controller.forceHideBottomSheet.value = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.restoreSystemStatus();
      widget.onExit?.call();
    });
  }

  void _onHover(bool value) {
    _hovering.value = value;

    if (!_controller.hoverToControlOverlay.value) {
      return;
    }

    if (widget.disableAnimation) {
      return;
    }

    if (value) {
      _controller.showOverlay(
        includeSystemStatus: false,
      );
    } else {
      _controller.hideOverlay(
        includeSystemStatus: false,
      );
    }
  }

  void _onSheetAnimatingChanged() {
    // Only control overlay when in expanded state
    if (!_controller.sheetState.value.isExpanded) return;
  }

  void _onPageChanged() {
    final page = _controller.pageController.page;

    _controller.precisePage.value = page;

    final pageNum = page?.round();

    if (pageNum == null) return;

    if (pageNum != _controller.page) {
      _controller.currentPage.value = pageNum;

      _controller.sheetState.value = switch (_controller.sheetState.value) {
        SheetState.expanded => SheetState.expanded,
        SheetState.collapsed => SheetState.collapsed,
        SheetState.hidden => SheetState.collapsed,
      };

      widget.onPageChanged?.call(pageNum);

      // Hide UI elements when page changes
      if (_controller.initialHideOverlay && !isLargeScreen) {
        _controller.hideAllUI();
      }
    }
  }

  void _onVerticalPositionChanged() {
    if (_controller.animating.value || _controller.isExpanded) return;

    final dy = _controller.verticalPosition.value;

    if (dy > 0) return;

    final size = _controller.sheetController.pixelsToSize(dy.abs());

    _controller.sheetController.jumpTo(size);
  }

  void _onSheetChanged() {
    final size = _controller.sheetController.size;

    if (size > widget.maxSize) {
      return;
    }

    final dis = _clampToZero(_controller.sheetController.sizeToPixels(size));

    _controller.setDisplacement(dis);

    // Handle case when sheet is closed by dragging down, this is not handled by the controller
    if (dis <= 0 && _controller.isExpanded) {
      _controller.sheetState.value = SheetState.hidden;
    }

    if (dis <= 200 && _controller.isExpanded) {
      if (!_controller.previouslyForcedShowUIByDrag) {
        // Delay to next frame to wait for the sheet state to change before showing the overlay
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.showBottomSheet();
        });
      } else {
        // UI was previously forced to show by drag, so we don't want to show it again here
      }
    }
  }

  void _onSheetStateChanged() {
    if (_controller.isExpanded) {
      widget.onExpanded?.call();
    } else {
      if (_controller.sheetState.value == SheetState.hidden) {
        widget.onShrink?.call();
      }

      // Hide UI elements when sheet is collapsed if it was previously forced to show by drag
      if (_controller.previouslyForcedShowUIByDrag) {
        _controller
          ..hideOverlay()
          ..previouslyForcedShowUIByDrag = false;
      }
    }

    if (isLargeScreen) {
      widget.sheetStateStorage?.persistExpandedState(_controller.isExpanded);
    }

    // sync the side sheet slide animation with the sheet state
    _sheetAnimController.value = _controller.isExpanded ? 1 : 0;
  }

  @override
  void dispose() {
    _controller.sheetState.removeListener(_onSheetStateChanged);
    _controller.pageController.removeListener(_onPageChanged);
    _controller.sheetController.removeListener(_onSheetChanged);

    _controller
      ..detachOverlayAnimController()
      ..detachBottomSheetAnimController();

    _isSheetAnimating.removeListener(_onSheetAnimatingChanged);

    _hovering.dispose();
    _pointerCount.dispose();
    _interacting.dispose();
    _isSheetAnimating.dispose();

    _overlayCurvedAnimation?.dispose();
    _overlayAnimController?.dispose();
    _sheetAnimController.dispose();
    _bottomInfoAnimController?.dispose();
    _bottomInfoCurvedAnimation?.dispose();

    if (widget.controller == null) {
      _controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          _controller.nextPage(
            duration: isLargeScreen ? Duration.zero : null,
          );
        },
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
          _controller.previousPage(
            duration: isLargeScreen ? Duration.zero : null,
          );
        },
        const SingleActivator(LogicalKeyboardKey.keyO): () =>
            _controller.toggleOverlay(),
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).maybePop(),
      },
      child: Focus(
        autofocus: true,
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: _controller.slideshow,
                    builder: (context, slideshow, child) => GestureDetector(
                      behavior: slideshow ? HitTestBehavior.opaque : null,
                      onTap: () => _controller.stopSlideshow(),
                      child: IgnorePointer(
                        ignoring: slideshow,
                        child: child,
                      ),
                    ),
                    child: MouseRegion(
                      onEnter: (_) => _onHover(true),
                      onExit: (_) => _onHover(false),
                      child: _buildMain(),
                    ),
                  ),
                ),
                if (!isLargeScreen)
                  const SizedBox.shrink()
                else if (!widget.disableAnimation)
                  AnimatedBuilder(
                    animation: _displacementAnim,
                    builder: (context, child) {
                      return SizedBox(width: _displacementAnim.value);
                    },
                  )
                else
                  _buildSideSheet(),
                ValueListenableBuilder(
                  valueListenable: _controller.sheetState,
                  builder: (_, state, _) => PopScope(
                    canPop: switch (isLargeScreen) {
                      true => true,
                      false => !state.isExpanded,
                    },
                    onPopInvokedWithResult: (didPop, _) {
                      if (didPop) {
                        _onPop();
                      } else {
                        if (_controller.isExpanded) {
                          _controller.resetSheet();
                          return;
                        }
                      }
                    },
                    child: const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
            if (isLargeScreen && !widget.disableAnimation)
              Align(
                alignment: Alignment.centerRight,
                child: SlideTransition(
                  position: _sideSheetSlideAnim,
                  child: _buildSideSheet(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideSheet() {
    return ValueListenableBuilder(
      valueListenable: _controller.forceHideOverlay,
      builder: (_, hide, child) => hide ? const SizedBox.shrink() : child!,
      child: SideSheet(
        controller: _controller,
        sheetBuilder: widget.sheetBuilder,
        animationController: _sheetAnimController,
      ),
    );
  }

  Widget _buildMain() {
    final bottomSheet = widget.bottomSheet;

    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _interacting,
                  builder: (_, interacting, _) => ValueListenableBuilder(
                    valueListenable: _controller.swipe,
                    builder: (_, swipe, _) => _buildPageView(
                      swipe,
                      interacting,
                    ),
                  ),
                ),
              ),
              _buildBottomDisplacement(),
            ],
          ),
        ),
        if (bottomSheet != null && !isLargeScreen)
          Align(
            alignment: Alignment.bottomCenter,
            child: ValueListenableBuilder(
              valueListenable: _controller.forceHideBottomSheet,
              builder: (_, hide, _) => hide
                  ? const SizedBox.shrink()
                  : _bottomInfoAnimController != null
                  ? SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(_bottomInfoAnimController),
                      child: ColoredBox(
                        color: Theme.of(context).colorScheme.surface,
                        child: FadeTransition(
                          opacity:
                              Tween(
                                begin: 0.0,
                                end: 1.0,
                              ).animate(
                                CurvedAnimation(
                                  parent: _bottomInfoAnimController,
                                  curve: Curves.easeInCubic,
                                ),
                              ),
                          child: bottomSheet,
                        ),
                      ),
                    )
                  : bottomSheet,
            ),
          ),
        Align(
          alignment: Alignment.bottomCenter,
          child: !isLargeScreen
              ? DragSheet(
                  sheetBuilder: widget.sheetBuilder,
                  pageViewController: _controller,
                  isSheetAnimating: _isSheetAnimating,
                )
              : const SizedBox.shrink(),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Builder(
            builder: (context) {
              final overlay = ValueListenableBuilder(
                valueListenable: _controller.sheetState,
                builder: (_, state, _) => ConditionalParentWidget(
                  condition: !state.isExpanded,
                  conditionalBuilder: (child) => ValueListenableBuilder(
                    valueListenable: _controller.freestyleMoving,
                    builder: (context, moving, _) => child,
                  ),
                  child: SafeArea(
                    right: isLargeScreen,
                    child: _buildOverlay(),
                  ),
                ),
              );

              return ValueListenableBuilder(
                valueListenable: _controller.forceHideOverlay,
                builder: (_, hide, _) => hide
                    ? const SizedBox.shrink()
                    : _overlayCurvedAnimation != null
                    ? SlideTransition(
                        position: Tween(
                          begin: const Offset(0, -1),
                          end: Offset.zero,
                        ).animate(_overlayCurvedAnimation),
                        child: overlay,
                      )
                    : overlay,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOverlay() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: OverflowBar(
              children: [
                CircularIconButton(
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Symbols.arrow_back_ios,
                    ),
                  ),
                  onPressed: Navigator.of(context).maybePop,
                ),
                const SizedBox(
                  width: 4,
                ),
                ...widget.leftActions,
              ],
            ),
          ),
          Flexible(
            child: OverflowBar(
              children: [
                ...widget.actions,
                const SizedBox(width: 8),
                if (!isLargeScreen)
                  const SizedBox.shrink()
                else
                  CircularIconButton(
                    onPressed: () {
                      _controller.toggleExpanded(
                        MediaQuery.sizeOf(context).longestSide,
                        () async {
                          if (!widget.disableAnimation) {
                            // if animation is running, ignore
                            if (_sheetAnimController.isAnimating) return;

                            if (_controller.isExpanded) {
                              await _sheetAnimController.reverse();
                            } else {
                              await _sheetAnimController.forward();
                            }
                          }
                        },
                      );
                    },
                    icon: const Icon(Symbols.info),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomDisplacement() {
    return !isLargeScreen
        ? ValueListenableBuilder(
            valueListenable: _controller.sheetMaxSize,
            builder: (_, maxSize, _) => ValueListenableBuilder(
              valueListenable: _controller.sheetState,
              builder: (_, state, _) => ValueListenableBuilder(
                valueListenable: _controller.displacement,
                builder: (context, dis, child) {
                  final maxSheetSize =
                      maxSize * MediaQuery.sizeOf(context).longestSide;

                  return state.isExpanded &&
                          dis >
                              maxSheetSize -
                                  0.01 // 0.01 is for rounding error e.g: 419.99999999999
                      ? SizedBox(
                          height: maxSheetSize,
                        )
                      : ValueListenableBuilder(
                          valueListenable: _pointerCount,
                          builder: (_, count, _) => SizedBox(
                            height: dis,
                          ),
                        );
                },
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildPageView(
    bool swipe,
    bool interacting,
  ) {
    final isPortrait = !context.isLargeScreen;

    return ValueListenableBuilder(
      valueListenable: _controller.sheetState,
      builder: (_, state, _) {
        final blockSwipe = !swipe || state.isExpanded || interacting;

        return PageView.builder(
          onPageChanged: blockSwipe && !isPortrait
              ? (_) => _controller.startCooldownTimer()
              : null,
          controller: _controller.pageController,
          physics: blockSwipe
              ? const NeverScrollableScrollPhysics()
              : const DefaultPageViewScrollPhysics(),
          itemCount: widget.itemCount,
          itemBuilder: (context, index) => _buildItem(index, blockSwipe),
        );
      },
    );
  }

  final _dummyAlwaysFalse = ValueNotifier(false);

  Widget _buildItem(int index, bool blockSwipe) {
    List<Widget> buildNavButtons() {
      return [
        PageNavButton(
          alignment: Alignment.centerRight,
          controller: _controller,
          visibleWhen: (page) => page < widget.itemCount - 1,
          icon: const Icon(Symbols.arrow_forward),
          onPressed: () => _controller.nextPage(duration: Duration.zero),
        ),
        PageNavButton(
          alignment: Alignment.centerLeft,
          controller: _controller,
          visibleWhen: (page) => page > 0,
          icon: const Icon(Symbols.arrow_back),
          onPressed: () => _controller.previousPage(duration: Duration.zero),
        ),
      ];
    }

    final isSmall = !isLargeScreen;

    return Stack(
      children: [
        Positioned.fill(
          child: ValueListenableBuilder(
            valueListenable: !isSmall ? _dummyAlwaysFalse : _controller.canPull,
            builder: (_, canPull, _) => PointerCountOnScreen(
              enable: isSmall,
              onCountChanged: (count) {
                _pointerCount.value = count;
                _interacting.value = count > 1;
              },
              child: ValueListenableBuilder(
                valueListenable: !isSmall
                    ? _dummyAlwaysFalse
                    : _controller.pulling,
                builder: (_, pulling, _) => GestureDetector(
                  onVerticalDragStart: canPull && !_interacting.value
                      ? _onVerticalDragStart
                      : null,
                  onVerticalDragUpdate: pulling ? _onVerticalDragUpdate : null,
                  onVerticalDragEnd: pulling ? _onVerticalDragEnd : null,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _controller.freestyleMoveOffset,
                      _controller.sheetState,
                    ]),
                    builder: (context, childAb) => Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..translate(
                          _controller.freestyleMoveOffset.value.dx,
                          _controller.freestyleMoveOffset.value.dy,
                        )
                        ..scale(_freestyleMoveScale),
                      child: childAb,
                    ),
                    child: widget.itemBuilder(context, index),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (isDesktopPlatform())
          ...buildNavButtons()
        else if (!isSmall)
          if (blockSwipe) ...buildNavButtons(),
      ],
    );
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _controller.pulling.value = true;

    if (!_controller.isExpanded) {
      _freestyleMoveStartOffset = details.globalPosition;
      _freestyleMoveScale = 1.0;
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    _controller.dragUpdate(details);

    if (_controller.freestyleMoving.value) {
      if (_controller.verticalPosition.value <= 0) return;

      // Calculate scale first
      final movePercent =
          details.globalPosition.dy - _freestyleMoveStartOffset.dy;
      final normalizedPercent = movePercent / widget.swipeDownThreshold;
      _freestyleMoveScale =
          1.0 -
          (normalizedPercent * _kSwipeDownScaleFactor).clamp(
            0.0,
            _kSwipeDownScaleFactor,
          );

      // Adjust translation based on scale
      final scaledOffset = details.globalPosition - _freestyleMoveStartOffset;
      // Apply scale compensation to keep the image centered
      final scaleCompensation =
          (1 - _freestyleMoveScale) *
          (_freestyleMoveStartOffset.dy - details.globalPosition.dy) /
          2;

      _controller.freestyleMoveOffset.value = Offset(
        scaledOffset.dx,
        scaledOffset.dy + scaleCompensation,
      );
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _controller.pulling.value = false;

    // Check if drag distance exceeds threshold for dismissal
    if (_controller.freestyleMoveOffset.value.dy.abs() >
        widget.swipeDownThreshold) {
      if (widget.onSwipeDownThresholdReached != null) {
        widget.onSwipeDownThresholdReached?.call();
      } else {
        Navigator.of(context).maybePop();
        return;
      }
      // scale back to 1.0
      _freestyleMoveScale = 1.0;
    } else {
      // Animate back to original position
      _animateBackToPosition();
      _freestyleMoveScale = 1.0;
    }

    _controller.freestyleMoveOffset.value = Offset.zero;

    _controller.dragEnd();
  }

  void _animateBackToPosition() {
    final startOffset = _controller.freestyleMoveOffset.value;

    final animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    final animation =
        Tween(
          begin: startOffset,
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animController,
            curve: Curves.easeOut,
          ),
        );

    animation.addListener(() {
      if (mounted) {
        _controller.freestyleMoveOffset.value = animation.value;
      }
    });

    // Start animation
    animController.forward().then((_) {
      animController.dispose();
    });
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
    mass: 1,
    stiffness: 400,
    damping: 40,
  );
}

const _kSwipeDownScaleFactor = 0.2;

double _clampToZero(
  double value, {
  double threshold = 0.01,
}) {
  if (value.isNaN) return 0.0;
  return value.abs() < threshold ? 0.0 : value;
}

enum SheetState {
  /// When the sheet is completely expanded
  expanded,

  /// When the sheet haven't expanded yet
  collapsed,

  /// When the sheet has exanded once and then collapsed
  hidden,
}

extension SheetExpansionStateX on SheetState {
  bool get isExpanded => this == SheetState.expanded;
}
