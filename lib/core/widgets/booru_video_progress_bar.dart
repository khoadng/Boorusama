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
    this.onSeek,
    this.onSoundToggle,
  });

  final VideoProgress progress;
  final void Function(Duration position)? onSeek;
  final void Function(bool value)? onSoundToggle;

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
              seekTo: (position) => onSeek?.call(position),
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
        SoundControlButton(
          hasSound: true,
          onSoundChanged: onSoundToggle,
        ),
        const SizedBox(
          width: 8,
        )
      ],
    );
  }
}

class SoundControlButton extends StatefulWidget {
  const SoundControlButton({
    super.key,
    required this.hasSound,
    this.onSoundChanged,
  });

  final bool hasSound;
  final void Function(bool hasSound)? onSoundChanged;

  @override
  State<SoundControlButton> createState() => _SoundControlButtonState();
}

class _SoundControlButtonState extends State<SoundControlButton> {
  late var soundOn = widget.hasSound;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() {
          soundOn = !soundOn;
          widget.onSoundChanged?.call(soundOn);
        }),
        child: Icon(
          soundOn ? Icons.volume_up : Icons.volume_off,
        ),
      ),
    );
  }
}
