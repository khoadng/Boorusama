// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../widgets/widgets.dart';
import 'post_details_page_view_controller.dart';

class PostDetailsOverlay extends StatelessWidget {
  const PostDetailsOverlay({
    required this.controller,
    required this.leftActions,
    required this.actions,
    required this.useVerticalLayout,
    required this.isLargeScreen,
    required this.sheetAnimController,
    required this.overlayCurvedAnimation,
    required this.disableAnimation,
    super.key,
  });

  final PostDetailsPageViewController controller;
  final List<Widget> leftActions;
  final List<Widget> actions;
  final bool useVerticalLayout;
  final bool isLargeScreen;
  final AnimationController sheetAnimController;
  final Animation<double>? overlayCurvedAnimation;
  final bool disableAnimation;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Builder(
        builder: (context) {
          final overlay = ValueListenableBuilder(
            valueListenable: controller.sheetState,
            builder: (_, state, _) => ConditionalParentWidget(
              condition: !state.isExpanded,
              conditionalBuilder: (child) => ValueListenableBuilder(
                valueListenable: controller.freestyleMoving,
                builder: (context, moving, _) => child,
              ),
              child: SafeArea(
                right: isLargeScreen,
                child: _buildOverlayContent(context),
              ),
            ),
          );

          return ValueListenableBuilder(
            valueListenable: controller.forceHideOverlay,
            builder: (_, hide, _) => hide
                ? const SizedBox.shrink()
                : overlayCurvedAnimation != null
                ? SlideTransition(
                    position: Tween(
                      begin: const Offset(0, -1),
                      end: Offset.zero,
                    ).animate(overlayCurvedAnimation!),
                    child: overlay,
                  )
                : overlay,
          );
        },
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
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
                ...leftActions,
              ],
            ),
          ),
          Flexible(
            child: OverflowBar(
              children: [
                ...actions,
                const SizedBox(width: 8),
                _SheetControlButton(
                  controller: controller,
                  isLargeScreen: isLargeScreen,
                  useVerticalLayout: useVerticalLayout,
                  disableAnimation: disableAnimation,
                  sheetAnimController: sheetAnimController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetControlButton extends StatelessWidget {
  const _SheetControlButton({
    required this.controller,
    required this.isLargeScreen,
    required this.useVerticalLayout,
    required this.disableAnimation,
    required this.sheetAnimController,
  });

  final PostDetailsPageViewController controller;
  final bool isLargeScreen;
  final bool useVerticalLayout;
  final bool disableAnimation;
  final AnimationController sheetAnimController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder(
      valueListenable: controller.sheetState,
      builder: (context, state, child) {
        final isExpanded = state.isExpanded;

        return !isExpanded
            ? _buildExpandButton(context)
            : _buildCollapseButton(context, colorScheme);
      },
    );
  }

  Widget _buildCollapseButton(BuildContext context, ColorScheme colorScheme) {
    return CircularIconButton(
      onPressed: () {
        if (controller.animating.value) return;

        if (!isLargeScreen || useVerticalLayout) {
          controller.resetSheet();
        } else {
          controller.toggleExpanded(
            MediaQuery.sizeOf(context).longestSide,
            () async {
              if (!disableAnimation) {
                if (sheetAnimController.isAnimating) return;
                await sheetAnimController.reverse();
              }
            },
          );
        }
      },
      icon: InfoCircleIcon(
        style: InfoCircleStyle.solid,
        color: colorScheme.primary,
      ),
    );
  }

  Widget _buildExpandButton(BuildContext context) {
    return CircularIconButton(
      onPressed: () {
        if (controller.animating.value) return;

        if (!isLargeScreen || useVerticalLayout) {
          controller
            ..expandToSnapPoint()
            ..hideBottomSheet();
        } else {
          controller.toggleExpanded(
            MediaQuery.sizeOf(context).longestSide,
            () async {
              if (!disableAnimation) {
                if (sheetAnimController.isAnimating) return;

                await sheetAnimController.forward();
              }
            },
          );
        }
      },
      icon: const InfoCircleIcon(),
    );
  }
}
