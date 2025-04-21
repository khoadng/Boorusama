// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
