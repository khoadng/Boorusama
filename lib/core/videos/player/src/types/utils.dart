// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:i18n/i18n.dart';

String buildSpeedText(double speed, BuildContext context) {
  if (speed == 1.0) return context.t.video_player.speed.normal;

  final speedText = speed.toStringAsFixed(2);
  // if end with zero, remove it
  final cleanned = speedText.endsWith('0')
      ? speedText.substring(0, speedText.length - 1)
      : speedText;

  return '${cleanned}x';
}

const kSpeedOptions = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
