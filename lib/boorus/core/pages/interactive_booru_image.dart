// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/pages/booru_image.dart';
import 'package:boorusama/boorus/core/pages/interactive_image.dart';
import 'package:boorusama/boorus/core/pages/widgets/conditional_parent_widget.dart';
import 'package:boorusama/boorus/core/provider.dart';

class InteractiveBooruImage extends ConsumerStatefulWidget {
  const InteractiveBooruImage({
    super.key,
    this.onTap,
    required this.useHero,
    required this.heroTag,
    required this.aspectRatio,
    required this.imageUrl,
    required this.placeholderImageUrl,
    this.previewCacheManager,
    this.onCached,
    this.imageOverlayBuilder,
    this.width,
    this.height,
    this.onZoomUpdated,
  });

  // ontap
  final VoidCallback? onTap;
  //useHero
  final bool useHero;
  final String heroTag;
  final double aspectRatio;
  final String imageUrl;
  final String placeholderImageUrl;
  final CacheManager? previewCacheManager;
  final void Function(String? path)? onCached;
  final List<Widget> Function(BoxConstraints constraints)? imageOverlayBuilder;
  final double? width;
  final double? height;
  //zoom updated
  final void Function(bool zoom)? onZoomUpdated;

  @override
  ConsumerState<InteractiveBooruImage> createState() =>
      _InteractiveBooruImageState();
}

class _InteractiveBooruImageState extends ConsumerState<InteractiveBooruImage> {
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
    super.dispose();
    transformationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl.isEmpty) {
      return AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: const ImagePlaceHolder(),
      );
    }

    return InteractiveImage(
      useOriginalSize: false,
      onTap: widget.onTap,
      transformationController: transformationController,
      image: ConditionalParentWidget(
        condition: widget.useHero,
        conditionalBuilder: (child) => Hero(
          tag: widget.heroTag,
          child: child,
        ),
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: LayoutBuilder(
            builder: (context, constraints) => CachedNetworkImage(
              httpHeaders: {
                'User-Agent': ref.watch(userAgentGeneratorProvider).generate(),
              },
              imageUrl: widget.imageUrl,
              imageBuilder: (context, imageProvider) {
                DefaultCacheManager()
                    .getFileFromCache(widget.imageUrl)
                    .then((file) {
                  if (!mounted) return;
                  widget.onCached?.call(file?.file.path);
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
                    ...widget.imageOverlayBuilder?.call(constraints) ?? [],
                  ],
                );
              },
              placeholderFadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              fadeInDuration: Duration.zero,
              placeholder: (context, url) => CachedNetworkImage(
                httpHeaders: {
                  'User-Agent':
                      ref.watch(userAgentGeneratorProvider).generate(),
                },
                fit: BoxFit.fill,
                imageUrl: widget.placeholderImageUrl,
                cacheManager: widget.previewCacheManager,
                fadeInDuration: Duration.zero,
                fadeOutDuration: Duration.zero,
                progressIndicatorBuilder: (context, url, progress) => FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    height: widget.height,
                    width: widget.width,
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
