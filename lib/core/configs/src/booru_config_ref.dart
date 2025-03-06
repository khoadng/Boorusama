// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../theme/theme_configs.dart';
import 'booru_config.dart';
import 'gestures.dart';
import 'manage/current_booru_providers.dart';

extension BooruWidgetRef on WidgetRef {
  BooruConfig get readConfig => read(currentReadOnlyBooruConfigProvider);

  BooruConfig get watchConfig => watch(currentReadOnlyBooruConfigProvider);

  BooruConfigAuth get readConfigAuth =>
      read(currentReadOnlyBooruConfigAuthProvider);

  BooruConfigAuth get watchConfigAuth =>
      watch(currentReadOnlyBooruConfigAuthProvider);

  BooruConfigSearch get readConfigSearch =>
      read(currentReadOnlyBooruConfigSearchProvider);

  BooruConfigSearch get watchConfigSearch =>
      watch(currentReadOnlyBooruConfigSearchProvider);

  BooruConfigFilter get readConfigFilter =>
      read(currentReadOnlyBooruConfigFilterProvider);

  BooruConfigFilter get watchConfigFilter =>
      watch(currentReadOnlyBooruConfigFilterProvider);

  PostGestureConfig? get watchPostGestures =>
      watch(currentReadOnlyBooruConfigGestureProvider);

  ThemeConfigs? get watchThemeConfigs =>
      watch(currentReadOnlyBooruConfigThemeProvider);

  LayoutConfigs? get watchLayoutConfigs =>
      watch(currentReadOnlyBooruConfigLayoutProvider);
}

extension BooruAutoDisposeProviderRef<T> on Ref<T> {
  BooruConfig get readConfig => read(currentReadOnlyBooruConfigProvider);

  BooruConfig get watchConfig => watch(currentReadOnlyBooruConfigProvider);

  BooruConfigAuth get readConfigAuth =>
      read(currentReadOnlyBooruConfigAuthProvider);

  BooruConfigAuth get watchConfigAuth =>
      watch(currentReadOnlyBooruConfigAuthProvider);

  BooruConfigSearch get readConfigSearch =>
      read(currentReadOnlyBooruConfigSearchProvider);

  BooruConfigSearch get watchConfigSearch =>
      watch(currentReadOnlyBooruConfigSearchProvider);

  BooruConfigFilter get readConfigFilter =>
      read(currentReadOnlyBooruConfigFilterProvider);

  BooruConfigFilter get watchConfigFilter =>
      watch(currentReadOnlyBooruConfigFilterProvider);

  LayoutConfigs? get readLayoutConfigs =>
      read(currentReadOnlyBooruConfigLayoutProvider);
}
