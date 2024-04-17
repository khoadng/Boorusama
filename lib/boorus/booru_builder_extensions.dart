part of 'booru_builder.dart';

extension BooruBuilderFeatureCheck on BooruBuilder {
  bool get isArtistSupported => artistPageBuilder != null;

  bool canFavorite(BooruConfig config) =>
      favoriteAdder != null &&
      favoriteRemover != null &&
      config.hasLoginDetails();
}

extension BooruRef on Ref {
  BooruBuilder? readBooruBuilder(BooruConfig? config) {
    if (config == null) return null;

    final booruBuilders = read(booruBuildersProvider);
    final booruBuilderFunc = booruBuilders[config.booruType];

    return booruBuilderFunc != null ? booruBuilderFunc(config) : null;
  }

  BooruBuilder? readCurrentBooruBuilder() {
    final config = read(currentBooruConfigProvider);
    return readBooruBuilder(config);
  }
}

extension BooruWidgetRef on WidgetRef {
  BooruBuilder? readBooruBuilder(BooruConfig? config) {
    if (config == null) return null;

    final booruBuilders = read(booruBuildersProvider);
    final booruBuilderFunc = booruBuilders[config.booruType];

    return booruBuilderFunc != null ? booruBuilderFunc(config) : null;
  }

  BooruBuilder? watchBooruBuilder(BooruConfig? config) {
    if (config == null) return null;

    final booruBuilders = watch(booruBuildersProvider);
    final booruBuilderFunc = booruBuilders[config.booruType];

    return booruBuilderFunc != null ? booruBuilderFunc(config) : null;
  }
}

extension BooruBuilderWidgetRef on WidgetRef {
  Color? getTagColor(
    BuildContext context,
    String tagType, {
    AppThemeMode? themeMode,
  }) {
    final tm = themeMode ?? context.themeMode;

    return getTagColorCore(
      tagType,
      primaryColor: context.colorScheme.primary,
      themeMode: tm,
      dynamicColor: watch(enableDynamicColoringSettingsProvider),
      color: watchBooruBuilder(watchConfig)?.tagColorBuilder(tm, tagType),
    );
  }
}

Color? getTagColorCore(
  String tagType, {
  required Color primaryColor,
  required AppThemeMode themeMode,
  bool dynamicColor = false,
  required Color? color,
}) =>
    dynamicColor ? color?.harmonizeWith(primaryColor) : color;

final booruBuilderProvider = Provider<BooruBuilder?>((ref) {
  final config = ref.watchConfig;
  final booruBuilders = ref.watch(booruBuildersProvider);
  final booruBuilderFunc = booruBuilders[config.booruType];

  return booruBuilderFunc != null ? booruBuilderFunc(config) : null;
});
