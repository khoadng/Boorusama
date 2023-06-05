// Flutter imports:
import 'package:flutter/material.dart';

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
        color: Colors.black.withOpacity(0.7),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Icon(
        icon,
        color: Colors.white70,
        size: size,
      ),
    );
  }
}
