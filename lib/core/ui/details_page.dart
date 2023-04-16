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
import 'package:boorusama/core/ui/floating_glassy_card.dart';
import 'package:boorusama/core/ui/swipe_down_to_dismiss_mixin.dart';

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

  @override
  Function() get popper => () => _onBackButtonPressed();

  double _navigationButtonGroupOffset = 0.0;
  double _topRightButtonGroupOffset = 0.0;
  late AnimationController _bottomSheetAnimationController;
  late Animation<Offset> _bottomSheetAnimation;

  @override
  void initState() {
    // Initialize the animation controller and animation
    _bottomSheetAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );

    _bottomSheetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _bottomSheetAnimationController,
      curve: Curves.easeOut,
    ));

    // Start the animation after a delay of 0.5 seconds
    Timer(const Duration(milliseconds: 500), () {
      _bottomSheetAnimationController.forward();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    _bottomSheetAnimationController.dispose();
  }

  void _handlePointerMove(PointerMoveEvent event, bool expanded) {
    if (expanded) {
      // Ignore the swipe down behavior when in expanded mode
      return;
    }

    handlePointerMove(event);

    if (isSwipingDown) {
      setState(() {
        _navigationButtonGroupOffset = -dragDistance > 0 ? 0 : -dragDistance;
        _topRightButtonGroupOffset = -dragDistance > 0 ? 0 : -dragDistance;
      });
    }
  }

  void _handlePointerUp(PointerUpEvent event, bool expanded) {
    if (expanded) {
      // Ignore the swipe down behavior when in expanded mode
      return;
    }
    handlePointerUp(event);
  }

  bool _handleScrollNotification(ScrollNotification notification) =>
      handleScrollNotification(notification);

  Future<void> _onBackButtonPressed() async {
    final navigator = Navigator.of(context);
    await _bottomSheetAnimationController.reverse();
    navigator.pop();
  }

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
            ValueListenableBuilder<int>(
              valueListenable: controller.currentPage,
              builder: (context, currentPage, _) =>
                  ValueListenableBuilder<bool>(
                valueListenable: isExpanded,
                builder: (context, expanded, _) {
                  if (isSwipingDown && !expanded) {
                    return Transform.translate(
                      offset: Offset(dragDistanceX, dragDistance),
                      child: Listener(
                        onPointerMove: (event) =>
                            _handlePointerMove(event, expanded),
                        onPointerUp: (event) =>
                            _handlePointerUp(event, expanded),
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
                      child: Listener(
                        onPointerMove: (event) =>
                            _handlePointerMove(event, expanded),
                        onPointerUp: (event) =>
                            _handlePointerUp(event, expanded),
                        child: NotificationListener<ScrollNotification>(
                          onNotification: _handleScrollNotification,
                          child: ExprollablePageView(
                            controller: controller,
                            onViewportChanged: (metrics) {
                              isExpanded.value = metrics.isExpanded;
                              widget.onExpanded?.call(currentPage);
                            },
                            onPageChanged: (page) =>
                                widget.onPageChanged?.call(page),
                            physics: const DefaultPageViewScrollPhysics(),
                            itemCount: widget.pageCount,
                            itemBuilder: (context, page) {
                              return ValueListenableBuilder<bool>(
                                valueListenable: isExpanded,
                                builder: (context, value, child) =>
                                    widget.expandedBuilder(
                                        context, page, currentPage, value),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            Align(
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
            ),
            Align(
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
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: widget.bottomSheet != null
                  ? SlideTransition(
                      position: _bottomSheetAnimation,
                      child: widget.bottomSheet,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingQuickActionBar extends StatelessWidget {
  const _FloatingQuickActionBar({
    required this.builder,
  });

  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 12,
      left: MediaQuery.of(context).size.width * 0.05,
      child: FloatingGlassyCard(
        child: builder(context),
      ),
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
