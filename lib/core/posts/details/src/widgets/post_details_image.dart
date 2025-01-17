// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/ref.dart';
import '../../../../http/providers.dart';
import '../../../../images/booru_image.dart';
import '../../../../images/providers.dart';
import '../../../../notes/notes.dart';
import '../../../../settings/providers.dart';
import '../../../../widgets/widgets.dart';
import '../../../post/post.dart';

class PostDetailsImage<T extends Post> extends ConsumerStatefulWidget {
  const PostDetailsImage({
    required this.imageUrlBuilder,
    required this.post,
    super.key,
    this.heroTag,
  });

  final String? heroTag;
  final String Function(T post)? imageUrlBuilder;
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

    return [
      if (noteState.enableNotes)
        ...noteState.notes.map(
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
    final config = ref.watchConfigAuth;
    final dio = ref.watch(dioProvider(config));
    final headers = {
      ...ref.watch(extraHttpHeaderProvider(config)),
      ...ref.watch(cachedBypassDdosHeadersProvider(config.url)),
    };
    final post = widget.post;

    final booruBuilder = ref.watch(currentBooruBuilderProvider);
    final imageGridQuality =
        ref.watch(imageListingSettingsProvider.select((v) => v.imageQuality));

    final gridThumbnailUrlBuilder = booruBuilder?.gridThumbnailUrlBuilder;
    final placeholderImageUrl = gridThumbnailUrlBuilder != null
        ? gridThumbnailUrlBuilder(imageGridQuality, post)
        : post.thumbnailImageUrl;

    return ExtendedImage.network(
      imageUrl,
      dio: dio,
      cacheMaxAge: kDefaultImageCacheDuration,
      fit: BoxFit.contain,
      headers: headers,
      placeholderWidget: placeholderImageUrl.isNotEmpty
          ? ExtendedImage.network(
              placeholderImageUrl,
              dio: dio,
              fit: BoxFit.contain,
              cacheMaxAge: kDefaultImageCacheDuration,
              headers: headers,
            )
          : null,
    );
  }
}
