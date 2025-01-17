// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import '../boorus/booru/booru.dart';
import '../configs/config.dart';
import '../configs/ref.dart';
import '../http/providers.dart';
import '../images/providers.dart';
import '../posts/sources/source.dart';

class BooruLogo extends ConsumerWidget {
  const BooruLogo({
    required this.source,
    super.key,
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
  Widget build(BuildContext context, WidgetRef ref) {
    if (_isFixedIcon) {
      return _buildAssetImage(source);
    }

    final config = ref.watchConfigAuth;
    final dio = ref.watch(dioProvider(config));

    return PostSource.from(source).whenWeb(
      (s) => FittedBox(
        child: s.faviconType == FaviconType.network
            ? ExtendedImage.network(
                dio: dio,
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
