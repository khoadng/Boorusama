// Flutter imports:
import 'dart:math' as math;

import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/notes/notes.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/widgets/widgets.dart';
import 'package:boorusama/core/application/api/api.dart';
import 'interactive_image.dart';

class PostMediaItem extends StatefulWidget {
  const PostMediaItem({
    super.key,
    required this.post,
    required this.onCached,
    this.enableNotes = true,
    this.onTap,
    this.onZoomUpdated,
    required this.notes,
    this.previewCacheManager,
  });

  final Post post;
  final List<Note> notes;
  final void Function(String? path) onCached;
  final bool enableNotes;
  final VoidCallback? onTap;
  final void Function(bool zoom)? onZoomUpdated;
  final CacheManager? previewCacheManager;

  @override
  State<PostMediaItem> createState() => _PostMediaItemState();
}

class _PostMediaItemState extends State<PostMediaItem> {
  late final String videoHtml = '''
            <center>
              <video controls allowfulscreen width="100%" height="100%" controlsList="nodownload" style="background-color:black;vertical-align: middle;display: inline-block;" autoplay muted loop>
                <source src=${widget.post.normalImageUrl}#t=0.01 type="video/webm" />
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
        ? p.extension(widget.post.normalImageUrl) == '.webm'
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
                    httpHeaders: const {
                      'User-Agent': userAgent,
                    },
                    imageUrl: widget.post.normalImageUrl,
                    imageBuilder: (context, imageProvider) {
                      DefaultCacheManager()
                          .getFileFromCache(widget.post.normalImageUrl)
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
                          if (widget.enableNotes)
                            ...widget.notes
                                .map((e) => e.adjustNoteCoordFor(
                                      widget.post,
                                      widthConstraint: constraints.maxWidth,
                                      heightConstraint: constraints.maxHeight,
                                    ))
                                .map((e) => PostNote(
                                      coordinate: e.coordinate,
                                      content: e.content,
                                    )),
                        ],
                      );
                    },
                    placeholderFadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                    fadeInDuration: Duration.zero,
                    placeholder: (context, url) => CachedNetworkImage(
                      httpHeaders: const {
                        'User-Agent': userAgent,
                      },
                      fit: BoxFit.fill,
                      imageUrl: widget.post.previewImageUrl,
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
