// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

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
