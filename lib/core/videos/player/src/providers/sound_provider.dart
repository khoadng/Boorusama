// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../settings/providers.dart';

class GlobalSoundNotifier extends Notifier<bool> {
  @override
  bool build() {
    final isMuteByDefault = ref.watch(
      imageViewerSettingsProvider.select(
        (s) => s.videoAudioDefaultState.muteByDefault,
      ),
    );

    return !isMuteByDefault;
  }

  void toggle() {
    state = !state;
  }

  void setState(bool value) {
    state = value;
  }
}

final globalSoundStateProvider = NotifierProvider<GlobalSoundNotifier, bool>(
  GlobalSoundNotifier.new,
);
