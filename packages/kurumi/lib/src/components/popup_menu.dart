import 'dart:math';

import 'package:anchor_ui/anchor_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';
import 'anchor.dart';
import 'focus_ring.dart';

class KurumiPopupMenuButton extends StatefulWidget {
  const KurumiPopupMenuButton({
    required this.items,
    super.key,
    this.iconColor,
    this.iconBackgroundColor,
    this.maxWidth,
    this.semanticLabel,
    this.icon,
    this.iconPadding = const EdgeInsets.all(6),
  });

  final List<Widget> items;
  final Color? iconColor;
  final double? maxWidth;
  final Color? iconBackgroundColor;
  final String? semanticLabel;
  final Widget? icon;
  final EdgeInsetsGeometry iconPadding;

  @override
  State<KurumiPopupMenuButton> createState() => _KurumiPopupMenuButtonState();
}

class _KurumiPopupMenuButtonState extends State<KurumiPopupMenuButton> {
  final _controller = AnchorController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuFeedback = KurumiTheme.maybeBehaviorOf(context)?.menuFeedback;

    void toggleMenu() {
      menuFeedback?.call();
      _controller.toggle();
    }

    return KurumiAnchor(
      controller: _controller,
      overlayBuilder: (context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        constraints: BoxConstraints(
          maxWidth: min(MediaQuery.widthOf(context), widget.maxWidth ?? 200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.items,
        ),
      ),
      child: Semantics(
        button: true,
        enabled: true,
        label: widget.semanticLabel,
        onTap: toggleMenu,
        child: Material(
          color: widget.iconBackgroundColor ?? Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: toggleMenu,
            child: Padding(
              padding: widget.iconPadding,
              child:
                  widget.icon ??
                  Icon(
                    Icons.more_vert,
                    color: widget.iconColor,
                    semanticLabel: widget.semanticLabel,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class KurumiPopupMenuItem extends StatelessWidget {
  const KurumiPopupMenuItem({
    required this.title,
    required this.onTap,
    super.key,
    this.icon,
  });

  final Widget title;
  final Widget? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = AnchorData.maybeOf(context)?.controller;

    void handleTap() {
      controller?.hide();
      onTap();
    }

    return Semantics(
      button: true,
      enabled: true,
      onTap: handleTap,
      child: KurumiFocusHighlight(
        builder: (context, highlighted) => Material(
          color: highlighted ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: handleTap,
            focusColor: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              child: IconTheme.merge(
                data: IconThemeData(
                  color: highlighted
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
                child: DefaultTextStyle.merge(
                  style: highlighted
                      ? TextStyle(color: colorScheme.onPrimary)
                      : null,
                  child: Row(
                    children: [
                      if (icon case final icon?)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: icon,
                        ),
                      Flexible(child: title),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
