import 'package:flutter/material.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class PostImage extends StatelessWidget {
  const PostImage({
    Key key,
    @required this.imageUrl,
  }) : super(key: key);

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return OptimizedCacheImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) {
        precacheImage(imageProvider, context);
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        );
      },
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
