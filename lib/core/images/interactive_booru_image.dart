// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/widgets/widgets.dart';

class InteractiveBooruImage extends ConsumerStatefulWidget {
  const InteractiveBooruImage({
    super.key,
    required this.useHero,
    required this.heroTag,
    required this.aspectRatio,
    required this.imageUrl,
    this.placeholderImageUrl,
    this.imageOverlayBuilder,
    this.width,
    this.height,
  });

  final bool useHero;
  final String heroTag;
  final double? aspectRatio;
  final String imageUrl;
  final String? placeholderImageUrl;
  final List<Widget> Function(BoxConstraints constraints)? imageOverlayBuilder;
  final double? width;
  final double? height;

  @override
  ConsumerState<InteractiveBooruImage> createState() =>
      _InteractiveBooruImageState();
}

class _InteractiveBooruImageState extends ConsumerState<InteractiveBooruImage> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfig;
    final ua = ref.watch(userAgentGeneratorProvider(config)).generate();

    if (widget.imageUrl.isEmpty) {
      return NullableAspectRatio(
        aspectRatio: widget.aspectRatio,
        child: const ImagePlaceHolder(),
      );
    }

    return ConditionalParentWidget(
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
                      width: constraints.maxWidth.isFinite
                          ? constraints.maxWidth
                          : null,
                      height: constraints.maxHeight.isFinite
                          ? constraints.maxHeight
                          : null,
                      fit: BoxFit.contain,
                      cacheMaxAge: kDefaultImageCacheDuration,
                      headers: {
                        AppHttpHeaders.userAgentHeader: ua,
                        ...ref.watch(extraHttpHeaderProvider(config)),
                      },
                    ),
                    ...widget.imageOverlayBuilder?.call(constraints) ?? [],
                  ],
                ),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) => ExtendedImage.network(
                widget.imageUrl,
                width:
                    constraints.maxWidth.isFinite ? constraints.maxWidth : null,
                height: constraints.maxHeight.isFinite
                    ? constraints.maxHeight
                    : null,
                cacheMaxAge: kDefaultImageCacheDuration,
                fit: BoxFit.contain,
                headers: {
                  AppHttpHeaders.userAgentHeader: ua,
                  ...ref.watch(extraHttpHeaderProvider(config)),
                },
              ),
            ),
    );
  }
}
