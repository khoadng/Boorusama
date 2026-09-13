import 'package:context_menus/context_menus.dart';
import 'package:material_ui/material_ui.dart';

import '../accessibility/behavior.dart';
import '../theme/theme.dart';

class KurumiCustomContextMenuOverlay extends StatelessWidget {
  const KurumiCustomContextMenuOverlay({
    required this.child,
    required this.mobileLayout,
    super.key,
    this.backgroundColor,
  });

  final Color? backgroundColor;
  final Widget child;
  final bool mobileLayout;

  @override
  Widget build(BuildContext context) {
    final behavior =
        KurumiTheme.maybeBehaviorOf(context) ?? const KurumiBehaviorData();

    return ContextMenuOverlay(
      cardBuilder: (context, children) => Material(
        color:
            backgroundColor ?? Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(4),
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(children: children),
        ),
      ),
      buttonBuilder: (context, config, [_]) => _KurumiContextMenuTile(
        config: config,
        mobileLayout: mobileLayout,
      ),
      hapticFeedbackOnStart: behavior.contextMenuStartFeedbackEnabled,
      child: child,
    );
  }
}

class _KurumiContextMenuTile extends StatefulWidget {
  const _KurumiContextMenuTile({
    required this.config,
    required this.mobileLayout,
  });

  final ContextMenuButtonConfig config;
  final bool mobileLayout;

  @override
  State<_KurumiContextMenuTile> createState() => _KurumiContextMenuTileState();
}

class _KurumiContextMenuTileState extends State<_KurumiContextMenuTile> {
  var isMouseOver = false;

  @override
  Widget build(BuildContext context) {
    final behavior =
        KurumiTheme.maybeBehaviorOf(context) ?? const KurumiBehaviorData();

    void handleTap() {
      behavior.contextMenuSelectionFeedback?.call();
      widget.config.onPressed?.call();
    }

    return MouseRegion(
      onEnter: (_) => setState(() => isMouseOver = true),
      onExit: (_) => setState(() => isMouseOver = false),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 200),
        child: Semantics(
          button: true,
          enabled: widget.config.onPressed != null,
          label: widget.config.label,
          onTap: widget.config.onPressed != null ? handleTap : null,
          excludeSemantics: true,
          child: _KurumiContextMenuTileSurface(
            mobileLayout: widget.mobileLayout,
            hoverColor: widget.config.labelStyle == null
                ? Theme.of(context).colorScheme.primary
                : widget.config.labelStyle?.color,
            onTap: handleTap,
            title: isMouseOver
                ? Text(
                    widget.config.label,
                    style: widget.config.labelStyle != null
                        ? widget.config.labelStyle?.copyWith(
                            color: Theme.of(context).colorScheme.onError,
                          )
                        : TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                  )
                : Text(
                    widget.config.label,
                    style:
                        widget.config.labelStyle ??
                        TextStyle(
                          color: widget.mobileLayout
                              ? Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant
                              : Theme.of(context).colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.75),
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _KurumiContextMenuTileSurface extends StatelessWidget {
  const _KurumiContextMenuTileSurface({
    required this.title,
    required this.mobileLayout,
    this.onTap,
    this.hoverColor,
  });

  final Widget title;
  final bool mobileLayout;
  final VoidCallback? onTap;
  final Color? hoverColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        hoverColor: hoverColor,
        onTap: onTap,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: mobileLayout ? 8 : 4,
            horizontal: 8,
          ),
          child: Row(
            children: [title],
          ),
        ),
      ),
    );
  }
}
