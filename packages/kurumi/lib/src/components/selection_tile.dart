import 'package:material_ui/material_ui.dart';
import 'package:material_symbols_icons/symbols.dart';

class KurumiDesktopSelectionTile extends StatefulWidget {
  const KurumiDesktopSelectionTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
    super.key,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final String? subtitle;

  @override
  State<KurumiDesktopSelectionTile> createState() =>
      _KurumiDesktopSelectionTileState();
}

class _KurumiDesktopSelectionTileState
    extends State<KurumiDesktopSelectionTile> {
  var _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: widget.isSelected,
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Material(
          color: _isHovered
              ? colorScheme.onSurface.withValues(alpha: 0.08)
              : Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: widget.isSelected
                        ? Icon(
                            Symbols.check,
                            size: 20,
                            color: colorScheme.onSurface,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        if (widget.subtitle case final subtitle?) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
