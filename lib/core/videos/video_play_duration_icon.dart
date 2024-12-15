// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../theme.dart';

class VideoPlayDurationIcon extends StatelessWidget {
  const VideoPlayDurationIcon({
    super.key,
    required this.duration,
    required this.hasSound,
  });

  final double? duration;
  final bool? hasSound;

  @override
  Widget build(BuildContext context) {
    final background = context.extendedColorScheme.surfaceContainerOverlayDim;
    final foreground = context.extendedColorScheme.onSurfaceContainerOverlayDim;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      height: 25,
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatDurationForMedia(Duration(seconds: duration!.round())),
            style: TextStyle(
              color: foreground,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          hasSound.toOption().fold(
                () => const SizedBox.shrink(),
                (sound) => sound
                    ? Icon(
                        Symbols.volume_up_rounded,
                        color: foreground,
                        size: 18,
                        fill: 1,
                      )
                    : Icon(
                        Symbols.volume_off_rounded,
                        color: foreground,
                        size: 18,
                        fill: 1,
                      ),
              ),
        ],
      ),
    );
  }
}
