import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:time/time.dart';

class PostImage extends StatelessWidget {
  const PostImage({
    Key key,
    @required this.imageUrl,
  }) : super(key: key);

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) {
        precacheImage(imageProvider, context);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        );
      },
      errorWidget: (context, url, error) => Icon(Icons.error),
      fadeInDuration: 10.milliseconds,
    );
  }
}
