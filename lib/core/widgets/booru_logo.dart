// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../boorus/booru/booru.dart';
import '../configs/config.dart';
import '../posts/sources/source.dart';
import 'widgets.dart';

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

  final String? source;
  final double? width;
  final double? height;
  final bool _isFixedIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_isFixedIcon) {
      return _buildAssetImage(source);
    }

    return PostSource.from(source).whenWeb(
      (s) => FittedBox(
        child: s.faviconType == FaviconType.network
            ? WebsiteLogo(
                url: s.faviconUrl,
                size: width ?? _kFallbackSize,
              )
            : _buildAssetImage(s.faviconUrl),
      ),
      () => WebsiteLogo(
        url: source,
        size: width ?? _kFallbackSize,
      ),
    );
  }

  Widget _buildAssetImage(url) {
    return Image.asset(
      url,
      width: width ?? _kFallbackSize,
      height: height ?? _kFallbackSize,
      fit: BoxFit.cover,
    );
  }
}

const _kFallbackSize = 28.0;
