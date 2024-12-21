// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:video_player/video_player.dart';

// Project imports:
import '../images/booru_image.dart';
import '../utils/duration_utils.dart';

//TODO: implement caching video
class BooruVideo extends StatefulWidget {
  const BooruVideo({
    required this.url,
    required this.aspectRatio,
    super.key,
    this.onCurrentPositionChanged,
    this.onVisibilityChanged,
    this.onVideoPlayerCreated,
    this.sound = true,
    this.speed = 1.0,
    this.customControlsBuilder,
    this.thumbnailUrl,
  });

  final String url;
  final double? aspectRatio;
  final void Function(double current, double total, String url)?
      onCurrentPositionChanged;
  final void Function(bool value)? onVisibilityChanged;
  final void Function(VideoPlayerController controller)? onVideoPlayerCreated;
  final bool sound;
  final double speed;
  final Widget? Function()? customControlsBuilder;
  final String? thumbnailUrl;

  @override
  State<BooruVideo> createState() => _BooruVideoState();
}

class _BooruVideoState extends State<BooruVideo> {
  late VideoPlayerController _videoPlayerController;
  bool? _initialized;

  @override
  void initState() {
    super.initState();
    _initVideoPlayerController();
  }

  void _initVideoPlayerController() {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    ); // TODO: dangerous parsing here

    widget.onVideoPlayerCreated?.call(_videoPlayerController);

    _videoPlayerController
      ..setVolume(widget.sound ? 1 : 0)
      ..setPlaybackSpeed(widget.speed)
      ..setLooping(true);

    _initialized = false;
    _videoPlayerController.initialize().then((_) {
      if (mounted) {
        setState(() {});
        _initialized = true;
      }
    });

    _listenToVideoPosition();
  }

  void _disposeVideoPlayerController() {
    _videoPlayerController.removeListener(_onChanged);
    _initialized = null;
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

    if (widget.url != oldWidget.url) {
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
              aspectRatio: widget.aspectRatio ??
                  _videoPlayerController.value.aspectRatio,
              child: VideoPlayer(_videoPlayerController),
            )
          : thumb != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: BooruImage(
                        aspectRatio: widget.aspectRatio ??
                            _videoPlayerController.value.aspectRatio,
                        imageUrl: thumb,
                      ),
                    ),
                    const LinearProgressIndicator(
                      minHeight: 2,
                    ),
                  ],
                )
              : const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(),
                ),
    );
  }
}
