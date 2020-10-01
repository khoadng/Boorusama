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
          // width: 150,
          // height: 150,
          decoration: BoxDecoration(
        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
      )),
      placeholder: (context, url) => Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }

  void _handleTap() {
    onTapped(null);
  }
}
