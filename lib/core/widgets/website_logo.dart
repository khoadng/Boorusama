// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cache_manager/cache_manager.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const _unknownSize = 26.0;
const kFaviconSize = 32.0;

double? _calcFailedIconSize(
  double size, {
  double defaultSize = _unknownSize,
  double referenceSize = kFaviconSize,
}) {
  final ratio = defaultSize / referenceSize;

  return size * ratio;
}

class WebsiteLogo extends StatelessWidget {
  const WebsiteLogo({
    required this.url,
    required this.dio,
    super.key,
    this.size = kFaviconSize,
    this.cacheManager,
  });

  final String? url;
  final double size;
  final Dio dio;
  final CacheManager? cacheManager;

  @override
  Widget build(BuildContext context) {
    final url = this.url;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: size,
        maxHeight: size,
        minWidth: size,
        minHeight: size,
      ),
      child: url != null
          ? ExtendedImage.network(
              url,
              dio: dio,
              clearMemoryCacheIfFailed: false,
              fit: BoxFit.cover,
              fetchStrategy: const FetchStrategyBuilder(
                maxAttempts: 1,
                timeout: Duration(seconds: 5),
                initialPauseBetweenRetries: Duration(milliseconds: 100),
                silent: true,
              ),
              placeholderWidget: Container(
                padding: const EdgeInsets.all(8),
                child: const CircularProgressIndicator(
                  strokeWidth: 1.5,
                ),
              ),
              cacheManager: cacheManager,
              errorWidget: _buildFallback(),
            )
          : _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Card(
      child: FaIcon(
        FontAwesomeIcons.globe,
        size: _calcFailedIconSize(size),
        color: Colors.blue,
      ),
    );
  }
}
