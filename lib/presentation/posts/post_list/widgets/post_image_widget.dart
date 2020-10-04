import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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

  CachedNetworkImage buildCachedNetworkImage() {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
      )),
      progressIndicatorBuilder: (context, url, progress) => Center(
        child: CircularProgressIndicator(
          value: progress.progress,
        ),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }

  void _handleTap() {
    onTapped(null);
  }
}
