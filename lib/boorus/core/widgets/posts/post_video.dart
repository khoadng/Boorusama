// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:chewie/chewie.dart' hide MaterialDesktopControls;
import 'package:video_player/video_player.dart';

// Project imports:
import 'package:boorusama/dart.dart';
import 'package:boorusama/widgets/platforms/windows/windows.dart';

//TODO: implement caching video
class BooruVideo extends StatefulWidget {
  const BooruVideo({
    super.key,
    required this.url,
    required this.aspectRatio,
    this.onCurrentPositionChanged,
    this.onVisibilityChanged,
    this.autoPlay = false,
  });

  final String url;
  final double aspectRatio;
  final void Function(double current, double total, String url)?
      onCurrentPositionChanged;
  final void Function(bool value)? onVisibilityChanged;
  final bool autoPlay;

  @override
  State<BooruVideo> createState() => _BooruVideoState();
}

class _BooruVideoState extends State<BooruVideo> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

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
      customControls: MaterialDesktopControls(
        onVisibilityChanged: widget.onVisibilityChanged,
      ),
      looping: true,
      autoInitialize: true,
    );

    _listenToVideoPosition();
  }

  void _disposeVideoPlayerController() {
    _videoPlayerController.removeListener(_onChanged);
    _videoPlayerController.dispose();
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
    widget.onCurrentPositionChanged!(current, total, widget.url);
  }

  @override
  void didUpdateWidget(BooruVideo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.url != oldWidget.url) {
      _disposeVideoPlayerController();
      _initVideoPlayerController();
    }
  }

  @override
  void dispose() {
    _disposeVideoPlayerController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(controller: _chewieController);
  }
}
