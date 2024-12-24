// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../settings/providers.dart';

final globalSoundStateProvider = StateProvider<bool>((ref) {
  final isMuteByDefault =
      ref.watch(settingsProvider.select((s) => s.muteAudioByDefault));

  return !isMuteByDefault;
});

final playbackSpeedProvider =
    StateProvider.autoDispose.family<double, String>((ref, url) {
  return 1.0;
});

extension VideoStateX on WidgetRef {
  bool get isGlobalVideoSoundOn => watch(globalSoundStateProvider);
  // ignore: use_setters_to_change_properties
  void setGlobalVideoSound(bool value) =>
      read(globalSoundStateProvider.notifier).state = value;

  double watchPlaybackSpeed(String url) => watch(playbackSpeedProvider(url));

  void setPlaybackSpeed(String url, double value) =>
      read(playbackSpeedProvider(url).notifier).state = value;
}

class VideoSoundScope extends ConsumerWidget {
  const VideoSoundScope({
    required this.builder,
    super.key,
  });

  final Widget Function(BuildContext context, bool soundOn) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundOn = ref.isGlobalVideoSoundOn;

    return builder(context, soundOn);
  }
}
