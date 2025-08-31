// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:video_player/video_player.dart';

// Project imports:
import '../../foundation/utils/duration_utils.dart';
import '../configs/config/providers.dart';
import '../images/booru_image.dart';
import '../widgets/widgets.dart';

//TODO: implement caching video
class BooruVideo extends StatefulWidget {
  const BooruVideo({
    required this.url,
    required this.aspectRatio,
    super.key,
    this.onCurrentPositionChanged,
    this.onVideoPlayerCreated,
    this.sound = true,
    this.speed = 1.0,
    this.thumbnailUrl,
    this.onOpenSettings,
    this.headers,
    this.heroTag,
    this.onInitializing,
  });

  final String url;
  final double? aspectRatio;
  final void Function(double current, double total, String url)?
  onCurrentPositionChanged;
  final void Function(VideoPlayerController controller)? onVideoPlayerCreated;
  final bool sound;
  final double speed;
  final String? thumbnailUrl;
  final void Function()? onOpenSettings;
  final Map<String, String>? headers;
  final String? heroTag;
  final void Function(bool value)? onInitializing;

  @override
  State<BooruVideo> createState() => _BooruVideoState();
}

class _BooruVideoState extends State<BooruVideo> {
  late VideoPlayerController _videoPlayerController;
  bool? _initialized;
  String? _error;
  bool _previouslyReportedInitializing = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initVideoPlayerController();
  }

  Map<String, String> _buildHeaders() => {
    if (widget.headers != null) ...widget.headers!,
  };

  void _initVideoPlayerController() {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
      httpHeaders: _buildHeaders(),
    );

    widget.onVideoPlayerCreated?.call(_videoPlayerController);

    _videoPlayerController
      ..setVolume(widget.sound ? 1 : 0)
      ..setPlaybackSpeed(widget.speed)
      ..setLooping(true);

    _timer = Timer(
      const Duration(milliseconds: 1000),
      () {
        // If the video is still initializing, report back to the parent widget
        if (!_videoPlayerController.value.isInitialized) {
          widget.onInitializing?.call(true);
          _previouslyReportedInitializing = true;
        }
      },
    );

    _initialized = false;
    _videoPlayerController
        .initialize()
        .then((_) {
          if (mounted) {
            setState(() {});
            _initialized = true;
            _clearInitializing();
          }
        })
        .catchError((error) {
          if (mounted) {
            setState(() {
              _error = error.toString();
            });
          }
        });

    _listenToVideoPosition();
  }

  void _clearInitializing() {
    if (_previouslyReportedInitializing) {
      widget.onInitializing?.call(false);
      _previouslyReportedInitializing = false;
    }

    _timer?.cancel();
    _timer = null;
  }

  void _disposeVideoPlayerController() {
    _clearInitializing();

    _videoPlayerController.removeListener(_onChanged);
    _initialized = null;
    _error = null;
    _videoPlayerController.dispose();
  }

  // Listen to the video position and report it back to the parent widget
  // if the callback is set.
  void _listenToVideoPosition() {
    if (widget.onCurrentPositionChanged != null) {
      _videoPlayerController.addListener(_onChanged);
    }
  }

  void _onChanged() {
    final current = _videoPlayerController.value.position.inPreciseSeconds;
    final total = _videoPlayerController.value.duration.inPreciseSeconds;
    widget.onCurrentPositionChanged!(current, total, widget.url);
  }

  @override
  void didUpdateWidget(BooruVideo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.url != oldWidget.url || widget.headers != oldWidget.headers) {
      _disposeVideoPlayerController();
      _initVideoPlayerController();
    }

    if (widget.sound != oldWidget.sound) {
      _videoPlayerController.setVolume(widget.sound ? 1 : 0);
    }

    if (widget.speed != oldWidget.speed) {
      _videoPlayerController.setPlaybackSpeed(widget.speed);
    }
  }

  @override
  void dispose() {
    _disposeVideoPlayerController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thumb = widget.thumbnailUrl;

    return Center(
      child: _initialized == true
          ? AspectRatio(
              aspectRatio:
                  widget.aspectRatio ??
                  _videoPlayerController.value.aspectRatio,
              child: BooruHero(
                tag: widget.heroTag,
                child: Stack(
                  children: [
                    if (thumb != null)
                      Positioned.fill(
                        child: Consumer(
                          builder: (_, ref, _) => BooruImage(
                            config: ref.watchConfigAuth,
                            borderRadius: BorderRadius.zero,
                            aspectRatio:
                                widget.aspectRatio ??
                                _videoPlayerController.value.aspectRatio,
                            imageUrl: thumb,
                          ),
                        ),
                      ),
                    Positioned.fill(
                      child: VideoPlayer(_videoPlayerController),
                    ),
                  ],
                ),
              ),
            )
          : _error != null
          ? Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'If this happens on a regular basis, consider using a different video player engine in the settings.'
                        .hc,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: widget.onOpenSettings,
                    child: Text(
                      context.t.settings.open_app_settings,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : BooruHero(
              tag: widget.heroTag,
              child: thumb != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Consumer(
                            builder: (_, ref, _) => BooruImage(
                              config: ref.watchConfigAuth,
                              borderRadius: BorderRadius.zero,
                              aspectRatio:
                                  widget.aspectRatio ??
                                  _videoPlayerController.value.aspectRatio,
                              imageUrl: thumb,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(),
                    ),
            ),
    );
  }
}
