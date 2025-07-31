// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selection_mode/selection_mode.dart';

// Project imports:
import '../types/settings.dart';
import '../types/types.dart';
import 'settings_notifier.dart';

final settingsProvider = Provider<Settings>(
  (ref) => ref.watch(settingsNotifierProvider),
  name: 'settingsProvider',
  dependencies: [settingsNotifierProvider],
);

final searchBarPositionProvider = Provider<SearchBarPosition>(
  (ref) => ref.watch(settingsProvider.select((s) => s.searchBarPosition)),
  name: 'searchBarPositionProvider',
);

final hapticFeedbackLevelProvider = Provider<HapticFeedbackLevel>(
  (ref) => ref.watch(settingsProvider.select((s) => s.hapticFeedbackLevel)),
  name: 'hapticFeedbackLevelProvider',
);

final selectionOptionsProvider = Provider<SelectionOptions>((ref) {
  final level = ref.watch(hapticFeedbackLevelProvider);

  return SelectionOptions(
    behavior: SelectionBehavior.manual,
    dragSelection: const DragSelectionOptions(),
    haptics: switch (level) {
      HapticFeedbackLevel.none => HapticFeedbackResolver.none,
      HapticFeedbackLevel.reduced => HapticFeedbackResolver.modeOnly,
      _ => HapticFeedbackResolver.all,
    },
  );
});
