// Dart imports:
// ignore_for_file: prefer_int_literals

// Dart imports:
import 'dart:async';
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../foundation/display.dart';
import '../../../foundation/mobile.dart';
import '../../../settings/settings.dart';
import '../../../widgets/widgets.dart';
import '../../details/src/widgets/auto_slide_mixin.dart';
import 'constants.dart';
import 'page_nav_button.dart';
import 'pointer_count_on_screen.dart';
import 'post_details_page_view_controller.dart';
import 'sheet_dragline.dart';
import 'sheet_state_storage.dart';
import 'side_sheet.dart';
import 'slide_details_container.dart';

class PostDetailsPageView extends StatefulWidget {
  const PostDetailsPageView({
    required this.sheetBuilder,
    required this.itemCount,
    required this.itemBuilder,
    required this.checkIfLargeScreen,
    super.key,
    this.minSize = 0.18,
    this.maxSize = 0.7,
    this.controller,
    this.onSwipeDownThresholdReached,
    this.onItemDoubleTap,
    this.onItemLongPress,
    this.onExit,
    this.onExpanded,
    this.onShrink,
    this.onTap,
    this.onPageChanged,
    this.swipeDownThreshold = 20,
    this.actions = const [],
    this.leftActions = const [],
    this.bottomSheet,
    this.slideshowOptions = const SlideshowOptions(),
    this.sheetStateStorage,
    this.disableAnimation = false,
  });

  final Widget Function(BuildContext, ScrollController? scrollController)
      sheetBuilder;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double minSize;
  final double maxSize;
  final double swipeDownThreshold;

  final List<Widget> actions;
  final List<Widget> leftActions;
  final Widget? bottomSheet;

  final void Function()? onSwipeDownThresholdReached;
  final void Function()? onItemDoubleTap;
  final void Function()? onItemLongPress;
  final void Function()? onExit;
  final void Function()? onExpanded;
  final void Function()? onShrink;
  final void Function()? onTap;
  final void Function(int page)? onPageChanged;

  final SlideshowOptions slideshowOptions;

  final PostDetailsPageViewController? controller;
  final SheetStateStorage? sheetStateStorage;

  final bool disableAnimation;
  final bool Function() checkIfLargeScreen;

  @override
  State<PostDetailsPageView> createState() => _PostDetailsPageViewState();
}

