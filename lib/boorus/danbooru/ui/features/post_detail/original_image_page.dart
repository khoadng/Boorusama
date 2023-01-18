// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

// Project imports:
import 'package:boorusama/core/application/application.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/posts/post.dart';
import 'package:boorusama/core/ui/widgets/shadow_gradient_overlay.dart';

class OriginalImagePage extends StatefulWidget {
  const OriginalImagePage({
    super.key,
    required this.post,
    required this.initialOrientation,
  });

  final Post post;
  final Orientation initialOrientation;

  @override
  State<OriginalImagePage> createState() => _OriginalImagePageState();
}

class _OriginalImagePageState extends State<OriginalImagePage> {
  late Orientation currentRotation;
  bool overlay = true;

  @override
  void initState() {
    super.initState();
    currentRotation = widget.initialOrientation;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [
        SystemUiOverlay.bottom,
        SystemUiOverlay.top,
      ],
    );

    switch (widget.initialOrientation) {
      case Orientation.portrait:
        _changeToPortrait();
        break;
      case Orientation.landscape:
        _changeToLandscape();
        break;
    }
  }

  void _changeToLandscape() {
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeRight],
    );
  }

  void _changeToPortrait() {
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        overlay = !overlay;
      }),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                httpHeaders: const {
                  'User-Agent': userAgent,
                },
                imageUrl: widget.post.fullImageUrl,
                imageBuilder: (context, imageProvider) => Hero(
                  tag: '${widget.post.id}_hero',
                  child: PhotoView(imageProvider: imageProvider),
                ),
                progressIndicatorBuilder: (context, url, progress) =>
                    CircularProgressIndicator.adaptive(
                  value: progress.progress,
                ),
              ),
            ),
            if (overlay)
              ShadowGradientOverlay(
                alignment: Alignment.bottomCenter,
                colors: <Color>[
                  const Color.fromARGB(60, 0, 0, 0),
                  Colors.black12.withOpacity(0),
                ],
              ),
            if (overlay)
              ShadowGradientOverlay(
                alignment: Alignment.topCenter,
                colors: <Color>[
                  const Color.fromARGB(60, 0, 0, 0),
                  Colors.black12.withOpacity(0),
                ],
              ),
            if (overlay)
              Align(
                alignment: const Alignment(-0.95, -0.9),
                child: MaterialButton(
                  color: Theme.of(context).cardColor.withOpacity(0.8),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close),
                ),
              ),
            if (overlay && isMobilePlatform())
              Align(
                alignment: const Alignment(0, 0.9),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ButtonBar(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).cardColor,
                        ),
                        label: const Text('Rotate'),
                        onPressed: () {
                          if (currentRotation == Orientation.portrait) {
                            setState(() {
                              _changeToLandscape();
                              currentRotation = Orientation.landscape;
                            });
                          } else {
                            setState(() {
                              _changeToPortrait();
                              currentRotation = Orientation.portrait;
                            });
                          }
                        },
                        icon: currentRotation == Orientation.portrait
                            ? const Icon(Icons.rotate_left)
                            : const Icon(Icons.rotate_right),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
