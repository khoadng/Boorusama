// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../boorus/booru/types.dart';
import '../configs/config/types.dart';
import '../http/client/providers.dart';
import '../images/providers.dart';
import '../posts/sources/types.dart';
import '../widgets/website_logo.dart';

class ConfigAwareWebsiteLogo extends ConsumerWidget {
  const ConfigAwareWebsiteLogo({
    required this.url,
    super.key,
    this.size = kFaviconSize,
    this.width,
    this.height,
  }) : _isFixedIcon = false;

  ConfigAwareWebsiteLogo.fromConfig(
    BooruConfigAuth config, {
    super.key,
    this.width,
    this.height,
  }) : url = _sourceFromType(config.booruType, config.url),
       size = kFaviconSize,
       _isFixedIcon = _isFixed(config.booruType);

  ConfigAwareWebsiteLogo.fromBooruType(
    BooruType booruType,
    String url, {
    super.key,
    this.width,
    this.height,
  }) : url = _sourceFromType(booruType, url),
       size = kFaviconSize,
       _isFixedIcon = _isFixed(booruType);

  static String _sourceFromType(BooruType booruType, String url) =>
      booruType == BooruType.hydrus ? 'assets/images/hydrus-logo.png' : url;

  static bool _isFixed(BooruType booruType) => booruType == BooruType.hydrus;

  final String? url;
  final double size;
  final double? width;
  final double? height;
  final bool _isFixedIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_isFixedIcon && url != null) {
      return _buildAssetImage(url!);
    }

    return PostSource.from(url).whenWeb(
      (s) => FittedBox(
        child: s.faviconType == FaviconType.network
            ? _buildWebsiteLogo(ref, s)
            : _buildAssetImage(s.faviconUrl),
      ),
      () => _buildWebsiteLogo(ref, null),
    );
  }

  Widget _buildWebsiteLogo(WidgetRef ref, WebSource? source) {
    final dio = ref.watch(faviconDioProvider);

    return WebsiteLogo(
      url: source?.faviconUrl,
      dio: dio,
      size: width ?? height ?? size,
      cacheManager: ref.watch(defaultImageCacheManagerProvider),
    );
  }

  Widget _buildAssetImage(String assetUrl) {
    return Image.asset(
      assetUrl,
      width: width ?? _kFallbackSize,
      height: height ?? _kFallbackSize,
      fit: BoxFit.cover,
    );
  }
}

const _kFallbackSize = 28.0;
