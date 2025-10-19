// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/material_symbols_icons.dart';

class DesktopVideoOptionTile extends StatefulWidget {
  const DesktopVideoOptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.value,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? value;
  final void Function() onTap;

  @override
  State<DesktopVideoOptionTile> createState() => _DesktopVideoOptionTileState();
}

class _DesktopVideoOptionTileState extends State<DesktopVideoOptionTile> {
  var _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: _isHovered
              ? const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                )
              : const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
          child: Container(
            padding: _isHovered
                ? const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  )
                : null,
            decoration: BoxDecoration(
              color: _isHovered
                  ? colorScheme.onSurface.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 20,
                  color: colorScheme.onSurface,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                if (widget.value case final value?) ...[
                  const SizedBox(width: 16),
                  Text(
                    value,
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Symbols.chevron_right,
                    size: 20,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
