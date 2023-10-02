// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/bookmarks/bookmarks.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/embedded_webview_webm.dart';
import 'package:boorusama/widgets/nullable_aspect_ratio.dart';

class BookmarkMediaItem extends ConsumerStatefulWidget {
  const BookmarkMediaItem({
    super.key,
    required this.bookmark,
    this.onTap,
    this.onZoomUpdated,
  });

  final Bookmark bookmark;
  final VoidCallback? onTap;
  final void Function(bool zoom)? onZoomUpdated;

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
    final config = ref.watchConfig;

    return widget.bookmark.isVideo
        ? p.extension(widget.bookmark.sampleUrl) == '.webm'
            ? EmbeddedWebViewWebm(
                url: widget.bookmark.sampleUrl,
                backgroundColor: context.colors.videoPlayerBackgroundColor,
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
              child: NullableAspectRatio(
                aspectRatio: widget.bookmark.aspectRatio,
                child: LayoutBuilder(
                  builder: (context, constraints) => ExtendedImage.network(
                    widget.bookmark.sampleUrl,
                    headers: {
                      'User-Agent': ref
                          .watch(userAgentGeneratorProvider(config))
                          .generate(),
                    },
                  ),
                ),
              ),
            ),
          );
  }
}
