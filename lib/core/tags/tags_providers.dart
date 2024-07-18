// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/theme.dart';

final tagsProvider =
    NotifierProvider.family<TagsNotifier, List<TagGroupItem>?, BooruConfig>(
  TagsNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
  ],
);

final emptyTagRepoProvider =
    Provider<TagRepository>((ref) => EmptyTagRepository());

final booruTagTypeStoreProvider = Provider<BooruTagTypeStore>(
  (ref) => BooruTagTypeStore(),
);

final booruTagTypePathProvider = Provider<String?>((ref) {
  return null;
});

final booruTagTypeProvider =
    FutureProvider.autoDispose.family<String?, String>((ref, tag) async {
  final config = ref.watchConfig;
  final store = ref.watch(booruTagTypeStoreProvider);
  final sanitized = tag.toLowerCase().replaceAll(' ', '_');
  final data = await store.get(config.booruType, sanitized);

  return data;
});

final tagColorProvider = Provider.family<Color?, String>(
  (ref, tag) {
    final config = ref.watchConfig;

    final colorBuilder = _getCurrentConfigColorBuilder(
      tag,
      ref.watch(booruBuildersProvider),
      config,
    );

    // In case the color builder is null, which means there is no config selected
    if (colorBuilder == null) return null;

    final themeMode =
        ref.watch(settingsProvider.select((value) => value.themeMode));

    final color = colorBuilder(themeMode, tag);

    final dynamicColors = ref
        .watch(settingsProvider.select((value) => value.enableDynamicColoring));

    // If dynamic colors are disabled, return the color as is
    if (!dynamicColors) return color;

    final colorScheme = ref.watch(colorSchemeProvider);

    return color?.harmonizeWith(colorScheme.primary);
  },
  dependencies: [
    currentBooruConfigProvider,
    settingsProvider,
    colorSchemeProvider,
  ],
);

TagColorBuilder? _getCurrentConfigColorBuilder(
  String tag,
  Map<BooruType, BooruBuilder Function(BooruConfig config)> builders,
  BooruConfig config,
) {
  final booruBuilderFunc = builders[config.booruType];
  final booruBuilder =
      booruBuilderFunc != null ? booruBuilderFunc(config) : null;

  return booruBuilder?.tagColorBuilder;
}
