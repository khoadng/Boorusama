// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:boorusama/core/ui/embedded_webview_webm.dart';
import 'package:boorusama/core/ui/interactive_image.dart';
import 'package:boorusama/core/ui/post_video.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;

// Project imports:
import 'package:boorusama/core/domain/posts/post.dart';
import 'package:boorusama/core/domain/user_agent_generator.dart';

class GelbooruPostMediaItem extends StatefulWidget {
  const GelbooruPostMediaItem({
    super.key,
    required this.post,
    required this.onCached,
    this.onTap,
    this.onZoomUpdated,
    this.previewCacheManager,
  });

  final Post post;
  final void Function(String? path) onCached;
  final VoidCallback? onTap;
  final void Function(bool zoom)? onZoomUpdated;
  final CacheManager? previewCacheManager;

  @override
  State<GelbooruPostMediaItem> createState() => _PostMediaItemState();
}

class _PostMediaItemState extends State<GelbooruPostMediaItem> {
  late final String videoHtml = '''
            <center>
              <video controls allowfulscreen width="100%" height="100%" controlsList="nodownload" style="background-color:black;vertical-align: middle;display: inline-block;" autoplay muted loop>
                <source src=${widget.post.sampleImageUrl}#t=0.01 type="video/webm" />
              </video>
            </center>''';

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
    return widget.post.isVideo
        ? p.extension(widget.post.sampleImageUrl) == '.webm'
            ? EmbeddedWebViewWebm(videoHtml: videoHtml)
            : PostVideo(post: widget.post)
        : InteractiveImage(
            useOriginalSize: false,
            onTap: widget.onTap,
            transformationController: transformationController,
            image: Hero(
              tag: '${widget.post.id}_hero',
              child: AspectRatio(
                aspectRatio: widget.post.aspectRatio,
                child: LayoutBuilder(
                  builder: (context, constraints) => CachedNetworkImage(
                    httpHeaders: {
                      'User-Agent':
                          context.read<UserAgentGenerator>().generate(),
                    },
                    imageUrl: widget.post.sampleLargeImageUrl,
                    imageBuilder: (context, imageProvider) {
                      DefaultCacheManager()
                          .getFileFromCache(widget.post.sampleImageUrl)
                          .then((file) {
                        if (!mounted) return;
                        widget.onCached(file?.file.path);
                      });

                      final w = math.max(
                        constraints.maxWidth,
                        MediaQuery.of(context).size.width,
                      );

                      final h = math.max(
                        constraints.maxHeight,
                        MediaQuery.of(context).size.height,
                      );

                      return Stack(
                        children: [
                          Image(
                            width: w,
                            height: h,
                            fit: BoxFit.contain,
                            image: imageProvider,
                          ),
                        ],
                      );
                    },
                    placeholderFadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                    fadeInDuration: Duration.zero,
                    placeholder: (context, url) => CachedNetworkImage(
                      httpHeaders: {
                        'User-Agent':
                            context.read<UserAgentGenerator>().generate(),
                      },
                      fit: BoxFit.fill,
                      imageUrl: widget.post.thumbnailImageUrl,
                      cacheManager: widget.previewCacheManager,
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      progressIndicatorBuilder: (context, url, progress) =>
                          FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          height: widget.post.height,
                          width: widget.post.width,
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
