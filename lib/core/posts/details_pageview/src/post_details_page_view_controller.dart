// Dart imports:
// ignore_for_file: prefer_int_literals

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../foundation/mobile.dart';
import '../../../widgets/widgets.dart';
import '../../slideshow/types.dart';
import 'constants.dart';
import 'post_details_page_view.dart';

class PostDetailsPageViewController extends ChangeNotifier {
  PostDetailsPageViewController({
    required this.initialPage,
    required this.totalPage,
    required this.checkIfLargeScreen,
    this.disableAnimation = false,
    this.initialHideOverlay = false,
    bool hoverToControlOverlay = false,
    this.maxSize = 0.7,
    this.thresholdSizeToExpand = 0.02,
    SlideshowOptions slideshowOptions = const SlideshowOptions(),
    this.viewMode = ViewMode.horizontal,
    this.onBeforeSlideshowAdvance,
  }) : currentPage = ValueNotifier(initialPage),
       overlay = ValueNotifier(!initialHideOverlay),
       bottomSheet = ValueNotifier(!initialHideOverlay),
       hoverToControlOverlay = ValueNotifier(hoverToControlOverlay),
       sheetState = ValueNotifier(SheetState.collapsed),
       _initialSlideshowOptions = slideshowOptions;

  final int initialPage;
  final int totalPage;
  final bool initialHideOverlay;
  final double maxSize;
  final double thresholdSizeToExpand;
  final bool disableAnimation;
  final ViewMode viewMode;
  final SlideshowOptions _initialSlideshowOptions;
  final SlideshowAdvanceCallback? onBeforeSlideshowAdvance;

  // Use for large screen when details is on the side to prevent spamming
  Timer? _debounceTimer;

  late final _pageController = PageController(
    initialPage: initialPage,
  );
  final _sheetController = DraggableScrollableController();
  late final _slideshowController = SlideshowController(
    onNavigateToPage: createDefaultSlideshowNavigateCallback(_pageController),
    options: _initialSlideshowOptions,
    onBeforeAdvance: onBeforeSlideshowAdvance,
  );

  final bool Function() checkIfLargeScreen;

  int get page => currentPage.value;
  bool get isExpanded => sheetState.value.isExpanded;
  bool get useVerticalLayout =>
      viewMode == ViewMode.vertical && !checkIfLargeScreen();

  PageController get pageController => _pageController;
  DraggableScrollableController get sheetController => _sheetController;
  SlideshowController get slideshowController => _slideshowController;

  AnimationController? _overlayAnimController;
  AnimationController? _bottomSheetAnimController;

  SlideshowOptions get slideshowOptions => _slideshowController.options;
  set slideshowOptions(SlideshowOptions value) {
    _slideshowController.options = value;
  }

  late final ValueNotifier<SheetState> sheetState;
  late final ValueNotifier<int> currentPage;
  late final ValueNotifier<bool> overlay;
  late final ValueNotifier<bool> bottomSheet;
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
  final freestyleMoveOffset = ValueNotifier(Offset.zero);
  final freestyleMoving = ValueNotifier(false);
  final isItemPushed = ValueNotifier(false);
  final forceHideOverlay = ValueNotifier(false);
  final forceHideBottomSheet = ValueNotifier(false);
  final cooldown = ValueNotifier(false);
  final keyboardShortcutsEnabled = ValueNotifier(true);

  var previouslyForcedShowUIByDrag = false;

  void attachOverlayAnimController(AnimationController? controller) {
    _overlayAnimController = controller;

    if (kEnableHeroTransition) {
      if (!initialHideOverlay) {
        _showOverlayAnim(
          animationDelay: const Duration(milliseconds: 150),
        );
      } else {
        _hideOverlayAnim();
      }
    } else {
      if (!initialHideOverlay) {
        controller?.value = 1.0;
      } else {
        controller?.value = 0.0;
      }
    }
  }

  void attachBottomSheetAnimController(AnimationController? controller) {
    _bottomSheetAnimController = controller;

    if (kEnableHeroTransition) {
      if (!initialHideOverlay) {
        _showBottomSheetAnim(
          animationDelay: const Duration(milliseconds: 150),
        );
      } else {
        _hideBottomSheetAnim();
      }
    } else {
      if (!initialHideOverlay) {
        controller?.value = 1.0;
      } else {
        controller?.value = 0.0;
      }
    }
  }

  void detachOverlayAnimController() {
    _overlayAnimController = null;
  }

  void detachBottomSheetAnimController() {
    _bottomSheetAnimController = null;
  }

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

    _showOverlayAnim();

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

    _hideOverlayAnim();

