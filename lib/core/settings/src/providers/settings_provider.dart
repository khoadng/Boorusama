// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../types/settings.dart';
import 'settings_notifier.dart';

final settingsProvider = Provider<Settings>(
  (ref) => ref.watch(settingsNotifierProvider),
  name: 'settingsProvider',
  dependencies: [settingsNotifierProvider],
);

final enableDynamicColoringProvider = Provider<bool>(
  (ref) => ref
      .watch(settingsProvider.select((value) => value.enableDynamicColoring)),
  name: 'enableDynamicColoringProvider',
  dependencies: [settingsProvider],
);
