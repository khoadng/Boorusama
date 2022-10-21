// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

class PostImage extends StatefulWidget {
  const PostImage({
    Key? key,
    required this.imageUrl,
    this.placeholderUrl,
    this.borderRadius,
    this.fit,
  }) : super(key: key);

  final String imageUrl;
  final String? placeholderUrl;
  final BorderRadiusGeometry? borderRadius;
  final BoxFit? fit;

  @override
  State<PostImage> createState() => _PostImageState();
}

class _PostImageState extends State<PostImage> {
  late Image myImage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(myImage.image, context);
  }

  @override
  void initState() {
    myImage = Image(
      image: CachedNetworkImageProvider(widget.imageUrl),
    );
    myImage.image
        .resolve(ImageConfiguration.empty)
        // ignore: no-empty-block
        .addListener(ImageStreamListener((_, __) {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      imageBuilder: (context, imageProvider) {
        return DecoratedBox(
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
              imageUrl: widget.placeholderUrl!,
              imageBuilder: (context, imageProvider) => DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: widget.borderRadius ??
                      const BorderRadius.all(Radius.circular(8)),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: widget.fit ?? BoxFit.cover,
                  ),
                ),
              ),
              placeholder: (context, url) => DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: widget.borderRadius ??
                      const BorderRadius.all(Radius.circular(8)),
                  color: Theme.of(context).cardColor,
                ),
              ),
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius ??
                    const BorderRadius.all(Radius.circular(8)),
                color: Theme.of(context).cardColor,
              ),
            ),
      errorWidget: (context, url, error) => DecoratedBox(
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
