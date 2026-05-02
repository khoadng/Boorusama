// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cache_manager/cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../../images/booru_image.dart';
import '../../../../notes/note/providers.dart';
import '../../../../notes/note/types.dart';
import '../../../../notes/note/widgets.dart';
import '../../../../widgets/widgets.dart';
import '../../../listing/providers.dart';
import '../../../listing/types.dart';
import '../../../post/types.dart';
import '../providers/note_overlay_provider.dart';

typedef PostDetailsPlaceholderMediaBuilder<T extends Post> =
    GridThumbnailMedia Function(T post);

class PostDetailsImage<T extends Post> extends StatelessWidget {
  const PostDetailsImage({
    required this.config,
    required this.imageUrlBuilder,
    required this.mediaAspectRatioBuilder,
    required this.placeholderMediaBuilder,
    required this.post,
    super.key,
    this.heroTag,
    this.imageCacheManager,
  });

  final BooruConfigAuth config;
  final String? heroTag;
  final String Function(T post)? imageUrlBuilder;
  final double? Function(T post)? mediaAspectRatioBuilder;
  final PostDetailsPlaceholderMediaBuilder<T>? placeholderMediaBuilder;
  final ImageCacheManager? imageCacheManager;
  final T post;

  @override
  Widget build(BuildContext context) {
    final aspectRatio =
        mediaAspectRatioBuilder?.call(post) ?? post.effectiveSampleAspectRatio;

    return aspectRatio != null
        ? AspectRatio(
            aspectRatio: aspectRatio,
            child: Consumer(
              builder: (_, ref, _) => Stack(
                children: [
                  RawPostDetailsImage(
                    config: config,
                    post: post,
                    heroTag: heroTag,
                    imageUrlBuilder: imageUrlBuilder,
                    mediaAspectRatioBuilder: mediaAspectRatioBuilder,
                    placeholderMediaBuilder: placeholderMediaBuilder,
                    imageCacheManager: imageCacheManager,
                  ),
                  ..._buildNotes(ref),
                ],
              ),
            ),
          )
        : RawPostDetailsImage(
            config: config,
            post: post,
            heroTag: heroTag,
            imageUrlBuilder: imageUrlBuilder,
            mediaAspectRatioBuilder: mediaAspectRatioBuilder,
            placeholderMediaBuilder: placeholderMediaBuilder,
            imageCacheManager: imageCacheManager,
          );
  }

  List<Widget> _buildNotes(WidgetRef ref) {
    final params = (config, post);
    final noteState = ref.watch(notesControllerProvider(post));
    final notes = ref.watch(currentNotesProvider(params)) ?? <Note>[].lock;
    final noteOverlayNotifier = ref.watch(noteOverlayProvider(params).notifier);

    return [
      if (noteState.enableNotes)
        ...notes.map(
          (note) => LayoutBuilder(
            builder: (context, constraints) => PostNote(
              note: note.adjust(
                width: post.width,
                height: post.height,
                widthConstraint: constraints.maxWidth,
                heightConstraint: constraints.maxHeight,
              ),
              onShow: () {
                noteOverlayNotifier.setVisible(true);
              },
              onHide: () {
                noteOverlayNotifier.setVisible(false);
              },
            ),
          ),
        ),
    ];
  }
}

class RawPostDetailsImage<T extends Post> extends ConsumerWidget {
  const RawPostDetailsImage({
    required this.config,
    required this.post,
    super.key,
    this.heroTag,
    this.imageUrlBuilder,
    this.mediaAspectRatioBuilder,
    this.placeholderMediaBuilder,
    this.imageCacheManager,
    this.fit,
  });

  final BooruConfigAuth config;
  final String? heroTag;
  final String Function(T post)? imageUrlBuilder;
  final double? Function(T post)? mediaAspectRatioBuilder;
  final PostDetailsPlaceholderMediaBuilder<T>? placeholderMediaBuilder;
  final ImageCacheManager? imageCacheManager;
  final T post;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = imageUrlBuilder != null
        ? imageUrlBuilder!(post)
        : post.thumbnailImageUrl;
    final aspectRatio =
        mediaAspectRatioBuilder?.call(post) ??
        post.effectiveThumbnailAspectRatio;

    if (imageUrl.isEmpty) {
      return NullableAspectRatio(
        aspectRatio: aspectRatio,
        child: const ImagePlaceHolder(
          borderRadius: BorderRadius.zero,
        ),
      );
    }

    final gridThumbnailUrlBuilder = ref.watch(
      gridThumbnailUrlGeneratorProvider(config),
    );
    final gridThumbnailSettings = ref.watch(
      gridThumbnailSettingsProvider(config),
    );
    final gridMedia = gridThumbnailUrlBuilder.resolve(
      post,
      settings: gridThumbnailSettings,
    );
    final placeholderMedia = placeholderMediaBuilder?.call(post) ?? gridMedia;
    final usesPrimaryPlaceholderUrl = placeholderMedia.url.isNotEmpty;
    final placeholderImageUrl = usesPrimaryPlaceholderUrl
        ? placeholderMedia.url
        : placeholderMedia.placeholderUrl;
    final placeholderAspectRatio = usesPrimaryPlaceholderUrl
        ? placeholderMedia.aspectRatio
        : placeholderMedia.placeholderAspectRatio ??
              placeholderMedia.aspectRatio;

    final image = BooruImage(
      config: config,
      imageUrl: imageUrl,
      placeholderUrl: placeholderImageUrl,
      placeholderAspectRatio: placeholderAspectRatio,
      placeholderFit: placeholderMedia.placeholderFit,
      aspectRatio: aspectRatio,
      forceCover: aspectRatio != null,
      imageHeight: post.height,
      imageWidth: post.width,
      forceFill: true,
      fit: fit,
      borderRadius: BorderRadius.zero,
      forceLoadPlaceholder: true,
      imageCacheManager: imageCacheManager,
    );

    return BooruHero(
      tag: heroTag,
      child: aspectRatio != null
          ? AspectRatio(
              aspectRatio: aspectRatio,
              child: image,
            )
          : LayoutBuilder(
              builder: (context, constraints) => image,
            ),
    );
  }
}
