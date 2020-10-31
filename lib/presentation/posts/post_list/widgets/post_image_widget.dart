import 'package:flutter/material.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class PostImage extends StatelessWidget {
  const PostImage({Key key, @required this.imageUrl, this.onTapped})
      : super(key: key);

  final String imageUrl;
  final ValueChanged onTapped;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: buildCachedNetworkImage(),
      onTap: _handleTap,
    );
  }

  Widget buildCachedNetworkImage() {
    return OptimizedCacheImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) {
        precacheImage(imageProvider, context);
        return Container(
            decoration: BoxDecoration(
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ));
      },
      // progressIndicatorBuilder: (context, url, progress) => Center(
      //   child: CircularProgressIndicator(
      //     value: progress.progress,
      //   ),
      // ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }

  void _handleTap() {
    onTapped(null);
  }
}
