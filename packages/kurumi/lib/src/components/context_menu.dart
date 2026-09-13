import 'package:anchor_ui/anchor_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../accessibility/behavior.dart';
import '../foundation/platform.dart';
import '../theme/theme.dart';

class KurumiContextMenu extends StatelessWidget {
  const KurumiContextMenu({
    required this.child,
    required this.menuItemsBuilder,
    super.key,
  });

  final Widget child;
  final List<Widget> Function(BuildContext context) menuItemsBuilder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final behavior =
        KurumiTheme.maybeBehaviorOf(context) ?? const KurumiBehaviorData();

    return AnchorContextMenu(
      viewPadding: const EdgeInsets.all(8),
      backdropBuilder: kurumiIsMobilePlatform()
          ? null
          : (context) => Container(
              color: Colors.transparent,
            ),
      onShow: behavior.contextMenuShowFeedback,
      menuBuilder: (context) {
        return Container(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: menuItemsBuilder(context),
          ),
        );
      },
      childBuilder: (context) => KurumiAdaptiveContextMenuGestureTrigger(
        child: child,
      ),
    );
  }
}

class KurumiContextMenuDivider extends StatelessWidget {
  const KurumiContextMenuDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      endIndent: 12,
      indent: 12,
      height: 8,
    );
  }
}

class KurumiAdaptiveContextMenuGestureTrigger extends StatelessWidget {
  const KurumiAdaptiveContextMenuGestureTrigger({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: kurumiIsMobilePlatform()
          ? (details) {
              context.showMenu(details.globalPosition);
            }
          : null,
      onSecondaryTapDown: !kurumiIsMobilePlatform()
          ? (details) {
              context.showMenu(details.globalPosition);
            }
          : null,
      child: child,
    );
  }
}

class KurumiContextMenuTile extends StatelessWidget {
  const KurumiContextMenuTile({
    required this.title,
    super.key,
    this.onTap,
    this.enabled = true,
    this.hideOnTap = true,
  });

  final String title;
  final VoidCallback? onTap;
  final bool enabled;
  final bool hideOnTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final behavior =
        KurumiTheme.maybeBehaviorOf(context) ?? const KurumiBehaviorData();

    void handleTap() {
      if (hideOnTap) {
        context.hideMenu();
      }

      behavior.contextMenuSelectionFeedback?.call();
      onTap?.call();
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
        ),
        constraints: const BoxConstraints(
          minWidth: 200,
        ),
        child: Semantics(
          button: true,
          enabled: enabled,
          label: title,
          onTap: enabled ? handleTap : null,
          excludeSemantics: true,
          child: InkWell(
            hoverColor: enabled ? colorScheme.primary : Colors.transparent,
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onTap: enabled ? handleTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 8,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: enabled
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withValues(alpha: 0.38),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
