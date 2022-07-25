// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/router.dart';

class PostMediaItem extends StatefulWidget {
  const PostMediaItem({
    Key? key,
    required this.post,
    required this.onCached,
  }) : super(key: key);

  final Post post;
  final void Function(String? path) onCached;

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

  @override
  Widget build(BuildContext context) {
    if (widget.post.isVideo) {
      return p.extension(widget.post.normalImageUrl) == '.webm'
          ? EmbeddedWebViewWebm(videoHtml: videoHtml)
          : PostVideo(post: widget.post);
    } else {
      return GestureDetector(
        onTap: () {
          AppRouter.router.navigateTo(context, '/posts/image',
              routeSettings: RouteSettings(arguments: [widget.post]));
        },
        child: Hero(
          tag: '${widget.post.id}_hero',
          child: CachedNetworkImage(
            imageUrl: widget.post.normalImageUrl,
            imageBuilder: (context, imageProvider) {
              DefaultCacheManager()
                  .getFileFromCache(widget.post.normalImageUrl)
                  .then((file) {
                if (!mounted) return;
                widget.onCached(file!.file.path);
              });
              return Image(image: imageProvider);
            },
            placeholderFadeInDuration: Duration.zero,
            fadeOutDuration: Duration.zero,
            progressIndicatorBuilder: (context, url, progress) => FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                height: widget.post.height,
                width: widget.post.width,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: LinearProgressIndicator(value: progress.progress),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
