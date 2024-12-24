// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import '../images/dio_extended_image.dart';
import '../images/providers.dart';

const _unknownSize = 26.0;
const _faviconSize = 32.0;

double? _calcFailedIconSize(
  double size, {
  double defaultSize = _unknownSize,
  double referenceSize = _faviconSize,
}) {
  final ratio = defaultSize / referenceSize;

  return size * ratio;
}

class WebsiteLogo extends StatelessWidget {
  const WebsiteLogo({
    required this.url,
    super.key,
    this.size = _faviconSize,
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
      child: DioExtendedImage.network(
        url,
        clearMemoryCacheIfFailed: false,
        cacheMaxAge: kDefaultImageCacheDuration,
        fit: BoxFit.cover,
        loadStateChanged: (state) => switch (state.extendedImageLoadState) {
          LoadState.failed => Card(
              child: FaIcon(
                FontAwesomeIcons.globe,
                size: _calcFailedIconSize(size),
                color: Colors.blue,
              ),
            ),
          LoadState.loading => Container(
              padding: const EdgeInsets.all(6),
              child: const CircularProgressIndicator(
                strokeWidth: 1,
              ),
            ),
          _ => state.completedWidget,
        },
      ),
    );
  }
}
