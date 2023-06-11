// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/mobile.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/widgets/widgets.dart';

class OriginalImagePage extends ConsumerStatefulWidget {
  const OriginalImagePage({
    super.key,
    required this.post,
    required this.initialOrientation,
  });

  final Post post;
  final Orientation initialOrientation;

  @override
  ConsumerState<OriginalImagePage> createState() => _OriginalImagePageState();
}

class _OriginalImagePageState extends ConsumerState<OriginalImagePage> {
  late Orientation currentRotation;
  bool overlay = true;
  bool zoom = false;

  @override
  void initState() {
    super.initState();
    currentRotation = widget.initialOrientation;
  }

  @override
  void dispose() {
    super.dispose();

    switch (widget.initialOrientation) {
      case Orientation.portrait:
        setDeviceToPortraitMode();
        break;
      case Orientation.landscape:
        setDeviceToLandscapeMode();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!zoom) {
          setState(() {
            overlay = !overlay;
          });
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: kToolbarHeight * 1.3,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leading: overlay
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => context.navigator.pop(),
                )
              : null,
          actions: [
            if (isMobilePlatform() && overlay)
              IconButton(
                onPressed: () {
                  if (currentRotation == Orientation.portrait) {
                    setState(() {
                      setDeviceToLandscapeMode();
                      currentRotation = Orientation.landscape;
                    });
                  } else {
                    setState(() {
                      setDeviceToPortraitMode();
                      currentRotation = Orientation.portrait;
                    });
                  }
                },
                color: Colors.white,
                icon: currentRotation == Orientation.portrait
                    ? const Icon(Icons.rotate_left)
                    : const Icon(Icons.rotate_right),
              ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                httpHeaders: {
                  'User-Agent':
                      ref.watch(userAgentGeneratorProvider).generate(),
                },
                imageUrl: widget.post.originalImageUrl,
                imageBuilder: (context, imageProvider) => Hero(
                  tag: '${widget.post.id}_hero',
                  child: PhotoView(
                    scaleStateChangedCallback: (value) {
                      if (value != PhotoViewScaleState.initial) {
                        setState(() {
                          zoom = true;
                          overlay = false;
                        });
                      } else {
                        setState(() => zoom = false);
                      }
                    },
                    imageProvider: imageProvider,
                  ),
                ),
                progressIndicatorBuilder: (context, url, progress) => Center(
                  child: CircularProgressIndicator.adaptive(
                    value: progress.progress,
                  ),
                ),
              ),
            ),
            if (overlay)
              ShadowGradientOverlay(
                alignment: Alignment.topCenter,
                colors: <Color>[
                  const Color.fromARGB(60, 0, 0, 0),
                  Colors.black12.withOpacity(0),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
