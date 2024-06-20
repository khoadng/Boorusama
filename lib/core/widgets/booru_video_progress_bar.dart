// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/theme/theme.dart';
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
    required this.onSpeedChanged,
    this.soundOn = true,
    required this.playbackSpeed,
  });

  final bool soundOn;
  final double playbackSpeed;
  final VideoProgress progress;
  final void Function(Duration position)? onSeek;
  final void Function(bool value)? onSoundToggle;
  final void Function(double value) onSpeedChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 12),
        Text(
          formatDurationForMedia(progress.position),
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.transparent,
            height: 36,
            child: VideoProgressBar(
              duration: progress.duration,
              position: progress.position,
              buffered: const [],
              seekTo: (position) => onSeek?.call(position),
              barHeight: 4,
              handleHeight: 8,
              drawShadow: true,
              backgroundColor: Theme.of(context).hintColor.withOpacity(0.2),
              playedColor: Theme.of(context).colorScheme.primary,
              bufferedColor: Theme.of(context).hintColor,
              handleColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Text(
          formatDurationForMedia(progress.duration),
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        SoundControlButton(
          soundOn: soundOn,
          onSoundChanged: onSoundToggle,
        ),
        const SizedBox(
          width: 8,
        ),
        MoreOptionsControlButton(
          speed: playbackSpeed,
          onSpeedChanged: onSpeedChanged,
        ),
        const SizedBox(width: 12)
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
        customBorder: const CircleBorder(),
        onTap: () => onSoundChanged?.call(!soundOn),
        child: Icon(
          soundOn ? Symbols.volume_up : Symbols.volume_off,
          fill: 1,
        ),
      ),
    );
  }
}

class MoreOptionsControlButton extends StatelessWidget {
  const MoreOptionsControlButton({
    super.key,
    required this.speed,
    required this.onSpeedChanged,
  });

  final double speed;
  final void Function(double speed) onSpeedChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => showMaterialModalBottomSheet(
          context: context,
          builder: (_) => BooruVideoOptionSheet(
            value: speed,
            onChanged: onSpeedChanged,
          ),
        ),
        child: const Icon(
          Symbols.settings,
          fill: 1,
        ),
      ),
    );
  }
}

class BooruVideoOptionSheet extends StatelessWidget {
  const BooruVideoOptionSheet({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final double value;
  final void Function(double value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kPreferredLayout.isDesktop
          ? context.colorScheme.surface
          : context.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            MobilePostGridConfigTile(
              value: _buildSpeedText(value),
              title: 'Play back speed',
              onTap: () {
                Navigator.of(context).pop();
                showMaterialModalBottomSheet(
                  context: context,
                  builder: (_) => PlaybackSpeedActionSheet(
                    onChanged: onChanged,
                    speeds: const [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
                  ),
                );
              },
            ),
            SizedBox(
              height: MediaQuery.viewPaddingOf(context).bottom,
            ),
          ],
        ),
      ),
    );
  }
}

String _buildSpeedText(double speed) {
  if (speed == 1.0) return 'Normal';

  final speedText = speed.toStringAsFixed(2);
  // if end with zero, remove it
  final cleanned = speedText.endsWith('0')
      ? speedText.substring(0, speedText.length - 1)
      : speedText;

  return '${cleanned}x';
}

class PlaybackSpeedActionSheet extends StatelessWidget {
  const PlaybackSpeedActionSheet({
    super.key,
    required this.onChanged,
    required this.speeds,
  });

  final void Function(double value) onChanged;
  final List<double> speeds;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.secondaryContainer,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: speeds
              .map(
                (e) => ListTile(
                  title: Text(_buildSpeedText(e)),
                  onTap: () {
                    context.navigator.pop();
                    onChanged(e);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
