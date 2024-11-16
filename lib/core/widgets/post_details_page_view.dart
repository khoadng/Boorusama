// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

class PostDetailsPageView extends StatefulWidget {
  const PostDetailsPageView({
    super.key,
    required this.sheet,
    required this.itemCount,
    required this.itemBuilder,
    this.minSize = 0.2,
    this.controller,
    this.onSwipeDownThresholdReached,
    this.swipeDownThreshold = 180.0,
    this.maxChildSize = 0.95,
  });

  final Widget sheet;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double minSize;
  final double maxChildSize;
  final double swipeDownThreshold;

  final void Function()? onSwipeDownThresholdReached;

  final PostDetailsPageViewController? controller;

  @override
  State<PostDetailsPageView> createState() => _PostDetailsPageViewState();
}

class _PostDetailsPageViewState extends State<PostDetailsPageView> {
  ValueNotifier<bool> get _swipe => _controller.swipe;
  ValueNotifier<double> get _verticalPosition => _controller.verticalPosition;
  ValueNotifier<double> get _displacement => _controller.displacement;
  final _pointerCount = ValueNotifier(0);
  final _interacting = ValueNotifier(false);

  late final PostDetailsPageViewController _controller;

  DraggableScrollableController get _sheetController =>
      _controller._sheetController;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? PostDetailsPageViewController();

    _controller._init(
      context: context,
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
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
              child: ValueListenableBuilder(
                valueListenable: _interacting,
                builder: (_, interacting, __) => ValueListenableBuilder(
                  valueListenable: _swipe,
                  builder: (_, swipe, __) => PageView.builder(
                    controller: _controller.pageController,
                    physics: swipe && !interacting
                        ? const DefaultPageViewScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    itemCount: widget.itemCount,
                    itemBuilder: (context, index) => ValueListenableBuilder(
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
                            onVerticalDragUpdate: pulling
                                ? (details) {
                                    final dy = details.delta.dy;

                                    _verticalPosition.value =
                                        _verticalPosition.value + dy;
                                  }
                                : null,
                            onVerticalDragEnd: pulling
                                ? (details) {
                                    _controller.pulling.value = false;
                                    if (_verticalPosition.value >
                                        widget.swipeDownThreshold) {
                                      _verticalPosition.value = 0.0;

                                      if (!_controller.isExpanded) {
                                        widget.onSwipeDownThresholdReached
                                            ?.call();
                                      }
                                      return;
                                    }

                                    final size = _sheetController.size;

                                    if (size > widget.minSize) {
                                      _controller.expandToSnapPoint();

                                      return;
                                    }

                                    if (_verticalPosition.value.abs() <=
                                        _controller.threshold) {
                                      //TODO: for some reasons, setState is needed, should investigate later
                                      setState(() {
                                        // Animate back to original position
                                        _controller.resetSheet();
                                      });
                                    }
                                  }
                                : null,
                            child: widget.itemBuilder(context, index),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _displacement,
              builder: (context, value, child) => SizedBox(
                height: value,
              ),
            ),
          ],
        ),
        NotificationListener<ScrollNotification>(
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
          child: DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0,
            minChildSize: 0,
            maxChildSize: widget.maxChildSize,
            snap: true,
            snapAnimationDuration: const Duration(milliseconds: 100),
            snapSizes: [_controller.maxSize],
            builder: (context, controller) => PostDetailsSheetScrollController(
              controller: controller,
              child: widget.sheet,
            ),
          ),
        ),
      ],
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

class PostDetailsPageViewController extends ChangeNotifier {
  PostDetailsPageViewController({
    this.initialPage = 0,
    this.initialExpanded = false,
    this.maxSize = 0.7,
    this.threshold = 400.0,
  })  : currentPageNotifier = ValueNotifier(initialPage),
        expandedNotifier = ValueNotifier(initialExpanded);

  final int initialPage;
  final bool initialExpanded;
  final double maxSize;

  final double threshold;

  late final _pageController = PageController(
    initialPage: initialPage,
  );
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  int get currentPage => currentPageNotifier.value;
  bool get isExpanded => expandedNotifier.value;
  PageController get pageController => _pageController;

  late final ValueNotifier<bool> expandedNotifier;
  late final ValueNotifier<int> currentPageNotifier;
  late final ValueNotifier<double> verticalPosition = ValueNotifier(0.0);
  late final ValueNotifier<double> displacement = ValueNotifier(0.0);
  late final ValueNotifier<double> topDisplacement = ValueNotifier(0.0);
  late final ValueNotifier<bool> animating = ValueNotifier(false);
  final ValueNotifier<bool> swipe = ValueNotifier(true);
  final ValueNotifier<bool> canPull = ValueNotifier(true);
  final ValueNotifier<bool> pulling = ValueNotifier(false);

  void _init({
    required BuildContext context,
  }) {
    _pageController.addListener(_onPageChanged);
    _sheetController.addListener(() {
      final size = _sheetController.size;

      if (size > maxSize) {
        return;
      }

      if (!context.mounted) {
        return;
      }

      final screenHeight = MediaQuery.sizeOf(context).height;
      final dis = size * screenHeight;

      displacement.value = dis;
    });

    verticalPosition.addListener(() {
      if (animating.value || isExpanded) return;

      final dy = verticalPosition.value;

      if (dy > 0) {
        topDisplacement.value = dy;
        return;
      }

      final size = min(dy.abs(), threshold) / threshold;

      _sheetController.jumpTo(size);
    });
  }

  void _onPageChanged() {
    if (_pageController.page?.round() != currentPage) {
      currentPageNotifier.value = _pageController.page?.round() ?? currentPage;
      notifyListeners();
    }
  }

  void jumpToPage(int page) {
    _pageController.jumpToPage(page);
  }

  Future<void> nextPage({
    Duration? duration,
    Curve? curve,
  }) =>
      animateToPage(
        currentPage + 1,
        duration: duration,
        curve: curve,
      );

  Future<void> previousPage({
    Duration? duration,
    Curve? curve,
  }) =>
      animateToPage(
        currentPage - 1,
        duration: duration,
        curve: curve,
      );

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
    expandedNotifier.value = false;

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

    expandedNotifier.value = true;

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

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _sheetController.dispose();
    super.dispose();
  }
}

class PostDetailsSheetScrollController extends InheritedWidget {
  const PostDetailsSheetScrollController({
    super.key,
    required this.controller,
    required super.child,
  });

  final ScrollController controller;

  static ScrollController of(BuildContext context) {
    final widget = context
        .dependOnInheritedWidgetOfExactType<PostDetailsSheetScrollController>();
    assert(widget != null,
        'No PostDetailsSheetScrollControllerProvider found in context');
    return widget!.controller;
  }

  @override
  bool updateShouldNotify(PostDetailsSheetScrollController oldWidget) {
    return controller != oldWidget.controller;
  }
}
