// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../themes/configs/types.dart';
import '../../../gesture/types.dart';
import '../../../manage/providers.dart';
import '../types/booru_config.dart';

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

  BooruConfigViewer get readConfigViewer =>
      read(currentReadOnlyBooruConfigViewerProvider);

  BooruConfigViewer get watchConfigViewer =>
      watch(currentReadOnlyBooruConfigViewerProvider);

  BooruConfigDownload get readConfigDownload =>
      read(currentReadOnlyBooruConfigDownloadProvider);

  BooruConfigDownload get watchConfigDownload =>
      watch(currentReadOnlyBooruConfigDownloadProvider);
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

  BooruConfigDownload get readConfigDownload =>
      read(currentReadOnlyBooruConfigDownloadProvider);

  BooruConfigDownload get watchConfigDownload =>
      watch(currentReadOnlyBooruConfigDownloadProvider);
}
