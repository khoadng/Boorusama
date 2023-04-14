import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/platform.dart';
import 'package:boorusama/core/ui/circular_icon_button.dart';
import 'package:boorusama/core/ui/swipe_down_to_dismiss_mixin.dart';
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter_bloc/flutter_bloc.dart';

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
    required this.onExpanded,
  }) : super(key: key);

  final void Function(int page)? onPageChanged;
  final int intitialIndex;
  final Widget Function(BuildContext context, int index) targetSwipeDownBuilder;
  final Widget Function(
          BuildContext context, int page, int currentPage, bool expanded)
      expandedBuilder;
  final int pageCount;
  final List<Widget> Function() topRightButtonsBuilder;
  final void Function(int currentPage) onExpanded;

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState<T> extends State<DetailsPage<T>>
    with SwipeDownToDismissMixin<DetailsPage<T>> {
  late final controller = ExprollablePageController(
    initialPage: widget.intitialIndex,
    maxViewportOffset: ViewportOffset.shrunk,
    minViewportFraction: 0.999,
    snapViewportOffsets: [
      const ViewportOffset.fractional(0.5),
      ViewportOffset.shrunk,
    ],
  );
  var isExpanded = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    controller.viewport.addListener(() {
      final vp = controller.viewport.value;
      final expandedOffset = ViewportOffset.expanded.toConcreteValue(vp);
      final expanded = vp.offset <= expandedOffset;
      isExpanded.value = expanded;
      if (expanded) {
        widget.onExpanded.call(controller.currentPage.value);
      }
    });
    controller.currentPage.addListener(() {
      widget.onPageChanged?.call(controller.currentPage.value);
    });
  }

  double _navigationButtonGroupOffset = 0.0;
  double _topRightButtonGroupOffset = 0.0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(calculateBackgroundOpacity()),
      body: Stack(
        children: [
          ValueListenableBuilder<int>(
            valueListenable: controller.currentPage,
            builder: (context, currentPage, _) => ValueListenableBuilder<bool>(
              valueListenable: isExpanded,
              builder: (context, expanded, _) {
                if (isSwipingDown && !expanded) {
                  return Transform.translate(
                    offset: Offset(dragDistanceX, dragDistance),
                    child: Listener(
                      onPointerMove: (event) =>
                          _handlePointerMove(event, expanded),
                      onPointerUp: (event) => _handlePointerUp(event, expanded),
                      child: Transform.scale(
                        scale: scale,
                        child:
                            widget.targetSwipeDownBuilder(context, currentPage),
                      ),
                    ),
                  );
                } else {
                  return Transform.translate(
                    offset: Offset(dragDistanceX, dragDistance),
                    child: Listener(
                      onPointerMove: (event) =>
                          _handlePointerMove(event, expanded),
                      onPointerUp: (event) => _handlePointerUp(event, expanded),
                      child: NotificationListener<ScrollNotification>(
                        onNotification: _handleScrollNotification,
                        child: ExprollablePageView(
                          controller: controller,
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
              child: const _NavigationButtonGroup(),
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
                children: widget.topRightButtonsBuilder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationButtonGroup extends StatelessWidget {
  const _NavigationButtonGroup();

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const _BackButton(),
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
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

    return CircularIconButton(
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
        Navigator.of(context).pop();
      },
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
