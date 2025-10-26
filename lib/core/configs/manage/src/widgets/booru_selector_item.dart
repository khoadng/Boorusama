// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:anchor_ui/anchor_ui.dart';

// Project imports:
import '../../../../../foundation/display.dart';
import '../../../../config_widgets/website_logo.dart';
import '../../../config/types.dart';
import 'drag_state_controller.dart';

class BooruSelectorItem extends StatelessWidget {
  const BooruSelectorItem({
    required this.config,
    required this.onTap,
    required this.show,
    required this.selected,
    required this.dragController,
    super.key,
    this.direction = Axis.vertical,
    this.hideLabel = false,
  });

  final BooruConfig config;
  final bool selected;
  final void Function() show;
  final void Function() onTap;
  final Axis direction;
  final bool hideLabel;
  final DragStateController dragController;

  @override
  Widget build(BuildContext context) {
    final logoSize = hideLabel
        ? kPreferredLayout.isMobile
              ? direction == Axis.horizontal
                    ? 28.0
                    : 36.0
              : 36.0
        : direction == Axis.horizontal
        ? 24.0
        : null;

    return Material(
      key: ValueKey(config.id),
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: direction == Axis.vertical
            ? EdgeInsets.symmetric(
                vertical: kPreferredLayout.isMobile ? 8 : 4,
              )
            : const EdgeInsets.only(
                bottom: 4,
                left: 4,
              ),
        child: InkWell(
          hoverColor: Theme.of(context).hoverColor.withValues(alpha: 0.1),
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onSecondaryTap: () => show(),
          onTap: onTap,
          child: ListenableBuilder(
            listenable: dragController,
            builder: (context, _) => _PopoverTooltip(
              hideLabel: hideLabel && !dragController.isDragging,
              direction: direction,
              config: config,
              child: _build(context, logoSize),
            ),
          ),
        ),
      ),
    );
  }

  Widget _build(BuildContext context, double? logoSize) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (direction == Axis.horizontal)
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
                border: Border(
                  top: BorderSide(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 4,
                  ),
                ),
              ),
            ),
          )
        else
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
                border: Border(
                  top: BorderSide(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 48,
                  ),
                ),
              ),
            ),
          ),
        Container(
          width: direction == Axis.vertical
              ? 60
              : hideLabel
              ? 52
              : 64,
          decoration: BoxDecoration(
            border: direction == Axis.vertical
                ? const Border(
                    left: BorderSide(
                      color: Colors.transparent,
                      width: 4,
                    ),
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (direction == Axis.horizontal)
                const SizedBox(height: 12)
              else
                const SizedBox(height: 4),
              Container(
                padding: kPreferredLayout.isDesktop
                    ? EdgeInsets.symmetric(
                        vertical: hideLabel ? 4 : 0,
                      )
                    : null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ConfigAwareWebsiteLogo.fromConfig(
                    config.auth,
                    width: logoSize,
                    height: logoSize,
                  ),
                ),
              ),
              if (direction == Axis.horizontal && hideLabel)
                const SizedBox(height: 8)
              else
                const SizedBox(height: 4),
              if (!hideLabel)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 4,
                    right: 4,
                    bottom: 4,
                  ),
                  child: Text(
                    config.name,
                    textAlign: TextAlign.center,
                    maxLines: direction == Axis.vertical ? 3 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PopoverTooltip extends StatelessWidget {
  const _PopoverTooltip({
    required this.hideLabel,
    required this.direction,
    required this.config,
    required this.child,
  });

  final bool hideLabel;
  final Axis direction;
  final BooruConfig config;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!hideLabel) {
      return child;
    }

    final colorScheme = Theme.of(context).colorScheme;

    return AnchorPopover(
      placement: switch (direction) {
        Axis.horizontal => Placement.top,
        Axis.vertical => Placement.right,
      },
      triggerMode: const AnchorTriggerMode.hover(),
      arrowSize: const Size(12, 4),
      arrowShape: const RoundedArrow(),
      offset: switch (direction) {
        Axis.horizontal => const Offset(0, -6),
        Axis.vertical => const Offset(6, 0),
      },
      border: BorderSide(
        color: colorScheme.outlineVariant,
        width: 1.5,
      ),
      backgroundColor: colorScheme.surfaceContainerHigh,
      transitionBuilder: (context, animation, child) => AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final isAppearing = animation.status == AnimationStatus.forward;

          if (isAppearing || animation.status == AnimationStatus.completed) {
            final t = animation.value;
            final scaleValue = Curves.easeOutBack.transform(t);
            final fadeValue = t < 0.2 ? t / 0.2 : 1.0;

            return Opacity(
              opacity: 0.3 + (0.7 * fadeValue),
              child: Transform.scale(
                scale: 0.5 + (0.5 * scaleValue),
                child: child,
              ),
            );
          } else {
            return Opacity(
              opacity: CurveTween(
                curve: Curves.easeIn,
              ).transform(animation.value),
              child: child,
            );
          }
        },
        child: child,
      ),
      overlayBuilder: (context) => Container(
        padding: const EdgeInsets.all(12),
        child: SelectableRegion(
          selectionControls: materialTextSelectionControls,
          child: Text(
            config.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      child: child,
    );
  }
}
