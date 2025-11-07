// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlaybackSpeedNotifier extends AutoDisposeFamilyNotifier<double, String> {
  @override
  double build(String url) => 1;

  void setSpeed(double value) {
    state = value;
  }
}

final playbackSpeedProvider =
    AutoDisposeNotifierProviderFamily<PlaybackSpeedNotifier, double, String>(
      PlaybackSpeedNotifier.new,
    );
