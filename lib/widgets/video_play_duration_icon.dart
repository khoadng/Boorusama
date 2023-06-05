// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/utils/time_utils.dart';

class VideoPlayDurationIcon extends StatelessWidget {
  const VideoPlayDurationIcon({
    super.key,
    required this.duration,
    required this.hasSound,
  });

  final double? duration;
  final bool hasSound;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      height: 25,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(formatDurationForMedia(Duration(seconds: duration!.round())),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              )),
          hasSound
              ? const Icon(
                  Icons.volume_up_rounded,
                  color: Colors.white70,
                  size: 18,
                )
              : const Icon(
                  Icons.volume_off_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
        ],
      ),
    );
  }
}
