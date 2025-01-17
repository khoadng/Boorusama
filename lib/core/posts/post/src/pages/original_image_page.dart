// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../configs/ref.dart';
import '../../../../foundation/display.dart';
import '../../../../foundation/mobile.dart';
import '../../../../http/providers.dart';
import '../../../../images/providers.dart';
import '../../../../widgets/widgets.dart';
import '../types/post.dart';

class OriginalImagePage extends ConsumerStatefulWidget {
  const OriginalImagePage({
    required this.imageUrl,
    required this.id,
    super.key,
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

  Future<void> _pop(bool didPop) async {
    await setDeviceToAutoRotateMode();
    unawaited(showSystemStatus());

    if (mounted && !didPop) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).pop(),
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) {
            _pop(didPop);
            return;
          }

          _pop(didPop);
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
        setState(() {
          _setOverlay(!overlay);
        });
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          toolbarHeight: kToolbarHeight * 1.3,
          automaticallyImplyLeading: false,
          leading: AnimatedSwitcher(
            duration: Durations.extralong1,
            reverseDuration: const Duration(milliseconds: 10),
            child: overlay
                ? IconButton(
                    icon: const Icon(Symbols.close, color: Colors.white),
                    onPressed: () => _pop(false),
                  )
                : null,
          ),
          actions: [
            if (kPreferredLayout.isMobile)
              AnimatedSwitcher(
                duration: Durations.extralong1,
                reverseDuration: const Duration(milliseconds: 10),
                child: overlay
                    ? IconButton(
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
                      )
                    : null,
              ),
            if (kPreferredLayout.isDesktop)
              AnimatedSwitcher(
                duration: Durations.extralong1,
                reverseDuration: const Duration(milliseconds: 10),
                child: overlay
                    ? Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: IconButton(
                          onPressed: () => turn.value = (turn.value - 0.25) % 1,
                          color: Colors.white,
                          icon: const Icon(Symbols.rotate_left),
                        ),
                      )
                    : null,
              ),
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
            AnimatedSwitcher(
              duration: Durations.extralong1,
              reverseDuration: const Duration(milliseconds: 10),
              child: overlay
                  ? ShadowGradientOverlay(
                      alignment: Alignment.topCenter,
                      colors: <Color>[
                        const Color.fromARGB(60, 0, 0, 0),
                        Colors.black12.withValues(alpha: 0),
                      ],
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final config = ref.watchConfigAuth;
    final dio = ref.watch(dioProvider(config));

    return BooruHero(
      tag: '${widget.id}_hero',
      child: InteractiveViewerExtended(
        onZoomUpdated: (value) {
          setState(() {
            zoom = value;
          });
        },
        child: ExtendedImage.network(
          widget.imageUrl,
          dio: dio,
          headers: {
            ...ref.watch(extraHttpHeaderProvider(config)),
            ...ref.watch(cachedBypassDdosHeadersProvider(config.url)),
          },
        ),
      ),
    );
  }

  void _setOverlay(bool value) {
    overlay = value;

    if (overlay) {
      showSystemStatus();
    } else {
      hideSystemStatus();
    }
  }
}
