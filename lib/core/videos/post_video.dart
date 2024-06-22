// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:chewie/chewie.dart' hide MaterialDesktopControls;
import 'package:video_player/video_player.dart';

// Project imports:
import 'package:boorusama/dart.dart';
import 'package:boorusama/widgets/widgets.dart';

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
    this.onZoomUpdated,
    this.customControlsBuilder,
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
  final void Function(bool value)? onZoomUpdated;
  final Widget? Function()? customControlsBuilder;

  @override
  State<BooruVideo> createState() => _BooruVideoState();
}

class _BooruVideoState extends State<BooruVideo> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  late TransformationController transformationController;

  @override
  void initState() {
    super.initState();
    _initVideoPlayerController();
  }

  void _initVideoPlayerController() {
    _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.url)); // TODO: dangerous parsing here
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
      autoInitialize: true,
      showControlsOnInitialize: false,
    );

    widget.onVideoPlayerCreated?.call(_videoPlayerController);

    _videoPlayerController.setVolume(widget.sound ? 1 : 0);
    _videoPlayerController.setPlaybackSpeed(widget.speed);

    transformationController = TransformationController();
    transformationController.addListener(_onTransform);

    _listenToVideoPosition();
  }

  void _onTransform() {
    final clampedMatrix = Matrix4.diagonal3Values(
      transformationController.value.right.x,
      transformationController.value.up.y,
      transformationController.value.forward.z,
    );

    widget.onZoomUpdated?.call(!clampedMatrix.isIdentity());
  }

  void _disposeVideoPlayerController() {
    _videoPlayerController.removeListener(_onChanged);
    transformationController.removeListener(_onTransform);
    _videoPlayerController.dispose();
    _chewieController.dispose();
    transformationController.dispose();
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
    return InteractiveImage(
      useOriginalSize: false,
      transformationController: transformationController,
      image: Chewie(controller: _chewieController),
    );
  }
}
