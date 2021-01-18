import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:time/time.dart';

class PostImage extends StatefulWidget {
  const PostImage({
    Key key,
    @required this.imageUrl,
  }) : super(key: key);

  final String imageUrl;

  @override
  _PostImageState createState() => _PostImageState();
}

class _PostImageState extends State<PostImage> {
  Image myImage;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(myImage.image, context);
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
      placeholder: (context, url) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Theme.of(context).cardColor,
        ),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
      fadeInDuration: 10.milliseconds,
    );
  }
}
