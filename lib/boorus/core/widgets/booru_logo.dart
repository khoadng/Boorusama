// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';

class BooruLogo extends StatelessWidget {
  const BooruLogo({
    super.key,
    required this.source,
    this.width,
    this.height,
  });

  final WebSource source;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 25,
        minHeight: 25,
        maxWidth: width ?? 25,
        maxHeight: height ?? 25,
      ),
      child: CachedNetworkImage(
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 100),
        fadeOutDuration: const Duration(milliseconds: 200),
        imageUrl: source.faviconUrl,
        errorWidget: (context, url, error) => const SizedBox.shrink(),
        errorListener: (e) {
          // Ignore error
        },
      ),
    );
  }
}
