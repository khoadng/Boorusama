// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

// Project imports:
import 'package:boorusama/core/application/api/api.dart';

class BooruImageLegacy extends StatefulWidget {
  const BooruImageLegacy({
    super.key,
    required this.imageUrl,
    this.placeholderUrl,
    this.borderRadius,
    this.fit,
  });

  final String imageUrl;
  final String? placeholderUrl;
  final BorderRadiusGeometry? borderRadius;
  final BoxFit? fit;

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
          'User-Agent': userAgent,
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
      httpHeaders: const {
        'User-Agent': userAgent,
      },
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
              httpHeaders: const {
                'User-Agent': userAgent,
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
