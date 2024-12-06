// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/core/posts/listing.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/theme.dart';

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

class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({
    super.key,
    required this.isPlaying,
    required this.onPlayingChanged,
    this.padding,
  });

  final ValueNotifier<bool> isPlaying;
  final void Function(bool value) onPlayingChanged;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isPlaying,
      builder: (_, playing, __) => Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => onPlayingChanged(playing),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: Icon(
              switch (playing) {
                true => Symbols.pause,
                false => Symbols.play_arrow,
              },
              fill: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class SoundControlButton extends StatelessWidget {
  const SoundControlButton({
    super.key,
    required this.soundOn,
    this.onSoundChanged,
    this.padding,
  });

  final bool soundOn;
  final void Function(bool hasSound)? onSoundChanged;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => onSoundChanged?.call(!soundOn),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Icon(
            soundOn ? Symbols.volume_up : Symbols.volume_off,
            fill: 1,
          ),
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
          : context.colorScheme.surfaceContainer,
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
      color: context.colorScheme.surfaceContainer,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 4,
        ),
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
