// Dart imports:
// ignore_for_file: prefer_int_literals

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../foundation/mobile.dart';
import 'auto_slide_mixin.dart';
import 'constants.dart';
import 'post_details_page_view.dart';

class PostDetailsPageViewController extends ChangeNotifier
    with AutomaticSlideMixin {
  PostDetailsPageViewController({
    required this.initialPage,
    required this.totalPage,
    required this.checkIfLargeScreen,
    this.initialHideOverlay = false,
    bool hoverToControlOverlay = false,
    this.maxSize = 0.7,
    this.threshold = 400.0,
    SlideshowOptions slideshowOptions = const SlideshowOptions(),
  })  : currentPage = ValueNotifier(initialPage),
        _slideshowOptions = slideshowOptions,
        overlay = ValueNotifier(!initialHideOverlay),
        hoverToControlOverlay = ValueNotifier(hoverToControlOverlay),
        sheetState = ValueNotifier(SheetState.collapsed);

  final int initialPage;
  final int totalPage;
  final bool initialHideOverlay;
  final double maxSize;
  final double threshold;

  late SlideshowOptions _slideshowOptions;

  late final _pageController = PageController(
    initialPage: initialPage,
  );
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  final bool Function() checkIfLargeScreen;

  int get page => currentPage.value;
  bool get isExpanded => sheetState.value.isExpanded;
  @override
  PageController get pageController => _pageController;

  DraggableScrollableController get sheetController => _sheetController;

  // ignore: unnecessary_getters_setters
  SlideshowOptions get slideshowOptions => _slideshowOptions;
  set slideshowOptions(SlideshowOptions value) {
    _slideshowOptions = value;
  }

  late final ValueNotifier<SheetState> sheetState;
  late final ValueNotifier<int> currentPage;
  late final ValueNotifier<bool> overlay;
  late final ValueNotifier<bool> hoverToControlOverlay;

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
  final freestyleMoveOffset = ValueNotifier(Offset.zero);
  final freestyleMoving = ValueNotifier(false);
  final isItemPushed = ValueNotifier(false);

  void enableHoverToControlOverlay() {
    hoverToControlOverlay.value = true;
  }

  void disableHoverToControlOverlay() {
    hoverToControlOverlay.value = false;

    // if overlay is hidden, show it
    if (!overlay.value) {
      showOverlay();
    }
  }

  void showOverlay({
    bool includeSystemStatus = true,
  }) {
    if (overlay.value) return;

    overlay.value = true;

    if (includeSystemStatus) {
      showSystemStatus();
    }
  }

  void hideOverlay({
    bool includeSystemStatus = true,
  }) {
    // ignore if overlay is already hidden
    if (!overlay.value) return;

    overlay.value = false;

    if (includeSystemStatus) {
      hideSystemStatus();
    }
  }

  void toggleOverlay({
    bool includeSystemStatus = true,
  }) {
    final oldValue = overlay.value;

    overlay.value = !oldValue;

    if (includeSystemStatus) {
      if (oldValue) {
        hideSystemStatus();
      } else {
        showSystemStatus();
      }
    }
  }

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

    return WidgetsBinding.instance.addPostFrameCallback((_) async {
      sheetMaxSize.value = maxSize;

      await _sheetController.animateTo(
        0,
        duration: duration ?? const Duration(milliseconds: 250),
        curve: curve ?? Curves.easeInOut,
      );

      sheetState.value = switch (sheetState.value) {
        SheetState.expanded => SheetState.hidden,
        SheetState.collapsed => SheetState.collapsed,
        SheetState.hidden => SheetState.hidden,
      };

      animating.value = false;
    });
  }

  Future<void> expandToFullSheetSize() async {
    sheetState.value = SheetState.expanded;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sheetController.animateTo(
        kFullSheetSize,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> expandToSnapPoint() async {
    animating.value = true;

    return WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _sheetController.animateTo(
        maxSize,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
      sheetState.value = SheetState.expanded;
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

  Future<void> toggleExpanded(
    BuildContext context,
    Future<void> Function() anim,
  ) async {
    if (sheetState.value.isExpanded) {
      sheetMaxSize.value = maxSize;
      displacement.value = 0.0;
    } else {
      displacement.value = maxSize * MediaQuery.sizeOf(context).longestSide;
    }

    await anim();

    sheetState.value = switch (sheetState.value) {
      SheetState.collapsed => SheetState.expanded,
      SheetState.expanded => SheetState.hidden,
      SheetState.hidden => SheetState.expanded,
    };
  }

  void onZoomUpdated(bool value) {
    // ignore same value
    if (zoom.value == value) return;

    zoom.value = value;
    if (value) {
      if (!initialHideOverlay) {
        hideOverlay();
      }
      disableAllSwiping();
    } else {
      if (!initialHideOverlay) {
        showOverlay();
      }
      enableAllSwiping();
    }
  }

  void restoreSystemStatus() {
    showSystemStatus();
  }

  Future<void> startSlideshow() async {
    slideshow.value = true;
    if (overlay.value) hideOverlay();

    final isLargeScreen = checkIfLargeScreen();

    // if in expanded mode, exit expanded mode first
    if (isExpanded) {
      if (!isLargeScreen) {
        await resetSheet();
      } else {
        sheetState.value = SheetState.hidden;
      }
    }

    startAutoSlide(
      page,
      totalPage,
      options: _slideshowOptions,
    );
  }

  void stopSlideshow() {
    slideshow.value = false;

    if (!initialHideOverlay) {
      showOverlay();
    }

    stopAutoSlide();
  }

  @override
  void dispose() {
    stopAutoSlide();

    _pageController.dispose();
    _sheetController.dispose();

    currentPage.dispose();
    overlay.dispose();
    hoverToControlOverlay.dispose();
    sheetState.dispose();
    verticalPosition.dispose();
    displacement.dispose();
    animating.dispose();
    sheetMaxSize.dispose();
    precisePage.dispose();
    swipe.dispose();
    canPull.dispose();
    pulling.dispose();
    zoom.dispose();
    slideshow.dispose();
    freestyleMoveOffset.dispose();
    freestyleMoving.dispose();

    super.dispose();
  }
}
