// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/mobile.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/circular_icon_button.dart';

const String kShowInfoStateCacheKey = 'showInfoCacheStateKey';

class DetailsPageDesktopController extends ChangeNotifier with UIOverlayMixin {
  DetailsPageDesktopController({
    required int initialPage,
    required this.totalPages,
    bool hideOverlay = false,
  })  : currentPage = ValueNotifier(initialPage),
        _hideOverlay = ValueNotifier(hideOverlay);

  final ValueNotifier<bool> showInfo = ValueNotifier(false);
  late final ValueNotifier<int> currentPage;
  final int totalPages;

  final StreamController<PageDirection> _pageController =
      StreamController<PageDirection>.broadcast();

  Stream<PageDirection> get pageStream => _pageController.stream;

  late final ValueNotifier<bool> _hideOverlay;

  @override
  ValueNotifier<bool> get hideOverlay => _hideOverlay;

  void toggleShowInfo() {
    showInfo.value = !showInfo.value;
    notifyListeners();
  }

  void setShowInfo(bool value) {
    showInfo.value = value;
    notifyListeners();
  }

  void changePage(int page) {
    currentPage.value = page;
    notifyListeners();
  }

  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      _pageController.add(PageDirection.next);
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      _pageController.add(PageDirection.previous);
    }
  }
}

class DetailsPageDesktop extends ConsumerStatefulWidget {
  const DetailsPageDesktop({
    super.key,
    required this.media,
    required this.info,
    this.initialPage = 0,
    required this.totalPages,
    required this.onExit,
    this.topRight,
    this.controller,
  });

  final int initialPage;
  final int totalPages;
  final Widget media;
  final Widget info;
  final Widget? topRight;
  final void Function(int page) onExit;
  final DetailsPageDesktopController? controller;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DetailsPageDesktopState();
}

class _DetailsPageDesktopState extends ConsumerState<DetailsPageDesktop> {
  late final DetailsPageDesktopController controller = widget.controller ??
      DetailsPageDesktopController(
        initialPage: widget.initialPage,
        totalPages: widget.totalPages,
      );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final showInfo =
          ref.read(miscDataProvider(kShowInfoStateCacheKey)) == 'true';
      controller.setShowInfo(showInfo);
    });

    showSystemStatus();
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.controller == null) {
      controller.dispose();
    }
  }

  void _onExit(bool didPop) {
    widget.onExit.call(controller.currentPage.value);

    if (didPop) {
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = Screen.of(context).size == ScreenSize.small;

    return CustomContextMenuOverlay(
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
              controller.nextPage(),
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
              controller.previousPage(),
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              _onExit(false),
        },
        child: PopScope(
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) {
              _onExit(didPop);
              return;
            }
            _onExit(false);
          },
          child: Focus(
            autofocus: true,
            child: Scaffold(
              body: Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        widget.media,
                        if (kPreferredLayout.isDesktop)
                          ValueListenableBuilder(
                            valueListenable: controller.currentPage,
                            builder: (context, page, child) => page <
                                    widget.totalPages - 1
                                ? Align(
                                    alignment: Alignment.centerRight,
                                    child: MaterialButton(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(12),
                                      onPressed: () => controller.nextPage(),
                                      child: const Icon(
                                        Symbols.arrow_forward,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        if (kPreferredLayout.isDesktop)
                          ValueListenableBuilder(
                            valueListenable: controller.currentPage,
                            builder: (context, page, child) => page > 0
                                ? Align(
                                    alignment: Alignment.centerLeft,
                                    child: MaterialButton(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(12),
                                      onPressed: () =>
                                          controller.previousPage(),
                                      child: const Icon(
                                        Symbols.arrow_back,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        SafeArea(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: ValueListenableBuilder(
                              valueListenable: controller.hideOverlay,
                              builder: (_, hide, __) => !hide
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: MaterialButton(
                                        color: Colors.black.withOpacity(0.5),
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(12),
                                        onPressed: () => _onExit(false),
                                        child: const Icon(
                                          Symbols.close,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ),
                        if (widget.topRight != null)
                          Builder(
                            builder: (context) {
                              final topRightWidgetRaw = Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSmall)
                                    CircularIconButton(
                                      onPressed: () =>
                                          showMaterialModalBottomSheet(
                                        context: context,
                                        backgroundColor: context
                                            .theme.scaffoldBackgroundColor,
                                        builder: (context) => widget.info,
                                      ),
                                      icon: const Icon(
                                        Symbols.info,
                                        color: Colors.white,
                                      ),
                                    )
                                  else
                                    CircularIconButton(
                                      onPressed: () => setState(
                                        () {
                                          controller.toggleShowInfo();
                                          ref
                                              .read(miscDataProvider(
                                                      kShowInfoStateCacheKey)
                                                  .notifier)
                                              .put(controller.showInfo.value
                                                  .toString());
                                        },
                                      ),
                                      icon: const Icon(
                                        Symbols.info,
                                        color: Colors.white,
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  widget.topRight!,
                                ],
                              );

                              final topRightWidget = ValueListenableBuilder(
                                valueListenable: controller.hideOverlay,
                                builder: (context, value, child) {
                                  return value
                                      ? const SizedBox.shrink()
                                      : topRightWidgetRaw;
                                },
                              );

                              return hasStatusBar()
                                  ? Positioned(
                                      top: 4,
                                      right: 4,
                                      child: SafeArea(
                                        child: topRightWidget,
                                      ),
                                    )
                                  : Positioned(
                                      top: 8,
                                      right: 12,
                                      child: topRightWidget,
                                    );
                            },
                          ),
                      ],
                    ),
                  ),
                  const VerticalDivider(
                    width: 1,
                    thickness: 1,
                  ),
                  if (!isSmall)
                    ValueListenableBuilder(
                      valueListenable: controller.showInfo,
                      builder: (context, value, child) {
                        return value
                            ? Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 400),
                                color: context.colorScheme.surface,
                                child: widget.info,
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
