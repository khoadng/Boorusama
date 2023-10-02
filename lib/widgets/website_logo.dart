// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';

class WebsiteLogo extends StatelessWidget {
  const WebsiteLogo({
    super.key,
    required this.url,
    this.size = 32,
  });

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: size,
        maxHeight: size,
        minWidth: size,
        minHeight: size,
      ),
      child: ExtendedImage.network(
        url,
        fit: BoxFit.cover,
        loadStateChanged: (state) =>
            state.extendedImageLoadState == LoadState.failed
                ? const Icon(Icons.arrow_outward)
                : null,
      ),
    );
  }
}
