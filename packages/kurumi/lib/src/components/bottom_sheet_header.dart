import 'package:material_ui/material_ui.dart';
import 'package:material_symbols_icons/symbols.dart';

class KurumiBottomSheetHeader extends StatelessWidget {
  const KurumiBottomSheetHeader({
    required this.title,
    required this.closeTooltip,
    required this.confirmTooltip,
    required this.onClose,
    required this.onConfirm,
    super.key,
    this.isConfirming = false,
  });

  final String title;
  final String closeTooltip;
  final String confirmTooltip;
  final VoidCallback? onClose;
  final VoidCallback? onConfirm;
  final bool isConfirming;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Row(
        children: [
          _HeaderAction(
            tooltip: closeTooltip,
            icon: Symbols.close,
            onPressed: onClose,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _HeaderAction(
            tooltip: confirmTooltip,
            icon: Icons.check_rounded,
            iconSize: 34,
            foregroundColor: colorScheme.primary,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
            onPressed: onConfirm,
            child: isConfirming
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.foregroundColor,
    this.backgroundColor,
    this.iconSize = 28,
    this.child,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final double iconSize;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: tooltip,
      iconSize: iconSize,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(52),
        shape: const CircleBorder(),
        foregroundColor: foregroundColor ?? colorScheme.onSurface,
        disabledForegroundColor: colorScheme.outline,
        backgroundColor:
            backgroundColor ??
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        disabledBackgroundColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.24,
        ),
      ),
      onPressed: onPressed,
      icon: child ?? Icon(icon),
    );
  }
}
