// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/theme.dart';

class CircularIconButton extends StatelessWidget {
  const CircularIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.padding,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.extendedColorScheme.surfaceContainerOverlay,
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
                    color:
                        context.extendedColorScheme.onSurfaceContainerOverlay,
                  ),
            ),
            child: icon,
          ),
        ),
      ),
    );
  }
}
