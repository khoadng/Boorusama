// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

class PostImage extends StatefulWidget {
  const PostImage({
    Key? key,
    required this.imageUrl,
    required this.placeholderUrl,
  }) : super(key: key);

  final String imageUrl;
  final String placeholderUrl;

  @override
  _PostImageState createState() => _PostImageState();
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
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((_, __) {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      imageBuilder: (context, imageProvider) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            image: DecorationImage(image: myImage.image, fit: BoxFit.cover),
          ),
        );
      },
      placeholder: (context, url) => CachedNetworkImage(
        imageUrl: widget.placeholderUrl,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Theme.of(context).cardColor,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Center(child: Icon(Icons.error)),
      fadeInDuration: Duration(microseconds: 10),
    );
  }
}
