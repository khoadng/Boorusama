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
                CircularIconButton(
                  onPressed: () {
                    if (useVerticalLayout) {
                      controller.expandToSnapPoint();
                    } else if (!isLargeScreen) {
                      controller.expandToSnapPoint();
                    } else {
                      controller.toggleExpanded(
                        MediaQuery.sizeOf(context).longestSide,
                        () async {
                          if (!disableAnimation) {
                            if (sheetAnimController.isAnimating) return;
                            if (controller.isExpanded) {
                              await sheetAnimController.reverse();
                            } else {
                              await sheetAnimController.forward();
                            }
                          }
                        },
                      );
                    }
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
}
