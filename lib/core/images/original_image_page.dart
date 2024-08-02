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
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/foundation/mobile.dart';
import 'package:boorusama/widgets/widgets.dart';

class OriginalImagePage extends ConsumerStatefulWidget {
  const OriginalImagePage({
    super.key,
    required this.imageUrl,
    required this.id,
  });

  OriginalImagePage.post(
    Post post, {
    super.key,
  })  : imageUrl = post.originalImageUrl,
        id = post.id;

  final String imageUrl;
  final int id;

  @override
  ConsumerState<OriginalImagePage> createState() => _OriginalImagePageState();
}

class _OriginalImagePageState extends ConsumerState<OriginalImagePage> {
  Orientation? currentRotation;
  bool overlay = true;
  bool zoom = false;
  var turn = ValueNotifier<double>(0);

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
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
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
            if (kPreferredLayout.isDesktop && overlay) ...[
              IconButton(
                onPressed: () => turn.value = (turn.value - 0.25) % 1,
                color: Colors.white,
                icon: const Icon(Symbols.rotate_left),
              ),
              const SizedBox(width: 12),
            ],
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: ValueListenableBuilder(
                valueListenable: turn,
                builder: (context, value, child) => RotationTransition(
                  turns: AlwaysStoppedAnimation(value),
                  child: child,
                ),
                child: _buildImage(),
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

  Widget _buildImage() {
    final config = ref.watchConfig;

    return CachedNetworkImage(
      httpHeaders: {
        AppHttpHeaders.userAgentHeader:
            ref.watch(userAgentGeneratorProvider(config)).generate(),
      },
      imageUrl: widget.imageUrl,
      imageBuilder: (context, imageProvider) => Hero(
        tag: '${widget.id}_hero',
        child: PhotoView(
          backgroundDecoration: const BoxDecoration(
            color: Colors.transparent,
          ),
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
    );
  }
}
