// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_view/photo_view.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/mobile.dart';
import 'package:boorusama/widgets/widgets.dart';

class OriginalImagePage extends ConsumerStatefulWidget {
  const OriginalImagePage({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  ConsumerState<OriginalImagePage> createState() => _OriginalImagePageState();
}

class _OriginalImagePageState extends ConsumerState<OriginalImagePage> {
  Orientation? currentRotation;
  bool overlay = true;
  bool zoom = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentRotation = context.orientation;
    });
  }

  Future<void> _pop() async {
    await setDeviceToAutoRotateMode();

    if (mounted) {
      context.navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfig;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            context.navigator.pop(),
      },
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;

          _pop();
        },
        child: Focus(
          autofocus: true,
          child: _buildBody(config),
        ),
      ),
    );
  }

  Widget _buildBody(BooruConfig config) {
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
          toolbarHeight: kToolbarHeight * 1.3,
          automaticallyImplyLeading: false,
          leading: overlay
              ? IconButton(
                  icon: const Icon(Symbols.close, color: Colors.white),
                  onPressed: _pop,
                )
              : null,
          actions: [
            if (kPreferredLayout.isMobile && overlay)
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
                    ? const Icon(Symbols.rotate_left)
                    : const Icon(Symbols.rotate_right),
              ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                httpHeaders: {
                  'User-Agent':
                      ref.watch(userAgentGeneratorProvider(config)).generate(),
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
