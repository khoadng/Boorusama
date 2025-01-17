// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/ref.dart';
import '../../../../http/providers.dart';
import '../../../../images/booru_image.dart';
import '../../../../images/dio_extended_image.dart';
import '../../../../images/providers.dart';
import '../../../../notes/notes.dart';
import '../../../../widgets/widgets.dart';
import '../../../post/post.dart';

class InteractiveBooruImage extends ConsumerStatefulWidget {
  const InteractiveBooruImage({
    required this.aspectRatio,
    required this.imageUrl,
    required this.post,
    super.key,
    this.heroTag,
    this.placeholderImageUrl,
    this.width,
    this.height,
  });

  final String? heroTag;
  final double? aspectRatio;
  final String imageUrl;
  final String? placeholderImageUrl;
  final double? width;
  final double? height;
  final Post? post;

  @override
  ConsumerState<InteractiveBooruImage> createState() =>
      _InteractiveBooruImageState();
}

class _InteractiveBooruImageState extends ConsumerState<InteractiveBooruImage> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigAuth;
    final dio = ref.watch(dioProvider(config));

    if (widget.imageUrl.isEmpty) {
      return NullableAspectRatio(
        aspectRatio: widget.aspectRatio,
        child: const ImagePlaceHolder(),
      );
    }

    final placeholderImageUrl = widget.placeholderImageUrl;
    final headers = {
      ...ref.watch(extraHttpHeaderProvider(config)),
      ...ref.watch(cachedBypassDdosHeadersProvider(config.url)),
    };

    Widget buildImage(BoxConstraints constraints) {
      return DioExtendedImage.network(
        widget.imageUrl,
        dio: dio,
        width: constraints.maxWidth.isFinite ? constraints.maxWidth : null,
        height: constraints.maxHeight.isFinite ? constraints.maxHeight : null,
        cacheMaxAge: kDefaultImageCacheDuration,
        fit: BoxFit.contain,
        headers: headers,
        loadStateChanged:
            placeholderImageUrl != null && placeholderImageUrl.isNotEmpty
                ? (state) => state.extendedImageLoadState == LoadState.loading
                    ? DioExtendedImage.network(
                        placeholderImageUrl,
                        dio: dio,
                        width: widget.width,
                        height: widget.height,
                        fit: BoxFit.contain,
                        cacheMaxAge: kDefaultImageCacheDuration,
                        headers: headers,
                      )
                    : null
                : null,
      );
    }

    final post = widget.post;

    final noteState =
        post != null ? ref.watch(notesControllerProvider(post)) : null;

    return BooruHero(
      tag: widget.heroTag,
      child: widget.aspectRatio != null
          ? AspectRatio(
              aspectRatio: widget.aspectRatio!,
              child: LayoutBuilder(
                builder: (context, constraints) => Stack(
                  children: [
                    buildImage(constraints),
                    if (post != null)
                      if (noteState?.enableNotes ?? false)
                        ...noteState?.notes
                                .map(
                                  (e) => e.adjustNoteCoordFor(
                                    post,
                                    widthConstraint: constraints.maxWidth,
                                    heightConstraint: constraints.maxHeight,
                                  ),
                                )
                                .map(
                                  (e) => PostNote(
                                    coordinate: e.coordinate,
                                    content: e.content,
                                  ),
                                ) ??
                            [],
                  ],
                ),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) => buildImage(constraints),
            ),
    );
  }
}
