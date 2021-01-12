import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

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
        return PhotoView(
          imageProvider: imageProvider,
          backgroundDecoration: BoxDecoration(
            color: Theme.of(context).appBarTheme.color,
          ),
        );
      },
      progressIndicatorBuilder: (context, url, progress) => Center(
        child: CircularProgressIndicator(
          value: progress.progress,
        ),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
