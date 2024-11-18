// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:chewie/chewie.dart' hide MaterialDesktopControls;
import 'package:video_player/video_player.dart';

// Project imports:
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'videos.dart';

//TODO: implement caching video
class BooruVideo extends StatefulWidget {
  const BooruVideo({
    super.key,
    required this.url,
    required this.aspectRatio,
    this.onCurrentPositionChanged,
    this.onVisibilityChanged,
    this.autoPlay = false,
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
  final bool autoPlay;
  final bool sound;
  final double speed;
  final Widget? Function()? customControlsBuilder;
  final String? thumbnailUrl;

  @override
  State<BooruVideo> createState() => _BooruVideoState();
}

class _BooruVideoState extends State<BooruVideo> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  final _manager = VideoWidgetManager();
  var _initialized = false;
  late var _url = widget.url;

  @override
  void initState() {
    super.initState();

    _initVideoPlayerController();
  }

  void _initVideoPlayerController() async {
    _initialized = false;

    _videoPlayerController = await _manager.registerVideo(
      Uri.parse(_url),
    );
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: widget.aspectRatio,
      autoPlay: widget.autoPlay,
      customControls: widget.customControlsBuilder != null
          ? widget.customControlsBuilder!()
          : MaterialDesktopControls(
              onVisibilityChanged: widget.onVisibilityChanged,
            ),
      looping: true,
      showControlsOnInitialize: false,
    );

    widget.onVideoPlayerCreated?.call(_videoPlayerController);

    _videoPlayerController.setVolume(widget.sound ? 1 : 0);
    _videoPlayerController.setPlaybackSpeed(widget.speed);

    _listenToVideoPosition();

    _initialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _disposeVideoPlayerController() {
    _videoPlayerController.removeListener(_onChanged);
    _manager.unregisterVideo(_url);
    _chewieController.dispose();
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
    widget.onCurrentPositionChanged!(current, total, _url);
  }

  @override
  void didUpdateWidget(BooruVideo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.url != oldWidget.url) {
      _url = widget.url;
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
    return _initialized
        ? Chewie(controller: _chewieController)
        : Center(
            child: NullableAspectRatio(
              aspectRatio: widget.aspectRatio,
              child: widget.thumbnailUrl != null
                  ? Stack(
                      children: [
                        Positioned.fill(
                          child: BooruImage(
                            imageUrl: widget.thumbnailUrl!,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(
                      height: 24,
                      width: 24,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                        ),
                      ),
                    ),
            ),
          );
  }
}
