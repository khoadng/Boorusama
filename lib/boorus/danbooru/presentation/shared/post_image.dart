// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PostImage extends StatelessWidget {
  const PostImage({
    Key? key,
    required this.imageUrl,
    this.placeholderUrl,
    this.borderRadius,
    this.cacheManager,
    this.memCacheHeight,
    this.memCacheWidth,
  }) : super(key: key);

  final String imageUrl;
  final String? placeholderUrl;
  final BorderRadius? borderRadius;
  final CacheManager? cacheManager;
  final int? memCacheWidth;
  final int? memCacheHeight;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      cacheManager: cacheManager,
      memCacheHeight: memCacheHeight,
      memCacheWidth: memCacheWidth,
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        );
      },
      placeholder: (context, url) => Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          color: Theme.of(context).cardColor,
        ),
      ),
      errorWidget: (context, url, error) =>
          const Center(child: Icon(Icons.error)),
      fadeInDuration: const Duration(microseconds: 10),
    );
  }
}
