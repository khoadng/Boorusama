// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../images/booru_image.dart';
import '../../../../notes/notes.dart';
import '../../../../settings/providers.dart';
import '../../../../widgets/widgets.dart';
import '../../../post/post.dart';

class PostDetailsImage<T extends Post> extends ConsumerStatefulWidget {
  const PostDetailsImage({
    required this.imageUrlBuilder,
    required this.thumbnailUrlBuilder,
    required this.post,
    super.key,
    this.heroTag,
  });

  final String? heroTag;
  final String Function(T post)? imageUrlBuilder;
  final String Function(T post)? thumbnailUrlBuilder;
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

    final booruBuilder = ref.watch(currentBooruBuilderProvider);
    final imageGridQuality = ref.watch(imageListingQualityProvider);

    final gridThumbnailUrlBuilder = booruBuilder?.gridThumbnailUrlBuilder;
    final placeholderImageUrl = widget.thumbnailUrlBuilder != null
        ? widget.thumbnailUrlBuilder!(post)
        : gridThumbnailUrlBuilder != null
            ? gridThumbnailUrlBuilder(imageGridQuality, post)
            : post.thumbnailImageUrl;

    return BooruImage(
      imageUrl: imageUrl,
      placeholderUrl: placeholderImageUrl,
      aspectRatio: post.aspectRatio,
      forceFill: post.aspectRatio != null,
      borderRadius: BorderRadius.zero,
      forceLoadPlaceholder: true,
    );
  }
}
