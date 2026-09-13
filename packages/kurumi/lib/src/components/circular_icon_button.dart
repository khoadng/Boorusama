import 'package:material_ui/material_ui.dart';

import '../theme/semantic_tokens.dart';
import '../theme/theme.dart';

class KurumiCircularIconButton extends StatelessWidget {
  const KurumiCircularIconButton({
    required this.icon,
    super.key,
    this.onPressed,
    this.semanticLabel,
    this.padding,
    this.backgroundColor,
    this.iconColor,
    this.constraints,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? iconColor;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    final semanticColors =
        KurumiTheme.maybeOf(context)?.data.semanticColors ??
        KurumiSemanticColors.fromMaterial(Theme.of(context));

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      child: ConstrainedBox(
        constraints:
            constraints ??
            const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
        child: Material(
          color: backgroundColor ?? semanticColors.overlay,
          shape: const CircleBorder(),
          child: InkWell(
            splashFactory: InkRipple.splashFactory,
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: Padding(
              padding: padding ?? const EdgeInsets.all(8),
              child: Theme(
                data: Theme.of(context).copyWith(
                  iconTheme: Theme.of(context).iconTheme.copyWith(
                    color: iconColor ?? semanticColors.onOverlay,
                  ),
                ),
                child: icon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
