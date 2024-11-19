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
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/mobile.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

const _kDefaultCooldownDuration = Duration(milliseconds: 500);

class PostDetailsPageView extends StatefulWidget {
  const PostDetailsPageView({
    super.key,
    required this.sheetBuilder,
    required this.itemCount,
    required this.itemBuilder,
    this.minSize = 0.15,
    this.maxSize = 0.7,
    this.controller,
    this.onSwipeDownThresholdReached,
    this.onItemDoubleTap,
    this.onItemLongPress,
    this.onExit,
    this.onExpanded,
    this.onPageChanged,
    this.swipeDownThreshold = 180.0,
    this.maxChildSize = 0.95,
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
  final double maxChildSize;
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
    with AutomaticSlideMixin {
  ValueNotifier<bool> get _swipe => _controller.swipe;
  ValueNotifier<double> get _verticalPosition => _controller.verticalPosition;
  ValueNotifier<double> get _displacement => _controller.displacement;
  final _pointerCount = ValueNotifier(0);
  final _interacting = ValueNotifier(false);
  late var _slideshowOptions = widget.slideshowOptions;

  late final PostDetailsPageViewController _controller;

  DraggableScrollableController get _sheetController =>
      _controller._sheetController;

  @override
  PageController get pageController => _controller.pageController;

  // Use for large screen when details is on the side to prevent spamming
  Timer? _debounceTimer;
  final _cooldown = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    _controller =
        widget.controller ?? PostDetailsPageViewController(initialPage: 0);

    _controller.pageController.addListener(_onPageChanged);
    _sheetController.addListener(_onSheetChanged);
    _controller.verticalPosition.addListener(_onVerticalPositionChanged);
    _controller.slideshow.addListener(_onSlideShowChanged);
    _controller.expanded.addListener(_onExpandedChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentExpanded = _controller.expanded.value;
      final orientation = MediaQuery.orientationOf(context);

      // auto expand side sheet if it was expanded before
      if (orientation.isLandscape && !currentExpanded) {
        final expanded = await widget.sheetStateStorage?.loadExpandedState();

        if (expanded == true) {
          _controller.expanded.value = true;
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

  void _onPageChanged() {
    final page = _controller.pageController.page?.round();

    if (page == null) return;

    if (page != _controller.page) {
      _controller.currentPage.value = page;

      widget.onPageChanged?.call(page);
    }
  }

  void _onVerticalPositionChanged() {
    if (_controller.animating.value || _controller.isExpanded) return;

    final dy = _controller.verticalPosition.value;

    if (dy > 0) {
      _controller.topDisplacement.value = dy;
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

  void _onExpandedChanged() {
    widget.onExpanded?.call();

    if (_controller.isExpanded) {
      showSystemStatus();
      _controller.overlay.value = true;
    }

    final orientation = MediaQuery.orientationOf(context);

    if (orientation.isLandscape) {
      widget.sheetStateStorage?.persistExpandedState(_controller.isExpanded);
    }
  }

  Future<void> _onSlideShowChanged() async {
    final slideShow = _controller.slideshow.value;

    if (slideShow) {
      // if in expanded mode, exit expanded mode first
      if (_controller.isExpanded) {
        final orientation = MediaQuery.orientationOf(context);

        if (orientation.isPortrait) {
          await _controller.resetSheet(
            duration: const Duration(milliseconds: 300),
          );
        } else {
          _controller.expanded.value = false;
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

  @override
  void dispose() {
    super.dispose();

    _debounceTimer?.cancel();

    _controller.expanded.removeListener(_onExpandedChanged);
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
          const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
              _controller.nextPage(),
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
              _controller.previousPage(),
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
                  child: _buildMain(),
                ),
              ),
              PerformanceOrientationBuilder(
                builder: (context, orientation) => orientation.isPortrait
                    ? const SizedBox.shrink()
                    : _buildSide(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSide() {
    return ValueListenableBuilder(
      valueListenable: _controller.expanded,
      builder: (context, expanded, child) => !expanded
          ? const SizedBox.shrink()
          : Container(
              constraints: const BoxConstraints(maxWidth: 400),
              color: Theme.of(context).colorScheme.surface,
              child: widget.sheetBuilder(context, null),
            ),
    );
  }

  Widget _buildMain() {
    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              ValueListenableBuilder(
                valueListenable: _controller.topDisplacement,
                builder: (context, dis, child) => SizedBox(
                  height: (dis * 1.75).clamp(
                    0.0,
                    MediaQuery.sizeOf(context).height * 0.6,
                  ),
                ),
              ),
              Expanded(
                child: PerformanceOrientationBuilder(
                  builder: (context, orientation) => ValueListenableBuilder(
                    valueListenable: _interacting,
                    builder: (_, interacting, __) => ValueListenableBuilder(
                      valueListenable: _swipe,
                      builder: (_, swipe, __) => _buildPageView(
                        swipe,
                        interacting,
                        orientation.isPortrait,
                      ),
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
          child: PerformanceOrientationBuilder(
            builder: (context, orientation) => orientation.isPortrait
                ? ValueListenableBuilder(
                    valueListenable: _controller.expanded,
                    builder: (_, expanded, __) => expanded
                        // If expanded, show the drag sheet
                        ? _buildDragSheet(
                            initialChildSize: widget.maxSize,
                            expanded: expanded,
                          )
                        // If not expanded, hide it and let the user pull it up
                        : _buildDragSheet(
                            expanded: expanded,
                          ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        if (widget.bottomSheet != null)
          Align(
            alignment: Alignment.bottomCenter,
            child: PerformanceOrientationBuilder(
              builder: (context, orientation) => orientation.isLandscape
                  ? const SizedBox.shrink()
                  : ValueListenableBuilder(
                      valueListenable: _controller.expanded,
                      builder: (context, expanded, _) => !expanded
                          ? ValueListenableBuilder(
                              valueListenable: _controller.overlay,
                              builder: (_, overlay, child) =>
                                  overlay ? child! : const SizedBox.shrink(),
                              child: HideUIOverlayTransition(
                                controller: _controller,
                                pointerCount: _pointerCount,
                                child: widget.bottomSheet!,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
            ),
          ),
        Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: ValueListenableBuilder(
              valueListenable: _controller.expanded,
              builder: (_, expanded, child) => ConditionalParentWidget(
                condition: !expanded,
                conditionalBuilder: (child) => HideUIOverlayTransition(
                  controller: _controller,
                  pointerCount: _pointerCount,
                  slideDown: false,
                  child: child,
                ),
                child: child!,
              ),
              child: _buildOverlay(),
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
                        PerformanceOrientationBuilder(
                          builder: (context, orientation) => orientation
                                  .isPortrait
                              ? const SizedBox.shrink()
                              : CircularIconButton(
                                  onPressed: () => _controller.toggleExpanded(),
                                  icon: const Icon(Symbols.info),
                                ),
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
    return PerformanceOrientationBuilder(
      builder: (context, orientation) => orientation.isPortrait
          ? ValueListenableBuilder(
              valueListenable: _controller.expanded,
              builder: (_, expanded, __) => ValueListenableBuilder(
                valueListenable: _displacement,
                builder: (context, value, child) => expanded && value <= 0
                    ? SizedBox(
                        height:
                            widget.maxSize * MediaQuery.sizeOf(context).height,
                      )
                    : ValueListenableBuilder(
                        valueListenable: _pointerCount,
                        builder: (_, count, __) => !expanded &&
                                value >=
                                    widget.maxSize *
                                        MediaQuery.sizeOf(context).height &&
                                !(count >
                                    0) // Only hide when there is any interaction
                            ? const SizedBox.shrink()
                            : SizedBox(height: value),
                      ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    return ValueListenableBuilder(
      valueListenable: _controller.expanded,
      builder: (_, expanded, __) => GestureDetector(
        // let the user tap the image to toggle overlay
        onTap: _controller.onImageTap,
        child: InteractiveViewExtended(
          enable: !expanded,
          onZoomUpdated: _controller.onZoomUpdated,
          onTap: _controller.onImageTap,
          onDoubleTap: widget.onItemDoubleTap,
          onLongPress: widget.onItemLongPress,
          child: widget.itemBuilder(context, index),
        ),
      ),
    );
  }

  Widget _buildDragSheet({
    double? initialChildSize,
    required bool expanded,
  }) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (_controller.isExpanded) {
          if (notification is ScrollEndNotification) {
            if (_sheetController.size < 0.65) {
              _controller.resetSheet();
            }
          }
        }

        return false;
      },
      child: DraggableScrollableSheet(
        controller: _sheetController,
        initialChildSize: initialChildSize ?? 0,
        minChildSize: 0,
        maxChildSize: expanded ? widget.maxChildSize : widget.maxSize,
        snap: true,
        snapAnimationDuration: const Duration(milliseconds: 100),
        snapSizes: [_controller.maxSize],
        builder: (context, scrollController) => Scaffold(
          floatingActionButton: ScrollToTop(
            scrollController: scrollController,
            child: BooruScrollToTopButton(
              onPressed: () {
                _controller.resetSheet(
                  duration: const Duration(milliseconds: 250),
                );
              },
            ),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: widget.sheetBuilder(context, scrollController),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ValueListenableBuilder(
                  valueListenable: _controller.expanded,
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
        ),
      ),
    );
  }

  Widget _buildPageView(
    bool swipe,
    bool interacting,
    bool isPortrait,
  ) {
    return ValueListenableBuilder(
      valueListenable: _controller.expanded,
      builder: (_, expanded, __) {
        final blockSwipe = !swipe || expanded || interacting;

        return PageView.builder(
          onPageChanged: blockSwipe && !isPortrait
              ? (value) {
                  _debounceTimer?.cancel();
                  _cooldown.value = true;
                  _debounceTimer = Timer(
                    _kDefaultCooldownDuration,
                    () {
                      if (!mounted) return;
                      _cooldown.value = false;
                    },
                  );
                }
              : null,
          controller: _controller.pageController,
          physics: blockSwipe
              ? const NeverScrollableScrollPhysics()
              : const DefaultPageViewScrollPhysics(),
          itemCount: widget.itemCount,
          itemBuilder: isPortrait
              ? (context, index) => ValueListenableBuilder(
                    valueListenable: _controller.canPull,
                    builder: (_, canPull, __) => PointerCountOnScreen(
                      onCountChanged: (count) {
                        _pointerCount.value = count;
                        _interacting.value = count > 1;
                      },
                      child: ValueListenableBuilder(
                        valueListenable: _controller.pulling,
                        builder: (__, pulling, ___) => GestureDetector(
                          onVerticalDragStart: canPull && !interacting
                              ? (details) {
                                  _controller.pulling.value = true;
                                }
                              : null,
                          onVerticalDragUpdate:
                              pulling ? _onVerticalDragUpdate : null,
                          onVerticalDragEnd:
                              pulling ? _onVerticalDragEnd : null,
                          child: buildItem(context, index),
                        ),
                      ),
                    ),
                  )
              : (context, index) => Stack(
                    alignment: Alignment.center,
                    children: [
                      buildItem(context, index),
                      if (blockSwipe)
                        ValueListenableBuilder(
                          valueListenable: _cooldown,
                          builder: (_, cooldown, __) => PageNavButton(
                            alignment: Alignment.centerRight,
                            controller: _controller,
                            visibleWhen: (page) => page < widget.itemCount - 1,
                            icon: Icon(Symbols.arrow_forward),
                            onPressed: !cooldown
                                ? () => _controller.nextPage(
                                      duration: Duration.zero,
                                    )
                                : null,
                          ),
                        ),
                      if (blockSwipe)
                        ValueListenableBuilder(
                          valueListenable: _cooldown,
                          builder: (_, cooldown, __) => PageNavButton(
                            alignment: Alignment.centerLeft,
                            controller: _controller,
                            visibleWhen: (page) => page > 0,
                            icon: Icon(Symbols.arrow_back),
                            onPressed: !cooldown
                                ? () => _controller.previousPage(
                                      duration: Duration.zero,
                                    )
                                : null,
                          ),
                        ),
                    ],
                  ),
        );
      },
    );
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final dy = details.delta.dy;

    _verticalPosition.value = _verticalPosition.value + dy;
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _controller.pulling.value = false;
    if (_verticalPosition.value > widget.swipeDownThreshold) {
      _verticalPosition.value = 0.0;

      if (!_controller.isExpanded) {
        if (widget.onSwipeDownThresholdReached != null) {
          widget.onSwipeDownThresholdReached?.call();
        } else {
          _onBackButtonPressed(false);
        }
      }

      return;
    }

    final size = _sheetController.size;

    if (size > widget.minSize) {
      _controller.expandToSnapPoint();

      return;
    }

    if (_verticalPosition.value.abs() <= _controller.threshold) {
      //TODO: for some reasons, setState is needed, should investigate later
      setState(() {
        // Animate back to original position
        _controller.resetSheet();
      });
    }
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
                    padding: const EdgeInsets.all(12),
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
    required this.onCountChanged,
    required this.child,
  });

  final Widget child;
  final void Function(int count) onCountChanged;

  @override
  State<PointerCountOnScreen> createState() => _PointerCountOnScreenState();
}

class _PointerCountOnScreenState extends State<PointerCountOnScreen> {
  final _pointersOnScreen = ValueNotifier<Set<int>>({});
  final _pointerCount = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _pointersOnScreen.addListener(_onPointerChanged);
    _pointerCount.addListener(_onPointerCountChanged);
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
      onPointerDown: (event) {
        _addPointer(event.pointer);
      },
      onPointerMove: (event) {
        _addPointer(event.pointer);
      },
      onPointerCancel: (event) {
        _removePointer(event.pointer);
      },
      onPointerUp: (event) {
        _removePointer(event.pointer);
      },
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

class HideUIOverlayTransition extends StatelessWidget {
  const HideUIOverlayTransition({
    super.key,
    required this.controller,
    required this.child,
    this.slideDown = true,
    required this.pointerCount,
  });

  final bool slideDown;
  final PostDetailsPageViewController controller;
  final Widget child;
  final ValueNotifier<int> pointerCount;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: pointerCount,
      builder: (_, count, __) => count > 0
          ? ValueListenableBuilder(
              valueListenable: controller.topDisplacement,
              builder: (_, topDis, child) => topDis > 0
                  ? Transform.translate(
                      offset:
                          slideDown ? Offset(0, topDis) : Offset(0, -topDis),
                      child: Opacity(
                        opacity: 1.0 - (topDis / 100).clamp(0.0, 1.0),
                        child: child,
                      ),
                    )
                  : ValueListenableBuilder(
                      valueListenable: controller.displacement,
                      builder: (context, dis, _) => Transform.translate(
                        offset: slideDown
                            ? Offset(0, dis * 0.5)
                            : Offset(0, -dis * 0.5),
                        child: child,
                      ),
                      child: child,
                    ),
              child: child,
            )
          : child,
    );
  }
}

class PostDetailsPageViewController extends ChangeNotifier {
  PostDetailsPageViewController({
    required this.initialPage,
    bool hideOverlay = false,
    this.maxSize = 0.7,
    this.threshold = 400.0,
  })  : currentPage = ValueNotifier(initialPage),
        overlay = ValueNotifier(!hideOverlay),
        expanded = ValueNotifier(false);

  final int initialPage;
  final double maxSize;

  final double threshold;

  late final _pageController = PageController(
    initialPage: initialPage,
  );
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  int get page => currentPage.value;
  bool get isExpanded => expanded.value;
  PageController get pageController => _pageController;

  late final ValueNotifier<bool> expanded;
  late final ValueNotifier<int> currentPage;
  late final ValueNotifier<bool> overlay;

  late final verticalPosition = ValueNotifier(0.0);
  late final displacement = ValueNotifier(0.0);
  late final topDisplacement = ValueNotifier(0.0);
  late final animating = ValueNotifier(false);

  final swipe = ValueNotifier(true);
  final canPull = ValueNotifier(true);
  final pulling = ValueNotifier(false);
  final zoom = ValueNotifier(false);
  final slideshow = ValueNotifier(false);

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
    topDisplacement.value = 0.0;
    expanded.value = false;

    return WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _sheetController.animateTo(
        0.0,
        duration: duration ?? const Duration(milliseconds: 100),
        curve: curve ?? Curves.easeInOut,
      );
      animating.value = false;
    });
  }

  Future<void> expandToSnapPoint() async {
    animating.value = true;

    expanded.value = true;

    return WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _sheetController.animateTo(
        maxSize,
        duration: const Duration(milliseconds: 100),
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
    expanded.value = !expanded.value;
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

  void onImageTap() {
    toggleOverlay();
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
