// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';

// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';

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
      child: ExtendedImage.network(
        source.faviconUrl,
        fit: BoxFit.cover,
        enableLoadState: false,
      ),
    );
  }
}
