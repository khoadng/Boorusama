// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WebsiteLogo extends StatelessWidget {
  const WebsiteLogo({
    super.key,
    required this.url,
    this.size = 32,
  });

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: size,
        maxHeight: size,
        minWidth: size,
        minHeight: size,
      ),
      child: ExtendedImage.network(
        url,
        clearMemoryCacheIfFailed: false,
        fit: BoxFit.cover,
        loadStateChanged: (state) =>
            state.extendedImageLoadState == LoadState.failed
                ? const FaIcon(
                    FontAwesomeIcons.globe,
                    size: 22,
                    color: Colors.blue,
                  )
                : null,
      ),
    );
  }
}