    if (includeSystemStatus) {
      hideSystemStatus();
    }
  }

  void _showOverlayAnim({
    Duration? animationDelay,
  }) {
    if (!disableAnimation) {
      if (animationDelay != null) {
        Future.delayed(
          animationDelay,
          () {
            _overlayAnimController?.forward();
          },
        );
      } else {
        _overlayAnimController?.forward();
      }
    } else {
      forceHideOverlay.value = false;
    }
  }

  void showBottomSheet({
    Duration? animationDelay,
  }) {
    if (bottomSheet.value) return;

    bottomSheet.value = true;

    _showBottomSheetAnim(
      animationDelay: animationDelay,
    );
  }

  void _showBottomSheetAnim({
    Duration? animationDelay,
  }) {
    if (!disableAnimation) {
      if (animationDelay != null) {
        Future.delayed(
          animationDelay,
          () {
            _bottomSheetAnimController?.forward();
          },
        );
      } else {
        _bottomSheetAnimController?.forward();
      }
    } else {
      forceHideBottomSheet.value = false;
    }
  }

  void hideBottomSheet() {
    if (!bottomSheet.value) return;

    bottomSheet.value = false;

    _hideBottomSheetAnim();
  }

  void _hideBottomSheetAnim() {
    if (!disableAnimation) {
      _bottomSheetAnimController?.reverse();
    } else {
      forceHideBottomSheet.value = true;
    }
  }

  void _hideOverlayAnim() {
    if (!disableAnimation) {
      _overlayAnimController?.reverse();
    } else {
      forceHideOverlay.value = true;
    }
  }

  void toggleOverlay({
    bool includeSystemStatus = true,
  }) {
    final oldValue = overlay.value;

    if (oldValue) {
      hideOverlay(
        includeSystemStatus: includeSystemStatus,
      );
      hideBottomSheet();
    } else {
      showOverlay(
        includeSystemStatus: includeSystemStatus,
      );
      showBottomSheet();
    }
  }

  void showAllUI() {
    showOverlay();
    showBottomSheet();
  }

  void hideAllUI() {
    if (overlay.value) hideOverlay();
    if (bottomSheet.value) hideBottomSheet();
  }

  void dragUpdate(DragUpdateDetails details) {
    if (isExpanded || useVerticalLayout) return;

    final dy = details.delta.dy;
    verticalPosition.value = verticalPosition.value + dy;

    freestyleMoving.value = verticalPosition.value > 0;

    if (freestyleMoving.value) {
      hideOverlay(
        includeSystemStatus: false,
      );
      hideBottomSheet();
    } else {
      // This is needed to prevent showing the UI when it is previously hidden
      if (!bottomSheet.value && !overlay.value) {
        previouslyForcedShowUIByDrag = true;
      }
      showOverlay();
    }

    if (verticalPosition.value < 0) {
      hideBottomSheet();
    }
  }

  Future<void> dragEnd() async {
    if (useVerticalLayout) return;

    final size = sheetController.size;

    if (size > thresholdSizeToExpand) {
      unawaited(expandToSnapPoint());

      return;
    }

    final threshold = _sheetController.sizeToPixels(thresholdSizeToExpand);

    if (verticalPosition.value.abs() <= threshold) {
      // Animate back to original position
      await resetSheet(
        duration: const Duration(milliseconds: 150),
      );
    } else {
      verticalPosition.value = 0.0;
    }

    if (previouslyForcedShowUIByDrag) {
      previouslyForcedShowUIByDrag = false;
      hideOverlay();
    } else {
      showBottomSheet();
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
  }) => _pageController.animateToPage(
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
    showOverlay(
      includeSystemStatus: false,
    );

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

  void enableKeyboardShortcuts() {
    keyboardShortcutsEnabled.value = true;
  }

  void disableKeyboardShortcuts() {
    keyboardShortcutsEnabled.value = false;
  }

  void setDisplacement(double value) {
    displacement.value = value;
    isItemPushed.value = value > 0;
  }

  Future<void> toggleExpanded(
    double longestSide,
    Future<void> Function() anim,
  ) async {
    void setSheetState() {
      sheetState.value = switch (sheetState.value) {
        SheetState.collapsed => SheetState.expanded,
        SheetState.expanded => SheetState.hidden,
        SheetState.hidden => SheetState.expanded,
      };
    }

    if (useVerticalLayout) {
      await anim();
      setSheetState();
      return;
    }

    if (sheetState.value.isExpanded) {
      sheetMaxSize.value = maxSize;
      setDisplacement(0.0);
    } else {
      setDisplacement(maxSize * longestSide);
    }

    await anim();

    setSheetState();
  }

  void onTransformationChanged(TransformationDetails details) {
    final isZoomed = details.isZoomed;
    // ignore same value
    if (zoom.value == isZoomed) return;

    zoom.value = isZoomed;
    if (isZoomed) {
      if (!initialHideOverlay) {
        hideAllUI();
      }
      disableAllSwiping();
    } else {
      if (!initialHideOverlay) {
        showAllUI();
      }
      enableAllSwiping();
    }
  }

  void restoreSystemStatus() {
    showSystemStatus();
  }

  Future<void> startSlideshow() async {
    final isLargeScreen = checkIfLargeScreen();

    // if in expanded mode, exit expanded mode first
    if (isExpanded) {
      if (!isLargeScreen) {
        await resetSheet();

        const maxWaitTime = Duration(seconds: 2);
        final startTime = DateTime.now();

        // wait for sheet to be fully collapsed with timeout
        while (sheetState.value != SheetState.hidden) {
          if (DateTime.now().difference(startTime) > maxWaitTime) {
            // Timeout reached, force the state
            sheetState.value = SheetState.hidden;
            break;
          }
          await Future.delayed(const Duration(milliseconds: 50));
        }
      } else {
        sheetState.value = SheetState.hidden;
      }
    }

    hideAllUI();

    _slideshowController.start(
      page,
      totalPage,
    );
  }

  void stopSlideshow() {
    if (!initialHideOverlay) {
      showAllUI();
    }

    _slideshowController.stop();
  }

  void _cancelCooldown() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    cooldown.value = false;
  }

  void startCooldownTimer([
    Duration? duration,
  ]) {
    _cancelCooldown();

    cooldown.value = true;
    _debounceTimer = Timer(
      duration ?? kDefaultCooldownDuration,
      () {
        cooldown.value = false;
      },
    );
  }

  @override
  void dispose() {
    _slideshowController.dispose();
    _cancelCooldown();

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
    freestyleMoveOffset.dispose();
    freestyleMoving.dispose();
    isItemPushed.dispose();
    forceHideOverlay.dispose();
    forceHideBottomSheet.dispose();
    keyboardShortcutsEnabled.dispose();

    super.dispose();
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
