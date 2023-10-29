// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/widgets/widgets.dart';

class InteractiveBooruImage extends ConsumerStatefulWidget {
  const InteractiveBooruImage({
    super.key,
    this.onTap,
    required this.useHero,
    required this.heroTag,
    required this.aspectRatio,
    required this.imageUrl,
    this.placeholderImageUrl,
    this.previewCacheManager,
    this.onCached,
    this.imageOverlayBuilder,
    this.width,
    this.height,
    this.onZoomUpdated,
  });

  final VoidCallback? onTap;
  final bool useHero;
  final String heroTag;
  final double? aspectRatio;
  final String imageUrl;
  final String? placeholderImageUrl;
  final CacheManager? previewCacheManager;
  final void Function(String? path)? onCached;
  final List<Widget> Function(BoxConstraints constraints)? imageOverlayBuilder;
  final double? width;
  final double? height;
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
    final config = ref.watchConfig;

    if (widget.imageUrl.isEmpty) {
      return NullableAspectRatio(
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
        child: widget.aspectRatio != null
            ? AspectRatio(
                aspectRatio: widget.aspectRatio!,
                child: LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    children: [
                      ExtendedImage.network(
                        widget.imageUrl,
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        fit: BoxFit.contain,
                        headers: {
                          'User-Agent': ref
                              .watch(userAgentGeneratorProvider(config))
                              .generate(),
                        },
                      ),
                      ...widget.imageOverlayBuilder?.call(constraints) ?? [],
                    ],
                  ),
                ),
              )
            : ExtendedImage.network(
                widget.imageUrl,
                headers: {
                  'User-Agent':
                      ref.watch(userAgentGeneratorProvider(config)).generate(),
                },
              ),
      ),
    );
  }
}
