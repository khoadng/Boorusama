// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:chewie/chewie.dart' hide MaterialDesktopControls;
import 'package:video_player/video_player.dart';

// Project imports:
import 'package:boorusama/core/domain/posts/post.dart';
import 'package:boorusama/core/ui/platforms/windows/windows.dart';

//TODO: implement caching video
class PostVideo extends StatefulWidget {
  const PostVideo({super.key, required this.post});

  final Post post;

  @override
  State<PostVideo> createState() => _PostVideoState();
}

class _PostVideoState extends State<PostVideo> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController =
        VideoPlayerController.network(widget.post.sampleImageUrl);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: widget.post.aspectRatio,
      autoPlay: true,
      customControls: const MaterialDesktopControls(),
      looping: true,
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(controller: _chewieController);
  }
}
