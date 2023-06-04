// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

// Project imports:
import 'package:boorusama/boorus/core/feats/bookmarks/bookmarks.dart';
import 'package:boorusama/boorus/core/pages/embedded_webview_webm.dart';
import 'package:boorusama/boorus/core/pages/interactive_image.dart';
import 'package:boorusama/boorus/core/pages/post_video.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/foundation/theme/theme_mode.dart';

class BookmarkMediaItem extends ConsumerStatefulWidget {
  const BookmarkMediaItem({
    super.key,
    required this.bookmark,
    this.onTap,
    this.onZoomUpdated,
    this.previewCacheManager,
  });

  final Bookmark bookmark;
  final VoidCallback? onTap;
  final void Function(bool zoom)? onZoomUpdated;
  final CacheManager? previewCacheManager;

  @override
  ConsumerState<BookmarkMediaItem> createState() => _PostMediaItemState();
}

class _PostMediaItemState extends ConsumerState<BookmarkMediaItem> {
  final transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    transformationController.addListener(() {
      final clampedMatrix = Matrix4.diagonal3Values(
        transformationController.value.right.x,
        transformationController.value.up.y,
        transformationController.value.forward.z,
      );

      widget.onZoomUpdated?.call(!clampedMatrix.isIdentity());
    });
  }

  @override
  void dispose() {
    transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return widget.bookmark.isVideo
        ? p.extension(widget.bookmark.sampleUrl) == '.webm'
            ? EmbeddedWebViewWebm(
                url: widget.bookmark.sampleUrl,
                backgroundColor:
                    theme == ThemeMode.light ? Colors.white : Colors.black,
              )
            : BooruVideo(
                url: widget.bookmark.sampleUrl,
                aspectRatio: widget.bookmark.aspectRatio,
              )
        : InteractiveImage(
            useOriginalSize: false,
            onTap: widget.onTap,
            transformationController: transformationController,
            image: Hero(
              tag: '${widget.bookmark.id}_hero',
              child: AspectRatio(
                aspectRatio: widget.bookmark.aspectRatio,
                child: LayoutBuilder(
                  builder: (context, constraints) => CachedNetworkImage(
                    httpHeaders: {
                      'User-Agent':
                          ref.watch(userAgentGeneratorProvider).generate(),
                    },
                    imageUrl: widget.bookmark.sampleUrl,
                    imageBuilder: (context, imageProvider) {
                      final w = math.max(
                        constraints.maxWidth,
                        MediaQuery.of(context).size.width,
                      );

                      final h = math.max(
                        constraints.maxHeight,
                        MediaQuery.of(context).size.height,
                      );

                      return Image(
                        width: w,
                        height: h,
                        fit: BoxFit.contain,
                        image: imageProvider,
                      );
                    },
                    placeholderFadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                    fadeInDuration: Duration.zero,
                    placeholder: (context, url) => CachedNetworkImage(
                      httpHeaders: {
                        'User-Agent':
                            ref.watch(userAgentGeneratorProvider).generate(),
                      },
                      fit: BoxFit.fill,
                      imageUrl: widget.bookmark.thumbnailUrl,
                      cacheManager: widget.previewCacheManager,
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      progressIndicatorBuilder: (context, url, progress) =>
                          FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          height: widget.bookmark.height,
                          width: widget.bookmark.width,
                          child: Stack(children: [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: LinearProgressIndicator(
                                value: progress.progress,
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
