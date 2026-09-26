// Package imports:
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

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
      borderRadius: BorderRadius.circular(16),
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
          hoverColor: Kurumi.themeOf(context).hoverColor.withValues(alpha: 0.1),
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
        if (selected)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Kurumi.themeOf(context)
                    .colorScheme
                    .secondaryContainer
                    .withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        SizedBox(
          width: direction == Axis.vertical
              ? 60
              : hideLabel
              ? 52
              : 64,
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
                  borderRadius: BorderRadius.circular(12),
                  child: ConfigAwareWebsiteLogo.fromConfig(
                    config.auth,
                    width: logoSize,
                    height: logoSize,
                    customIconUrl: config.profileIcon?.url,
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
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                      color: selected
                          ? Kurumi.themeOf(context)
                              .colorScheme
                              .onSecondaryContainer
                          : Kurumi.themeOf(context)
                              .colorScheme
                              .onSurfaceVariant,
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

    return KurumiTooltip(
      message: config.name,
      placement: switch (direction) {
        Axis.horizontal => Placement.top,
        Axis.vertical => Placement.right,
      },
      child: child,
    );
  }
}
