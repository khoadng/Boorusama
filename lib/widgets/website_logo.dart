// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

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
      child: CachedNetworkImage(
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 50),
        fadeOutDuration: const Duration(milliseconds: 50),
        imageUrl: url,
        errorWidget: (context, url, error) => const Icon(Icons.arrow_outward),
        errorListener: (e) {
          // Ignore error
        },
      ),
    );
  }
}
