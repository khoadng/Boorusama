// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/domain/user_agent_generator.dart';

class BooruImageLegacy extends StatefulWidget {
  const BooruImageLegacy({
    super.key,
    required this.imageUrl,
    this.placeholderUrl,
    this.borderRadius,
    this.fit,
    this.cacheHeight,
    this.cacheWidth,
  });

  final String imageUrl;
  final String? placeholderUrl;
  final BorderRadiusGeometry? borderRadius;
  final BoxFit? fit;
  final int? cacheWidth;
  final int? cacheHeight;

  @override
  State<BooruImageLegacy> createState() => _BooruImageLegacyState();
}

class _BooruImageLegacyState extends State<BooruImageLegacy> {
  late Image myImage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(myImage.image, context);
  }

  @override
  void initState() {
    myImage = Image(
      image: CachedNetworkImageProvider(
        widget.imageUrl,
        headers: {
          'User-Agent': context.read<UserAgentGenerator>().generate(),
        },
      ),
    );
    myImage.image
        // ignore: use_named_constants
        .resolve(const ImageConfiguration())
        // ignore: no-empty-block
        .addListener(ImageStreamListener((_, __) {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      httpHeaders: {
        'User-Agent': context.read<UserAgentGenerator>().generate(),
      },
      memCacheWidth: widget.cacheWidth,
      memCacheHeight: widget.cacheHeight,
      imageUrl: widget.imageUrl,
      imageBuilder: (context, imageProvider) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ??
                const BorderRadius.all(Radius.circular(8)),
            image: DecorationImage(
              image: myImage.image,
              fit: widget.fit ?? BoxFit.cover,
            ),
          ),
        );
      },
      placeholder: (context, url) => widget.placeholderUrl != null
          ? CachedNetworkImage(
              httpHeaders: {
                'User-Agent': context.read<UserAgentGenerator>().generate(),
              },
              imageUrl: widget.placeholderUrl!,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: widget.borderRadius ??
                      const BorderRadius.all(Radius.circular(8)),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: widget.fit ?? BoxFit.cover,
                  ),
                ),
              ),
              placeholder: (context, url) => Container(
                decoration: BoxDecoration(
                  borderRadius: widget.borderRadius ??
                      const BorderRadius.all(Radius.circular(8)),
                  color: Theme.of(context).cardColor,
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius ??
                    const BorderRadius.all(Radius.circular(8)),
                color: Theme.of(context).cardColor,
              ),
            ),
      errorWidget: (context, url, error) => Container(
        decoration: BoxDecoration(
          borderRadius:
              widget.borderRadius ?? const BorderRadius.all(Radius.circular(8)),
          color: Theme.of(context).cardColor,
        ),
        child: const Center(child: Icon(Icons.broken_image_rounded)),
      ),
      fadeInDuration: const Duration(microseconds: 10),
      fadeOutDuration: const Duration(microseconds: 500),
    );
  }
}
