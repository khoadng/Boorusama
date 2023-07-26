// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/time.dart';
import 'package:boorusama/widgets/video_progress_bar.dart';

// Class to store duration and position of video
class VideoProgress extends Equatable {
  const VideoProgress(
    this.duration,
    this.position,
  );

  final Duration duration;
  final Duration position;

  static const zero = VideoProgress(Duration.zero, Duration.zero);

  @override
  List<Object?> get props => [duration, position];
}

class BooruVideoProgressBar extends StatelessWidget {
  const BooruVideoProgressBar({
    super.key,
    required this.progress,
  });

  final VideoProgress progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 8,
        ),
        Text(formatDurationForMedia(progress.position)),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            color: Colors.transparent,
            height: 30,
            child: VideoProgressBar(
              duration: progress.duration,
              position: progress.position,
              buffered: const [],
              seekTo: (position) {
                // webmVideoController.value
                //     ?.seek(position.inSeconds.toDouble());
              },
              barHeight: 2.0,
              handleHeight: 5.0,
              drawShadow: true,
              backgroundColor: Colors.grey,
              playedColor: Colors.blue,
              bufferedColor: Colors.lightBlue,
              handleColor: Colors.white,
            ),
          ),
        ),
        Text(formatDurationForMedia(progress.duration)),
        const SizedBox(
          width: 8,
        ),
      ],
    );
  }
}
