// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

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
