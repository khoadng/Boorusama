// Flutter imports:
import 'package:anchor_ui/anchor_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../foundation/display.dart';
import '../../../../../foundation/platform.dart';
import '../../../../../foundation/toast.dart';
import '../../../../config_widgets/website_logo.dart';
import '../../../../widgets/booru_tooltip.dart';
import '../../../../widgets/context_menu_tile.dart';
import '../../../config/types.dart';
import '../../../create/routes.dart';
import '../pages/remove_booru_alert_dialog.dart';
import '../providers/booru_config_provider.dart';
import 'drag_state_controller.dart';

class BooruSelectorItem extends StatelessWidget {
  const BooruSelectorItem({
    required this.config,
    required this.onTap,
    required this.selected,
    required this.dragController,
    required this.index,
    required this.showMenuIndex,
    super.key,
    this.direction = Axis.vertical,
    this.hideLabel = false,
  });

  final BooruConfig config;
  final bool selected;
  final void Function() onTap;
  final Axis direction;
  final bool hideLabel;
  final DragStateController dragController;
  final int index;
  final ValueNotifier<int?> showMenuIndex;

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
          onTap: onTap,
          child: ListenableBuilder(
            listenable: dragController,
            builder: (context, _) => BooruSelectorContextMenu(
              config: config,
              direction: direction,
              index: index,
              showMenuIndex: showMenuIndex,
              child: _PopoverTooltip(
                hideLabel: hideLabel && !dragController.isDragging,
                direction: direction,
                config: config,
                child: _build(context, logoSize),
              ),
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

    return BooruTooltip(
      message: config.name,
      placement: switch (direction) {
        Axis.horizontal => Placement.top,
        Axis.vertical => Placement.right,
      },
      child: child,
    );
  }
}

class BooruSelectorContextMenu extends StatefulWidget {
  const BooruSelectorContextMenu({
    super.key,
    required this.direction,
    required this.config,
    required this.showMenuIndex,
    required this.index,
    required this.child,
  });

  final Axis direction;
  final Widget child;
  final BooruConfig config;
  final int index;
  final ValueNotifier<int?> showMenuIndex;

  @override
  State<BooruSelectorContextMenu> createState() =>
      _BooruSelectorContextMenuState();
}

class _BooruSelectorContextMenuState extends State<BooruSelectorContextMenu> {
  final controller = AnchorController();

  @override
  void initState() {
    super.initState();
    widget.showMenuIndex.addListener(_showMenuListener);
  }

  @override
  void dispose() {
    widget.showMenuIndex.removeListener(_showMenuListener);
    controller.dispose();
    super.dispose();
  }

  void _showMenuListener() {
    // if (widget.showMenuIndex.value == widget.index) {
    //   if (!controller.isShowing) {
    //     print('Showing context menu for index ${widget.index}');
    //     controller.show();
    //   }
    // } else {
    //   if (controller.isShowing) {
    //     print('Hiding context menu for index ${widget.index}');
    //     // controller.hide();
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = isDesktopPlatform();

    return RawAnchor(
      controller: controller,
      placement: switch (widget.direction) {
        Axis.horizontal => Placement.top,
        Axis.vertical => Placement.right,
      },
      middlewares: const [
        OffsetMiddleware(mainAxis: OffsetValue.value(4)),
        FlipMiddleware(),
        ShiftMiddleware(),
      ],
      backdropBuilder: (context) => GestureDetector(
        onTap: () {
          controller.hide();
        },
        child: Container(
          color: isDesktop
              ? Colors.transparent
              : Colors.black.withValues(alpha: 0.75),
        ),
      ),
      overlayBuilder: (context) => Container(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 4,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          boxShadow: kElevationToShadow[4],
          border: Border.all(
            color: colorScheme.outlineVariant,
          ),
        ),
        constraints: const BoxConstraints(
          maxWidth: 200,
        ),
        child: Consumer(
          builder: (_, ref, _) {
            final notifier = ref.watch(booruConfigProvider.notifier);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ContextMenuTile(
                  title: context.t.generic.action.edit,
                  onTap: () => goToUpdateBooruConfigPage(
                    ref,
                    config: widget.config,
                  ),
                ),
                ContextMenuTile(
                  title: context.t.generic.action.duplicate,
                  onTap: () => notifier.duplicate(config: widget.config),
                ),
                ContextMenuTile(
                  title: context.t.generic.action.delete,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      routeSettings: const RouteSettings(
                        name: 'booru/delete',
                      ),
                      builder: (context) => RemoveBooruConfigAlertDialog(
                        title: context.t.booru.deletion.title(
                          profileName: widget.config.name,
                        ),
                        description: context.t.booru.deletion.confirmation,
                        onConfirm: () => notifier.delete(
                          widget.config,
                          onFailure: (message) =>
                              showErrorToast(context, message),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
      child: widget.child,
    );
  }
}
