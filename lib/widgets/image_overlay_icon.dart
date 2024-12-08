// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/theme.dart';

class ImageOverlayIcon extends StatelessWidget {
  const ImageOverlayIcon({
    super.key,
    required this.icon,
    this.size,
  });

  final IconData icon;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: context.extendedColorScheme.surfaceContainerOverlayDim,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Icon(
        icon,
        color: context.extendedColorScheme.onSurfaceContainerOverlayDim,
        size: size,
      ),
    );
  }
}
