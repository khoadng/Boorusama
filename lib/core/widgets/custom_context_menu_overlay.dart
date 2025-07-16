// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../foundation/display.dart';
import '../settings/providers.dart';
import '../settings/settings.dart';

class CustomContextMenuOverlay extends ConsumerWidget {
  const CustomContextMenuOverlay({
    required this.child,
    super.key,
    this.backgroundColor,
  });

  final Color? backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hapticFeedbackLevel = ref.watch(
      settingsProvider.select((s) => s.hapticFeedbackLevel),
    );

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
      buttonBuilder: (context, config, [_]) => ContextMenuTile(config: config),
      hapticFeedbackOnStart: hapticFeedbackLevel != HapticFeedbackLevel.none,
      child: child,
    );
  }
}

class ContextMenuTile extends StatefulWidget {
  const ContextMenuTile({
    required this.config,
    super.key,
  });

  final ContextMenuButtonConfig config;

  @override
  State<ContextMenuTile> createState() => _ContextMenuTileState();
}

class _ContextMenuTileState extends State<ContextMenuTile> {
  var isMouseOver = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isMouseOver = true),
      onExit: (_) => setState(() => isMouseOver = false),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 200),
        child: _Tile(
          hoverColor: widget.config.labelStyle == null
              ? Theme.of(context).colorScheme.primary
              : widget.config.labelStyle?.color,
          onTap: widget.config.onPressed,
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
                        color: kPreferredLayout.isMobile
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Theme.of(context).colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.75),
                      ),
                ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.title,
    this.onTap,
    this.hoverColor,
  });

  final Widget title;
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
            vertical: kPreferredLayout.isMobile ? 8 : 4,
            horizontal: 8,
          ),
          child: Row(
            children: [
              title,
            ],
          ),
        ),
      ),
    );
  }
}
