// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';

// Project imports:
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class CustomContextMenuOverlay extends StatelessWidget {
  const CustomContextMenuOverlay({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ContextMenuOverlay(
      cardBuilder: (context, children) => Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(children: children),
        ),
      ),
      buttonBuilder: (context, config, [__]) => ContextMenuTile(config: config),
      child: child,
    );
  }
}

class ContextMenuTile extends StatefulWidget {
  const ContextMenuTile({
    super.key,
    required this.config,
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
        child: Material(
          color: Colors.transparent,
          child: Ink(
            child: ListTile(
              dense: true,
              visualDensity: const ShrinkVisualDensity(),
              hoverColor: widget.config.labelStyle == null
                  ? context.colorScheme.primary
                  : widget.config.labelStyle!.color,
              onTap: widget.config.onPressed,
              title: isMouseOver
                  ? Text(
                      widget.config.label,
                      style: widget.config.labelStyle != null
                          ? widget.config.labelStyle!
                              .copyWith(color: context.colorScheme.onError)
                          : TextStyle(
                              color: context.colorScheme.onPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                    )
                  : Text(
                      widget.config.label,
                      style: widget.config.labelStyle,
                    ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              minVerticalPadding: 0,
            ),
          ),
        ),
      ),
    );
  }
}
