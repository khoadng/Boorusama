// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

// Project imports:
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts/sources/source_utils.dart';

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
        minWidth: 20,
        minHeight: 20,
        maxWidth: 20,
        maxHeight: 20,
      ),
      child: CachedNetworkImage(
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 100),
        fadeOutDuration: const Duration(milliseconds: 200),
        imageUrl: getFavicon(booru.url),
      ),
    );
  }
}
