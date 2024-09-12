// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/core/posts/posts.dart';

class BooruLogo extends StatelessWidget {
  const BooruLogo({
    super.key,
    required this.source,
    this.width,
    this.height,
  });

  final String source;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return PostSource.from(source).whenWeb(
      (s) => FittedBox(
        child: s.faviconType == FaviconType.network
            ? ExtendedImage.network(
                s.faviconUrl,
                width: width ?? 24,
                height: height ?? 24,
                fit: BoxFit.cover,
                clearMemoryCacheIfFailed: false,
                loadStateChanged: (state) =>
                    switch (state.extendedImageLoadState) {
                  LoadState.failed => FaIcon(
                      FontAwesomeIcons.globe,
                      size: width,
                      color: Colors.blue,
                    ),
                  _ => state.completedWidget,
                },
              )
            : Image.asset(
                s.faviconUrl,
                width: width ?? 28,
                height: height ?? 28,
                fit: BoxFit.cover,
              ),
      ),
      () => const SizedBox.shrink(),
    );
  }
}
