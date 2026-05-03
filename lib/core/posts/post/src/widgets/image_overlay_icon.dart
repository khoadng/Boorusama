// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../themes/theme/types.dart';

class ImageOverlayIcon extends StatelessWidget {
  const ImageOverlayIcon({
    required this.icon,
    super.key,
    this.size,
  });

  final IconData icon;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: context.extendedColorScheme.surfaceContainerOverlayDim,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Icon(
        icon,
        color: context.extendedColorScheme.onSurfaceContainerOverlayDim,
        size: size ?? 18,
        weight: 700,
      ),
    );
  }
}
