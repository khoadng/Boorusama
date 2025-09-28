// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../providers/sound_provider.dart';

class SoundControlButton extends ConsumerWidget {
  const SoundControlButton({
    super.key,
    this.padding,
  });

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundOn = ref.watch(globalSoundStateProvider);
    final notifier = ref.watch(globalSoundStateProvider.notifier);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => notifier.toggle(),
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
