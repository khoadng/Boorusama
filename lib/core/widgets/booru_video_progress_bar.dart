// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:material_symbols_icons/symbols.dart';

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
    this.soundOn = true,
  });

  final bool soundOn;
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
              backgroundColor: Theme.of(context).hintColor,
              playedColor: Theme.of(context).colorScheme.primary,
              bufferedColor: Theme.of(context).hintColor,
              handleColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Text(formatDurationForMedia(progress.duration)),
        const SizedBox(
          width: 8,
        ),
        SoundControlButton(
          soundOn: soundOn,
          onSoundChanged: onSoundToggle,
        ),
        const SizedBox(
          width: 8,
        )
      ],
    );
  }
}

class SoundControlButton extends StatelessWidget {
  const SoundControlButton({
    super.key,
    required this.soundOn,
    this.onSoundChanged,
  });

  final bool soundOn;

  final void Function(bool hasSound)? onSoundChanged;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSoundChanged?.call(!soundOn),
        child: Icon(
          soundOn ? Symbols.volume_up : Symbols.volume_off,
        ),
      ),
    );
  }
}
