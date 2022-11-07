// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/note/note.dart';
import 'package:boorusama/boorus/danbooru/domain/notes/notes.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/post_image_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/widgets/widgets.dart';

class PostMediaItem extends StatefulWidget {
  const PostMediaItem({
    super.key,
    required this.post,
    required this.onCached,
    this.enableNotes = true,
    this.onTap,
    this.onZoomUpdated,
  });

  final Post post;
  final void Function(String? path) onCached;
  final bool enableNotes;
  final VoidCallback? onTap;
  final void Function(bool zoom)? onZoomUpdated;

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
        : BlocBuilder<NoteBloc, AsyncLoadState<List<Note>>>(
            builder: (context, state) {
              return InteractiveImage(
                useOriginalSize: false,
                onTap: widget.onTap,
                transformationController: transformationController,
                image: Stack(
                  children: [
                    Hero(
                      tag: '${widget.post.id}_hero',
                      child: AspectRatio(
                        aspectRatio: widget.post.aspectRatio,
                        child: LayoutBuilder(
                          builder: (context, constraints) => CachedNetworkImage(
                            imageUrl: widget.post.normalImageUrl,
                            imageBuilder: (context, imageProvider) {
                              final widthPercent =
                                  constraints.maxWidth / widget.post.width;
                              final heightPercent =
                                  constraints.maxHeight / widget.post.height;

                              DefaultCacheManager()
                                  .getFileFromCache(widget.post.normalImageUrl)
                                  .then((file) {
                                if (!mounted) return;
                                widget.onCached(file!.file.path);
                              });

                              return Stack(
                                children: [
                                  Image(image: imageProvider),
                                  if (state.data != null && widget.enableNotes)
                                    ...state.data!.map((e) => PostNote(
                                          coordinate: NoteCoordinate(
                                            x: e.coordinate.x * widthPercent,
                                            y: e.coordinate.y * heightPercent,
                                            height: e.coordinate.height *
                                                heightPercent,
                                            width: e.coordinate.width *
                                                widthPercent,
                                          ),
                                          content: e.content,
                                        )),
                                ],
                              );
                            },
                            placeholderFadeInDuration: Duration.zero,
                            fadeOutDuration: Duration.zero,
                            fadeInDuration: Duration.zero,
                            placeholder: (context, url) => CachedNetworkImage(
                              fit: BoxFit.fill,
                              imageUrl: widget.post.previewImageUrl,
                              fadeInDuration: Duration.zero,
                              fadeOutDuration: Duration.zero,
                              progressIndicatorBuilder:
                                  (context, url, progress) => FittedBox(
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
                  ],
                ),
              );
            },
          );
  }
}
