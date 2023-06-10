// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

class WebsiteLogo extends StatelessWidget {
  const WebsiteLogo({
    super.key,
    required this.url,
  });

  final String url;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 32,
        minHeight: 32,
        maxWidth: 32,
        maxHeight: 32,
      ),
      child: CachedNetworkImage(
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 50),
        fadeOutDuration: const Duration(milliseconds: 50),
        imageUrl: url,
      ),
    );
  }
}