class _PostDetailsPageViewState extends State<PostDetailsPageView>
    with AutomaticSlideMixin, TickerProviderStateMixin {
  ValueNotifier<bool> get _swipe => _controller.swipe;
  ValueNotifier<double> get _verticalPosition => _controller.verticalPosition;
  ValueNotifier<double> get _displacement => _controller.displacement;
  final _pointerCount = ValueNotifier(0);
  final _interacting = ValueNotifier(false);
  late var _slideshowOptions = widget.slideshowOptions;
  var _freestyleMoveStartOffset = Offset.zero;
  var _freestyleMoveScale = 1.0;

  late final PostDetailsPageViewController _controller;

  DraggableScrollableController get _sheetController =>
      _controller.sheetController;

  late final _animationController = !widget.disableAnimation
      ? AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 150),
        )
      : null;

  late final _curvedAnimation = !widget.disableAnimation
      ? CurvedAnimation(
          parent: _animationController!,
          curve: Curves.easeOutCirc,
        )
      : null;

  @override
  PageController get pageController => _controller.pageController;

  // Use for large screen when details is on the side to prevent spamming
  Timer? _debounceTimer;
  final _cooldown = ValueNotifier(false);
  final hovering = ValueNotifier(false);

  late AnimationController _sheetAnimController;
  late Animation<double> _displacementAnim;
  late Animation<Offset> _sideSheetSlideAnim;

  final _forceHide = ValueNotifier(false);

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
    _displacementAnim = Tween<double>(
      begin: 0.0,
      end: kSideSheetWidth,
    ).animate(
      CurvedAnimation(parent: _sheetAnimController, curve: Curves.easeInOut),
    );

    // Animate the side sheet’s position from offscreen to onscreen
    _sideSheetSlideAnim = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _sheetAnimController, curve: Curves.easeInOut),
    );

    hovering.addListener(_onHover);

    _controller =
        widget.controller ?? PostDetailsPageViewController(initialPage: 0);

    _controller.pageController.addListener(_onPageChanged);
    _sheetController.addListener(_onSheetChanged);
    _controller.verticalPosition.addListener(_onVerticalPositionChanged);
    _controller.slideshow.addListener(_onSlideShowChanged);
    _controller.sheetState.addListener(_onSheetStateChanged);
    _controller.overlay.addListener(_onOverlayChanged);

    _verticalSheetDragY.addListener(_onVerticalSheetDragYChanged);

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

    if (widget.controller?.overlay.value ?? true) {
      if (!widget.disableAnimation) {
        Future.delayed(
          const Duration(milliseconds: 150),
          () {
            if (!mounted) return;
            _animationController?.forward();
          },
        );
      } else {
        _forceHide.value = false;
      }
    } else {
      if (!widget.disableAnimation) {
        _animationController?.reverse();
      } else {
        _forceHide.value = true;
      }
    }
  }

  void _onPop() {
    if (!widget.disableAnimation) {
      _controller.freestyleMoving.value = true;
    }

    _forceHide.value = true;

    _controller.restoreSystemStatus();
    widget.onExit?.call();
  }

  void _onHover() {
    if (!_controller.hoverToControlOverlay.value) {
      return;
    }

    if (hovering.value) {
      _controller.overlay.value = true;
    } else {
      _controller.overlay.value = false;
    }
  }

  void _onOverlayChanged() {
    if (_controller.overlay.value) {
      if (!widget.disableAnimation) {
        _animationController?.forward();
      } else {
        _forceHide.value = false;
      }

      showSystemStatus();
    } else {
      if (!widget.disableAnimation) {
        _animationController?.reverse();
      } else {
        _forceHide.value = true;
      }

      hideSystemStatus();
    }
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
    }
  }

  void _onVerticalPositionChanged() {
    if (_controller.animating.value || _controller.isExpanded) return;

    final dy = _controller.verticalPosition.value;

    if (dy > 0) {
      return;
    }

    final size = min(dy.abs(), _controller.threshold) / _controller.threshold;

    _sheetController.jumpTo(size);
  }

  void _onSheetChanged() {
    final size = _sheetController.size;

    if (size > widget.maxSize) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    final screenHeight = MediaQuery.sizeOf(context).height;
    final dis = size * screenHeight;

    _controller.displacement.value = _clampToZero(dis);
  }

  void _onSheetStateChanged() {
    if (_controller.isExpanded) {
      widget.onExpanded?.call();
      showSystemStatus();
      _controller.overlay.value = true;
    } else {
      if (_controller.sheetState.value == SheetState.hidden) {
        widget.onShrink?.call();
      }
    }

    if (isLargeScreen) {
      widget.sheetStateStorage?.persistExpandedState(_controller.isExpanded);
    }

    // sync the side sheet slide animation with the sheet state
    _sheetAnimController.value = _controller.isExpanded ? 1 : 0;
  }

  Future<void> _onSlideShowChanged() async {
    final slideShow = _controller.slideshow.value;

    if (slideShow) {
      // if in expanded mode, exit expanded mode first
      if (_controller.isExpanded) {
        if (!isLargeScreen) {
          await _controller.resetSheet();
        } else {
          _controller.sheetState.value = SheetState.hidden;
        }
      }

      startAutoSlide(
        _controller.page,
        widget.itemCount,
        skipAnimation: _slideshowOptions.skipTransition,
        direction: switch (_slideshowOptions.direction) {
          SlideshowDirection.forward => SlideDirection.forward,
          SlideshowDirection.backward => SlideDirection.backward,
          SlideshowDirection.random => SlideDirection.random,
        },
        duration: _slideshowOptions.duration,
      );
    } else {
      stopAutoSlide();
    }
  }

  void _onVerticalSheetDragYChanged() {
    final delta = _verticalSheetDragY.value;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final percentage = delta / screenHeight;

    final size =
        (_verticalSheetDragStartSize - percentage).clamp(0.4, kFullSheetSize);

    _sheetController.jumpTo(size);
  }

  @override
  void dispose() {
    _cancelCooldown();

    _controller.sheetState.removeListener(_onSheetStateChanged);
    _controller.pageController.removeListener(_onPageChanged);
    _controller.slideshow.removeListener(_onSlideShowChanged);
    _controller.verticalPosition.removeListener(_onVerticalPositionChanged);
    _controller.sheetController.removeListener(_onSheetChanged);

    _verticalSheetDragY.removeListener(_onVerticalSheetDragYChanged);
    hovering.removeListener(_onHover);

    _animationController?.dispose();

    stopAutoSlide();

    if (widget.controller == null) {
      _controller.dispose();
    }

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PostDetailsPageView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.slideshowOptions != oldWidget.slideshowOptions) {
      _slideshowOptions = widget.slideshowOptions;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          if (_cooldown.value) return;

          _controller.nextPage(
            duration: isLargeScreen ? Duration.zero : null,
          );
        },
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
          if (_cooldown.value) return;

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
                      onEnter: (_) => hovering.value = true,
                      onExit: (_) => hovering.value = false,
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
                  builder: (_, state, __) => PopScope(
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
      valueListenable: _forceHide,
      builder: (_, hide, child) => hide ? const SizedBox.shrink() : child!,
      child: SideSheet(
        controller: _controller,
        sheetBuilder: widget.sheetBuilder,
        animationController: _sheetAnimController,
      ),
    );
  }

  Widget _buildMain() {
    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _interacting,
                  builder: (_, interacting, __) => ValueListenableBuilder(
                    valueListenable: _swipe,
                    builder: (_, swipe, __) => _buildPageView(
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
        Align(
          alignment: Alignment.bottomCenter,
          child: !isLargeScreen
              ? ValueListenableBuilder(
                  valueListenable: _controller.sheetState,
                  builder: (_, state, __) => state.isExpanded
                      // If expanded, show the drag sheet
                      ? _buildDragSheet(
                          forceInitialSizeAsMax: true,
                          sheetState: state,
                        )
                      // If not expanded, hide it and let the user pull it up
                      : _buildDragSheet(
                          sheetState: state,
                        ),
                )
              : const SizedBox.shrink(),
        ),
        if (widget.bottomSheet != null)
          Align(
            alignment: Alignment.bottomCenter,
            child: Builder(
              builder: (context) {
                final sheet = _buildBottomSheet();

                return ValueListenableBuilder(
                  valueListenable: _forceHide,
                  builder: (__, hide, _) => hide
                      ? const SizedBox.shrink()
                      : _curvedAnimation != null
                          ? SlideTransition(
                              position: Tween(
                                begin: const Offset(0, 1),
                                end: Offset.zero,
                              ).animate(_curvedAnimation),
                              child: sheet,
                            )
                          : sheet,
                );
              },
            ),
          ),
        Align(
          alignment: Alignment.topCenter,
          child: Builder(
            builder: (context) {
              final overlay = ValueListenableBuilder(
                valueListenable: _controller.sheetState,
                builder: (_, state, __) => ConditionalParentWidget(
                  condition: !state.isExpanded,
                  conditionalBuilder: (child) => ValueListenableBuilder(
                    valueListenable: _controller.freestyleMoving,
                    builder: (context, moving, child) => SlideDetailsContainer(
                      shouldSlide: moving,
                      direction: SlideContainerDirection.up,
                      child: child!,
                    ),
                    child: child,
                  ),
                  child: SafeArea(
                    right: isLargeScreen,
                    child: _buildOverlay(),
                  ),
                ),
              );

              return ValueListenableBuilder(
                valueListenable: _forceHide,
                builder: (_, hide, __) => hide
                    ? const SizedBox.shrink()
                    : _curvedAnimation != null
                        ? SlideTransition(
                            position: Tween(
                              begin: const Offset(0, -1),
                              end: Offset.zero,
                            ).animate(_curvedAnimation),
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

  Widget _buildBottomSheet() {
    return ValueListenableBuilder(
      valueListenable: _controller.sheetState,
      builder: (_, state, __) => isLargeScreen
          ? const SizedBox.shrink()
          : ValueListenableBuilder(
              valueListenable: _controller.freestyleMoving,
              builder: (context, moving, child) => SlideDetailsContainer(
                shouldSlide: switch (moving) {
                  true => true,
                  false => state.isExpanded,
                },
                direction: SlideContainerDirection.down,
                child: ValueListenableBuilder(
                  valueListenable: _controller.displacement,
                  builder: (_, dis, __) {
                    return switch (moving) {
                      true => widget.bottomSheet!,
                      false =>
                        dis > 0 ? const SizedBox.shrink() : widget.bottomSheet!,
                    };
                    // return !moving ? widget.bottomSheet!;
                  },
                ),
              ),
            ),
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
                        context,
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
            builder: (_, maxSize, __) => ValueListenableBuilder(
              valueListenable: _controller.sheetState,
              builder: (_, state, __) => ValueListenableBuilder(
                valueListenable: _displacement,
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
                          builder: (_, count, __) => SizedBox(
                            height: dis,
                          ),
                        );
                },
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildDragSheet({
    required SheetState sheetState,
    bool? forceInitialSizeAsMax,
  }) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (_controller.isExpanded) {
          if (notification is ScrollEndNotification) {
            if (_sheetController.size < 0.6) {
              _controller.resetSheet();
            }
          }
        }

        return false;
      },
      child: ValueListenableBuilder(
        valueListenable: _controller.sheetMaxSize,
        builder: (_, maxSize, __) => DraggableScrollableSheet(
          controller: _sheetController,
          initialChildSize: forceInitialSizeAsMax == true ? maxSize : 0.0,
          minChildSize: 0,
          maxChildSize: maxSize,
          shouldCloseOnMinExtent: false,
          snap: true,
          snapAnimationDuration: const Duration(milliseconds: 200),
          builder: (context, scrollController) => Scaffold(
            floatingActionButton: ScrollToTop(
              scrollController: scrollController,
              child: BooruScrollToTopButton(
                onPressed: () {
                  if (mounted) {
                    scrollController.jumpTo(0);
                  }
                },
              ),
            ),
            body: Stack(
              children: [
                Positioned.fill(
                  child: widget.sheetBuilder(context, scrollController),
                ),
                const Divider(
                  height: 0,
                  thickness: 0.75,
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: ValueListenableBuilder(
                    valueListenable: _controller.sheetState,
                    builder: (context, state, _) => state ==
                            SheetState.collapsed
                        ? const SizedBox.shrink()
                        : GestureDetector(
                            onVerticalDragStart: (details) {
                              _controller.sheetMaxSize.value = kFullSheetSize;
                              _verticalSheetDragStartY =
                                  details.globalPosition.dy;
                              _verticalSheetDragStartSize =
                                  _sheetController.size;
                              _verticalSheetDragging.value = true;
                            },
                            onVerticalDragUpdate: state.isExpanded
                                ? (details) {
                                    _verticalSheetDragY.value =
                                        details.globalPosition.dy -
                                            _verticalSheetDragStartY;
                                  }
                                : null,
                            onVerticalDragEnd: state.isExpanded
                                ? (_) {
                                    final currentSize = _sheetController.size;

                                    if (currentSize < widget.maxSize) {
                                      // Collapse if below maxSize
                                      _controller.resetSheet();
                                    } else {
                                      // not sure why this is needed, but it is required to force the sheet to expand
                                      setState(() {
                                        // Expand if above maxSize
                                        _controller.expandToFullSheetSize();
                                      });
                                    }

                                    _verticalSheetDragging.value = false;
                                  }
                                : null,
                            child: ValueListenableBuilder(
                              valueListenable: _verticalSheetDragging,
                              builder: (_, dragging, __) => SheetDragline(
                                isHolding: dragging,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final _verticalSheetDragY = ValueNotifier(0.0);
  var _verticalSheetDragStartY = 0.0;
  var _verticalSheetDragStartSize = 0.0;
  final _verticalSheetDragging = ValueNotifier(false);

  Widget _buildPageView(
    bool swipe,
    bool interacting,
  ) {
    final isPortrait = !context.isLargeScreen;

    return ValueListenableBuilder(
      valueListenable: _controller.sheetState,
      builder: (_, state, __) {
        final blockSwipe = !swipe || state.isExpanded || interacting;

        return PageView.builder(
          onPageChanged:
              blockSwipe && !isPortrait ? (_) => _startCooldownTimer() : null,
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

  void _cancelCooldown() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _cooldown.value = false;
  }

  void _startCooldownTimer([
    Duration? duration,
  ]) {
    _cancelCooldown();

    if (!mounted) return;

    _cooldown.value = true;
    _debounceTimer = Timer(
      duration ?? kDefaultCooldownDuration,
      () {
        if (!mounted) return;
        _cooldown.value = false;
      },
    );
  }

  final _dummyAlwaysFalse = ValueNotifier(false);

  Widget _buildItem(int index, bool blockSwipe) {
    final isSmall = !context.isLargeScreen;
    return Stack(
      children: [
        Positioned.fill(
          child: ValueListenableBuilder(
            valueListenable: !isSmall ? _dummyAlwaysFalse : _controller.canPull,
            builder: (_, canPull, __) => PointerCountOnScreen(
              enable: isSmall,
              onCountChanged: (count) {
                _pointerCount.value = count;
                _interacting.value = count > 1;
              },
              child: ValueListenableBuilder(
                valueListenable:
                    !isSmall ? _dummyAlwaysFalse : _controller.pulling,
                builder: (__, pulling, ___) => GestureDetector(
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
                    child: ValueListenableBuilder(
                      valueListenable: _controller.freestyleMoveOffset,
                      builder: (_, offset, __) => ValueListenableBuilder(
                        valueListenable: _controller.sheetState,
                        builder: (_, state, __) => GestureDetector(
                          // let the user tap the image to toggle overlay
                          onTap: widget.onTap,
                          child: InteractiveViewerExtended(
                            enable: !state.isExpanded,
                            onZoomUpdated: _controller.onZoomUpdated,
                            onTap: widget.onTap,
                            onDoubleTap: widget.onItemDoubleTap,
                            onLongPress: widget.onItemLongPress,
                            child: widget.itemBuilder(context, index),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (!isSmall)
          if (blockSwipe) ...[
            ValueListenableBuilder(
              valueListenable: _cooldown,
              builder: (_, cooldown, __) => PageNavButton(
                alignment: Alignment.centerRight,
                controller: _controller,
                visibleWhen: (page) => page < widget.itemCount - 1,
                icon: const Icon(Symbols.arrow_forward),
                onPressed: !cooldown
                    ? () => _controller.nextPage(duration: Duration.zero)
                    : null,
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _cooldown,
              builder: (_, cooldown, __) => PageNavButton(
                alignment: Alignment.centerLeft,
                controller: _controller,
                visibleWhen: (page) => page > 0,
                icon: const Icon(Symbols.arrow_back),
                onPressed: !cooldown
                    ? () => _controller.previousPage(duration: Duration.zero)
                    : null,
              ),
            ),
          ],
      ],
    );
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _controller.pulling.value = true;

    if (!_controller.isExpanded) {
      _freestyleMoveStartOffset = details.globalPosition;
      _controller.freestyleMoving.value = true;
      _freestyleMoveScale = 1.0;
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final dy = details.delta.dy;
    _verticalPosition.value = _verticalPosition.value + dy;

    if (_controller.freestyleMoving.value) {
      if (_verticalPosition.value <= 0) return;

      // Calculate scale first
      final movePercent =
          details.globalPosition.dy - _freestyleMoveStartOffset.dy;
      final normalizedPercent = movePercent / widget.swipeDownThreshold;
      _freestyleMoveScale = 1.0 -
          (normalizedPercent * _kSwipeDownScaleFactor)
              .clamp(0.0, _kSwipeDownScaleFactor);

      // Adjust translation based on scale
      final scaledOffset = details.globalPosition - _freestyleMoveStartOffset;
      // Apply scale compensation to keep the image centered
      final scaleCompensation = (1 - _freestyleMoveScale) *
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
    _controller.freestyleMoving.value = false;

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

    final size = _sheetController.size;

    if (size > widget.minSize) {
      _controller.expandToSnapPoint();

      return;
    }

    if (_verticalPosition.value.abs() <= _controller.threshold) {
      //TODO: for some reasons, setState is needed, should investigate later
      setState(() {
        // Animate back to original position
        _controller.resetSheet(
          duration: const Duration(milliseconds: 100),
        );
      });
    }
  }

  void _animateBackToPosition() {
    final startOffset = _controller.freestyleMoveOffset.value;

    final animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    final animation = Tween(
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
        mass: 50,
        stiffness: 80,
        damping: 0.8,
      );
}

class SlideshowOptions extends Equatable {
  const SlideshowOptions({
    this.duration = const Duration(seconds: 5),
    this.direction = SlideshowDirection.forward,
    this.skipTransition = false,
  });

  final Duration duration;
  final SlideshowDirection direction;
  final bool skipTransition;

  @override
  List<Object?> get props => [duration, direction, skipTransition];
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
