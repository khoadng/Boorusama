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
import '../../../../widgets/widgets.dart';
import '../../../foundation/display.dart';
import '../../../foundation/mobile.dart';
import '../../../foundation/platform.dart';
import '../../../settings.dart';
import '../../../theme.dart';
import '../../../widgets/widgets.dart';
import 'auto_slide_mixin.dart';

const _kDefaultCooldownDuration = Duration(milliseconds: 750);
const _kFullSheetSize = 0.95;

class PostDetailsPageView extends StatefulWidget {
  const PostDetailsPageView({
    super.key,
    required this.sheetBuilder,
    required this.itemCount,
    required this.itemBuilder,
    this.minSize = 0.18,
    this.maxSize = 0.7,
    this.controller,
    this.onSwipeDownThresholdReached,
    this.onItemDoubleTap,
    this.onItemLongPress,
    this.onExit,
    this.onExpanded,
    this.onPageChanged,
    this.swipeDownThreshold = 20,
    this.actions = const [],
    this.leftActions = const [],
    this.bottomSheet,
    this.slideshowOptions = const SlideshowOptions(),
    this.sheetStateStorage,
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
  final void Function(int page)? onPageChanged;

  final SlideshowOptions slideshowOptions;

  final PostDetailsPageViewController? controller;
  final SheetStateStorage? sheetStateStorage;

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
      _controller._sheetController;

  @override
  PageController get pageController => _controller.pageController;

  // Use for large screen when details is on the side to prevent spamming
  Timer? _debounceTimer;
  final _cooldown = ValueNotifier(false);
  final hovering = ValueNotifier(false);

  bool get isLargeScreen => context.isLargeScreen;

  @override
  void initState() {
    super.initState();

    hovering.addListener(_onHover);

    _controller =
        widget.controller ?? PostDetailsPageViewController(initialPage: 0);

    _controller.pageController.addListener(_onPageChanged);
    _sheetController.addListener(_onSheetChanged);
    _controller.verticalPosition.addListener(_onVerticalPositionChanged);
    _controller.slideshow.addListener(_onSlideShowChanged);
    _controller.sheetState.addListener(_onSheetStateChanged);

    _verticalSheetDragY.addListener(_onVerticalSheetDragYChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentExpanded = _controller.sheetState.value.isExpanded;

      // auto expand side sheet if it was expanded before
      if (isLargeScreen && !currentExpanded) {
        final expanded = await widget.sheetStateStorage?.loadExpandedState();

        if (expanded == true) {
          _controller.sheetState.value = SheetState.expanded;
        }
      }
    });
  }

  void _onBackButtonPressed(bool didPop) {
    _controller.restoreSystemStatus();
    if (!didPop) {
      Navigator.of(context).pop();
    }
    widget.onExit?.call();
  }

  void _onHover() {
    if (!isDesktopPlatform() || !isLargeScreen) {
      // Overlay is handled by touch gestures on mobile
      return;
    }

    if (hovering.value) {
      _controller.overlay.value = true;
    } else {
      _controller.overlay.value = false;
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

    _controller.displacement.value = dis;
  }

  void _onSheetStateChanged() {
    widget.onExpanded?.call();

    if (_controller.isExpanded) {
      showSystemStatus();
      _controller.overlay.value = true;
    }

    if (isLargeScreen) {
      widget.sheetStateStorage?.persistExpandedState(_controller.isExpanded);
    }
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
        (_verticalSheetDragStartSize - percentage).clamp(0.4, _kFullSheetSize);

    _sheetController.jumpTo(size);
  }

  @override
  void dispose() {
    super.dispose();

    _cancelCooldown();

    _controller.sheetState.removeListener(_onSheetStateChanged);
    _controller.pageController.removeListener(_onPageChanged);
    _controller.slideshow.removeListener(_onSlideShowChanged);
    _controller.verticalPosition.removeListener(_onVerticalPositionChanged);
    _controller._sheetController.removeListener(_onSheetChanged);

    stopAutoSlide();

    if (widget.controller == null) {
      _controller.dispose();
    }
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
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _onBackButtonPressed(didPop);
          return;
        }

        _onBackButtonPressed(didPop);
      },
      child: CallbackShortcuts(
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
              _onBackButtonPressed(false),
        },
        child: Focus(
          autofocus: true,
          child: Row(
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
              !isLargeScreen ? const SizedBox.shrink() : _buildSide(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSide() {
    return ValueListenableBuilder(
      valueListenable: _controller.sheetState,
      builder: (context, state, child) => switch (state) {
        SheetState.expanded => child!,
        SheetState.collapsed => const SizedBox.shrink(),
        SheetState.hidden => Offstage(
            child: child,
          ),
      },
      child: MediaQuery.removePadding(
        context: context,
        removeLeft: true,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          color: Theme.of(context).colorScheme.surface,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).colorScheme.hintColor,
                  width: 0.25,
                ),
              ),
            ),
            child: widget.sheetBuilder(context, null),
          ),
        ),
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
            child: ValueListenableBuilder(
              valueListenable: _controller.sheetState,
              builder: (_, state, __) => !state.isExpanded
                  ? isLargeScreen
                      ? const SizedBox.shrink()
                      : ValueListenableBuilder(
                          valueListenable: _controller.freestyleMoving,
                          builder: (context, moving, child) => _SlideContainer(
                            shouldSlide: moving,
                            direction: SlideContainerDirection.down,
                            child: ValueListenableBuilder(
                              valueListenable: _controller.overlay,
                              builder: (_, overlay, child) => overlay
                                  ? ValueListenableBuilder(
                                      valueListenable: _controller.displacement,
                                      builder: (_, dis, __) => _SlideContainer(
                                        direction: SlideContainerDirection.down,
                                        shouldSlide: dis > _kMinSlideDistance,
                                        child: widget.bottomSheet!,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        )
                  : const SizedBox.shrink(),
            ),
          ),
        Align(
          alignment: Alignment.topCenter,
          child: ValueListenableBuilder(
            valueListenable: _controller.sheetState,
            builder: (_, state, __) => ConditionalParentWidget(
              condition: !state.isExpanded,
              conditionalBuilder: (child) => ValueListenableBuilder(
                valueListenable: _controller.freestyleMoving,
                builder: (context, moving, child) => _SlideContainer(
                  shouldSlide: moving,
                  direction: SlideContainerDirection.up,
                  child: HideUIOverlayTransition(
                    controller: _controller,
                    pointerCount: _pointerCount,
                    slideDown: false,
                    child: child!,
                  ),
                ),
                child: child,
              ),
              child: SafeArea(
                right: isLargeScreen && !state.isExpanded,
                child: _buildOverlay(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverlay() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: ValueListenableBuilder(
        valueListenable: _controller.overlay,
        builder: (_, overlay, __) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: OverflowBar(
                children: overlay
                    ? [
                        CircularIconButton(
                          icon: const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Symbols.arrow_back_ios,
                            ),
                          ),
                          onPressed: () => _onBackButtonPressed(false),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        ...widget.leftActions,
                      ]
                    : const [],
              ),
            ),
            Flexible(
              child: OverflowBar(
                children: overlay
                    ? [
                        ...widget.actions,
                        const SizedBox(width: 8),
                        !isLargeScreen
                            ? const SizedBox.shrink()
                            : CircularIconButton(
                                onPressed: () => _controller.toggleExpanded(),
                                icon: const Icon(Symbols.info),
                              ),
                      ]
                    : const [],
              ),
            ),
          ],
        ),
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
                builder: (context, value, child) =>
                    state.isExpanded && value < 0
                        ? SizedBox(
                            height: maxSize * MediaQuery.sizeOf(context).height,
                          )
                        : ValueListenableBuilder(
                            valueListenable: _pointerCount,
                            builder: (_, count, __) => !state.isExpanded &&
                                    value >=
                                        maxSize *
                                            MediaQuery.sizeOf(context).height &&
                                    !(count >
                                        0) // Only hide when there is any interaction
                                ? const SizedBox.shrink()
                                : SizedBox(height: value),
                          ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildDragSheet({
    bool? forceInitialSizeAsMax,
    required SheetState sheetState,
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
                onPressed: () async {
                  await _controller.resetSheet();
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
                              _controller.sheetMaxSize.value = _kFullSheetSize;
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
      duration ?? _kDefaultCooldownDuration,
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
                          onTap: () => _controller.onImageTap(context),
                          child: InteractiveViewerExtended(
                            enable: !state.isExpanded,
                            onZoomUpdated: _controller.onZoomUpdated,
                            onTap: () => _controller.onImageTap(context),
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
      _controller.freestyleMove.value = true;
      _controller.freestyleMoving.value = true;
      _freestyleMoveScale = 1.0;
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final dy = details.delta.dy;
    _verticalPosition.value = _verticalPosition.value + dy;

    if (_controller.freestyleMove.value) {
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
        _onBackButtonPressed(false);
        return;
      }
      // scale back to 1.0
      _freestyleMoveScale = 1.0;
    } else {
      // Animate back to original position
      _animateBackToPosition();
      _freestyleMoveScale = 1.0;
    }

    _controller.freestyleMove.value = false;
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

class SheetDragline extends StatelessWidget {
  const SheetDragline({
    super.key,
    this.maxWidth = 120,
    this.minWidth = 80,
    this.isHolding = false,
  });

  final double maxWidth;
  final double minWidth;
  final bool isHolding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: ColoredBox(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(
                top: 12,
                bottom: 24,
              ),
              color: Colors.transparent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isHolding ? maxWidth : minWidth,
                height: 4,
                decoration: ShapeDecoration(
                  shape: const StadiumBorder(),
                  color: isHolding
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PageNavButton extends StatelessWidget {
  const PageNavButton({
    super.key,
    required this.controller,
    required this.visibleWhen,
    required this.icon,
    required this.onPressed,
    required this.alignment,
  });

  final PostDetailsPageViewController controller;
  final bool Function(int page) visibleWhen;
  final Widget icon;
  final void Function()? onPressed;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.overlay,
      builder: (_, overlay, child) =>
          overlay ? child! : const SizedBox.shrink(),
      child: ValueListenableBuilder(
        valueListenable: controller.zoom,
        builder: (_, zoom, child) => !zoom ? child! : const SizedBox.shrink(),
        child: ValueListenableBuilder(
          valueListenable: controller.currentPage,
          builder: (context, page, _) => visibleWhen(page)
              ? Align(
                  alignment: alignment,
                  child: MaterialButton(
                    color: context.extendedColorScheme.surfaceContainerOverlay,
                    shape: const CircleBorder(),
                    padding:
                        context.isLargeScreen ? const EdgeInsets.all(8) : null,
                    onPressed: onPressed,
                    child: icon,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class PointerCountOnScreen extends StatefulWidget {
  const PointerCountOnScreen({
    super.key,
    required this.enable,
    required this.onCountChanged,
    required this.child,
  });

  final Widget child;
  final bool enable;
  final void Function(int count) onCountChanged;

  @override
  State<PointerCountOnScreen> createState() => _PointerCountOnScreenState();
}

class _PointerCountOnScreenState extends State<PointerCountOnScreen> {
  final _pointersOnScreen = ValueNotifier<Set<int>>({});
  final _pointerCount = ValueNotifier<int>(0);
  late var enable = widget.enable;

  @override
  void initState() {
    super.initState();
    _pointersOnScreen.addListener(_onPointerChanged);
    _pointerCount.addListener(_onPointerCountChanged);
  }

  @override
  void didUpdateWidget(covariant PointerCountOnScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.enable != oldWidget.enable) {
      setState(() {
        enable = widget.enable;
      });
    }
  }

  void _onPointerCountChanged() {
    widget.onCountChanged(_pointerCount.value);
  }

  void _onPointerChanged() {
    _pointerCount.value = _pointersOnScreen.value.length;
  }

  void _addPointer(int index) {
    _pointersOnScreen.value = {..._pointersOnScreen.value, index};
  }

  void _removePointer(int index) {
    _pointersOnScreen.value = {..._pointersOnScreen.value}..remove(index);
  }

  @override
  void dispose() {
    super.dispose();
    _pointersOnScreen.removeListener(_onPointerChanged);
    _pointerCount.removeListener(_onPointerCountChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: enable ? (event) => _addPointer(event.pointer) : null,
      onPointerMove: enable ? (event) => _addPointer(event.pointer) : null,
      onPointerCancel: enable ? (event) => _removePointer(event.pointer) : null,
      onPointerUp: enable ? (event) => _removePointer(event.pointer) : null,
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

abstract class SheetStateStorage {
  Future<void> persistExpandedState(bool expanded);
  Future<bool> loadExpandedState();
}

class SheetStateStorageBuilder implements SheetStateStorage {
  const SheetStateStorageBuilder({
    required this.save,
    required this.load,
  });

  final Future<void> Function(bool expanded) save;
  final Future<bool> Function() load;

  @override
  Future<bool> loadExpandedState() => load();

  @override
  Future<void> persistExpandedState(bool expanded) => save(expanded);
}

const _kLargeOffset = 500.0;
const _kMinSlideDistance = 5.0;
const _kSwipeDownScaleFactor = 0.2;

class HideUIOverlayTransition extends StatelessWidget {
  const HideUIOverlayTransition({
    super.key,
    required this.controller,
    required this.child,
    this.slideDown = true,
    required this.pointerCount,
    this.skipTransition = false,
  });

  final bool slideDown;
  final PostDetailsPageViewController controller;
  final Widget child;
  final ValueNotifier<int> pointerCount;
  final bool skipTransition;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: pointerCount,
      builder: (_, count, __) => count > 0
          ? ValueListenableBuilder(
              valueListenable: controller.displacement,
              builder: (context, dis, _) => Transform.translate(
                offset: skipTransition && dis > _kMinSlideDistance
                    ? const Offset(0, _kLargeOffset)
                    : slideDown
                        ? Offset(0, dis * 0.5)
                        : Offset(0, -dis * 0.5),
                child: child,
              ),
              child: child,
            )
          : child,
    );
  }
}

enum SlideContainerDirection {
  up,
  down,
}

class _SlideContainer extends StatefulWidget {
  const _SlideContainer({
    required this.child,
    required this.shouldSlide,
    required this.direction,
  });

  final Widget child;
  final bool shouldSlide;
  final SlideContainerDirection direction;

  @override
  _SlideContainerState createState() => _SlideContainerState();
}

class _SlideContainerState extends State<_SlideContainer>
    with TickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      value: 0,
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _SlideContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.shouldSlide != widget.shouldSlide) {
      _animController.animateTo(
        widget.shouldSlide ? 1 : 0,
        duration: widget.shouldSlide
            ? const Duration(milliseconds: 200)
            : const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween(
        begin: Offset.zero,
        end: switch (widget.direction) {
          SlideContainerDirection.up => const Offset(0, -1),
          SlideContainerDirection.down => const Offset(0, 1)
        },
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Curves.easeOut,
        ),
      ),
      child: widget.child,
    );
  }
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

class PostDetailsPageViewController extends ChangeNotifier {
  PostDetailsPageViewController({
    required this.initialPage,
    bool hideOverlay = false,
    this.maxSize = 0.7,
    this.threshold = 400.0,
  })  : currentPage = ValueNotifier(initialPage),
        overlay = ValueNotifier(!hideOverlay),
        sheetState = ValueNotifier(SheetState.collapsed);

  final int initialPage;
  final double maxSize;

  final double threshold;

  late final _pageController = PageController(
    initialPage: initialPage,
  );
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  int get page => currentPage.value;
  bool get isExpanded => sheetState.value.isExpanded;
  PageController get pageController => _pageController;

  late final ValueNotifier<SheetState> sheetState;
  late final ValueNotifier<int> currentPage;
  late final ValueNotifier<bool> overlay;

  late final verticalPosition = ValueNotifier(0.0);
  late final displacement = ValueNotifier(0.0);
  late final animating = ValueNotifier(false);
  late final sheetMaxSize = ValueNotifier(maxSize);
  late final precisePage = ValueNotifier<double?>(initialPage.toDouble());

  final swipe = ValueNotifier(true);
  final canPull = ValueNotifier(true);
  final pulling = ValueNotifier(false);
  final zoom = ValueNotifier(false);
  final slideshow = ValueNotifier(false);
  final freestyleMove = ValueNotifier(false);
  final freestyleMoveOffset = ValueNotifier(Offset.zero);
  final freestyleMoving = ValueNotifier(false);

  void jumpToPage(int page) {
    _pageController.jumpToPage(page);
  }

  Future<void> nextPage({
    Duration? duration,
    Curve? curve,
  }) async {
    final nextPage = page + 1;

    if (duration == Duration.zero) {
      jumpToPage(nextPage);
      return;
    }

    return animateToPage(
      nextPage,
      duration: duration,
      curve: curve,
    );
  }

  Future<void> previousPage({
    Duration? duration,
    Curve? curve,
  }) async {
    final prevPage = page - 1;

    if (duration == Duration.zero) {
      jumpToPage(prevPage);
      return;
    }

    return animateToPage(
      page - 1,
      duration: duration,
      curve: curve,
    );
  }

  Future<void> animateToPage(
    int page, {
    Duration? duration,
    Curve? curve,
  }) =>
      _pageController.animateToPage(
        page,
        duration: duration ?? const Duration(milliseconds: 300),
        curve: curve ?? Curves.easeInOut,
      );

  Future<void> resetSheet({
    Duration? duration,
    Curve? curve,
  }) async {
    animating.value = true;
    swipe.value = true;
    verticalPosition.value = 0.0;
    sheetState.value = switch (sheetState.value) {
      SheetState.expanded => SheetState.hidden,
      SheetState.collapsed => SheetState.collapsed,
      SheetState.hidden => SheetState.hidden,
    };

    return WidgetsBinding.instance.addPostFrameCallback((_) async {
      sheetMaxSize.value = maxSize;

      await _sheetController.animateTo(
        0.0,
        duration: duration ?? const Duration(milliseconds: 250),
        curve: curve ?? Curves.easeInOut,
      );
      animating.value = false;
    });
  }

  Future<void> expandToFullSheetSize() async {
    sheetState.value = SheetState.expanded;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sheetController.animateTo(
        _kFullSheetSize,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> expandToSnapPoint() async {
    animating.value = true;

    sheetState.value = SheetState.expanded;

    return WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _sheetController.animateTo(
        maxSize,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
      animating.value = false;
      verticalPosition.value = 0.0;
    });
  }

  void disableAllSwiping() {
    swipe.value = false;
    canPull.value = false;
  }

  void enableAllSwiping() {
    swipe.value = true;
    canPull.value = true;
  }

  void toggleExpanded() {
    if (sheetState.value.isExpanded) {
      sheetMaxSize.value = maxSize;
    }

    sheetState.value = switch (sheetState.value) {
      SheetState.collapsed => SheetState.expanded,
      SheetState.expanded => SheetState.hidden,
      SheetState.hidden => SheetState.expanded,
    };
  }

  void onZoomUpdated(bool value) {
    zoom.value = value;
    if (value) {
      disableAllSwiping();
    } else {
      enableAllSwiping();
    }
  }

  void toggleOverlay() {
    overlay.value = !overlay.value;

    if (!overlay.value) {
      hideSystemStatus();
    } else {
      showSystemStatus();
    }
  }

  void restoreSystemStatus() {
    showSystemStatus();
  }

  void onImageTap(BuildContext context) {
    if (isDesktopPlatform() && context.isLargeScreen) {
      // overlay is handle by hovering
    } else {
      toggleOverlay();
    }
  }

  void startSlideshow() {
    slideshow.value = true;
    if (overlay.value) overlay.value = false;
    hideSystemStatus();
  }

  void stopSlideshow() {
    slideshow.value = false;
    overlay.value = true;
    showSystemStatus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _sheetController.dispose();
    super.dispose();
  }
}
