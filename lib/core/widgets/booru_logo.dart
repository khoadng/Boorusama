// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/core/boorus.dart';
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/core/images/dio_extended_image.dart';
import 'package:boorusama/core/images/providers.dart';
import 'package:boorusama/core/posts/sources.dart';

class BooruLogo extends StatelessWidget {
  const BooruLogo({
    super.key,
    required this.source,
    this.width,
    this.height,
  }) : _isFixedIcon = false;

  BooruLogo.fromConfig(
    BooruConfigAuth config, {
    super.key,
    this.width,
    this.height,
  })  : source = _sourceFromType(config.booruType, config.url),
        _isFixedIcon = _isFixed(config.booruType);

  BooruLogo.fromBooruType(
    BooruType booruType,
    String url, {
    super.key,
    this.width,
    this.height,
  })  : source = _sourceFromType(booruType, url),
        _isFixedIcon = _isFixed(booruType);

  static String _sourceFromType(BooruType booruType, String url) =>
      booruType == BooruType.hydrus ? 'assets/images/hydrus-logo.png' : url;

  static bool _isFixed(BooruType booruType) => booruType == BooruType.hydrus;

  final String source;
  final double? width;
  final double? height;
  final bool _isFixedIcon;

  @override
  Widget build(BuildContext context) {
    if (_isFixedIcon) {
      return _buildAssetImage(source);
    }

    return PostSource.from(source).whenWeb(
      (s) => FittedBox(
        child: s.faviconType == FaviconType.network
            ? DioExtendedImage.network(
                s.faviconUrl,
                width: width ?? 24,
                height: height ?? 24,
                fit: BoxFit.cover,
                clearMemoryCacheIfFailed: false,
                cacheMaxAge: kDefaultImageCacheDuration,
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
            : _buildAssetImage(s.faviconUrl),
      ),
      () => const SizedBox.shrink(),
    );
  }

  Widget _buildAssetImage(url) {
    return Image.asset(
      url,
      width: width ?? 28,
      height: height ?? 28,
      fit: BoxFit.cover,
    );
  }
}
