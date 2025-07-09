// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../configs/ref.dart';
import '../../../../images/booru_image.dart';
import '../../../../notes/notes.dart';
import '../../../../widgets/widgets.dart';
import '../../../listing/providers.dart';
import '../../../post/post.dart';

class PostDetailsImage<T extends Post> extends ConsumerStatefulWidget {
  const PostDetailsImage({
    required this.imageUrlBuilder,
    required this.thumbnailUrlBuilder,
    required this.post,
    super.key,
    this.heroTag,
    this.imageCacheManager,
  });

  final String? heroTag;
  final String Function(T post)? imageUrlBuilder;
  final String Function(T post)? thumbnailUrlBuilder;
  final ImageCacheManager Function(Post post)? imageCacheManager;
  final Post post;

  @override
  ConsumerState<PostDetailsImage> createState() => _PostDetailsImageState();
}

class _PostDetailsImageState extends ConsumerState<PostDetailsImage> {
  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.imageUrlBuilder != null
        ? widget.imageUrlBuilder!(widget.post)
        : widget.post.thumbnailImageUrl;
    final aspectRatio = widget.post.aspectRatio;

    if (imageUrl.isEmpty) {
      return NullableAspectRatio(
        aspectRatio: aspectRatio,
        child: const ImagePlaceHolder(),
      );
    }

    return BooruHero(
      tag: widget.heroTag,
      child: aspectRatio != null
          ? AspectRatio(
              aspectRatio: aspectRatio,
              child: Stack(
                children: [
                  _buildImage(imageUrl),
                  ..._buildNotes(),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) => _buildImage(imageUrl),
            ),
    );
  }

  List<Widget> _buildNotes() {
    final post = widget.post;

    final noteState = ref.watch(notesControllerProvider(post));
    final notes = ref.watch(currentNotesProvider(post)) ?? <Note>[].lock;

    return [
      if (noteState.enableNotes)
        ...notes.map(
          (e) => LayoutBuilder(
            builder: (context, constraints) {
              final effectiveNote = e.adjustNoteCoordFor(
                post,
                widthConstraint: constraints.maxWidth,
                heightConstraint: constraints.maxHeight,
              );
              return PostNote(
                coordinate: effectiveNote.coordinate,
                content: effectiveNote.content,
              );
            },
          ),
        ),
    ];
  }

  Widget _buildImage(String imageUrl) {
    final post = widget.post;
    final config = ref.watchConfigAuth;

    final gridThumbnailUrlBuilder = ref.watch(
      gridThumbnailUrlGeneratorProvider(config),
    );
    final placeholderImageUrl = widget.thumbnailUrlBuilder != null
        ? widget.thumbnailUrlBuilder!(post)
        : gridThumbnailUrlBuilder.generateUrl(
            post,
            settings: ref.watch(gridThumbnailSettingsProvider(config)),
          );

    return BooruImage(
      imageUrl: imageUrl,
      placeholderUrl: placeholderImageUrl,
      aspectRatio: post.aspectRatio,
      forceCover: post.aspectRatio != null,
      imageHeight: post.height,
      imageWidth: post.width,
      forceFill: true,
      borderRadius: BorderRadius.zero,
      forceLoadPlaceholder: true,
      imageCacheManager: widget.imageCacheManager != null
          ? widget.imageCacheManager!(post)
          : null,
    );
  }
}
