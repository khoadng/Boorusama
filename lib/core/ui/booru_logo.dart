// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

// Project imports:
import 'package:boorusama/core/domain/boorus.dart';

class BooruLogo extends StatelessWidget {
  const BooruLogo({
    super.key,
    required this.booru,
  });

  final Booru booru;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 28,
        minHeight: 28,
        maxWidth: 28,
        maxHeight: 28,
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 100),
          fadeOutDuration: const Duration(milliseconds: 200),
          imageUrl: booru.getIconUrl(),
        ),
      ),
    );
  }
}
