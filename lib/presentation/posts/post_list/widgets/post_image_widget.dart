import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PostImage extends StatelessWidget {
  const PostImage({Key key, @required this.imageUrl}) : super(key: key);

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
          )),
      placeholder: (context, url) => FractionallySizedBox(
        widthFactor: 0.1,
        heightFactor: 0.1,
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
