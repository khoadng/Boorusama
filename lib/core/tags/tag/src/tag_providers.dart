// Dart imports:
import 'dart:ui';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../boorus/booru_builder.dart';
import '../../../../boorus/booru_builder_types.dart';
import '../../../boorus.dart';
import '../../../configs/config.dart';
import '../../../configs/current.dart';
import '../../../configs/ref.dart';
import '../../../settings/data.dart';
import '../../../theme.dart';
import 'tag_repository.dart';
import 'tag_repository_impl.dart';

final emptyTagRepoProvider =
    Provider<TagRepository>((ref) => EmptyTagRepository());

final tagColorProvider = Provider.family<Color?, String>(
  (ref, tag) {
    final config = ref.watchConfigAuth;

    final colorBuilder = _getCurrentConfigColorBuilder(
      tag,
      ref.watch(booruBuildersProvider),
      config,
    );

    // In case the color builder is null, which means there is no config selected
    if (colorBuilder == null) return null;

    final colorScheme = ref.watch(colorSchemeProvider);

    final color = colorBuilder(colorScheme.brightness, tag);

    final dynamicColors = ref
        .watch(settingsProvider.select((value) => value.enableDynamicColoring));

    // If dynamic colors are disabled, return the color as is
    if (!dynamicColors) return color;

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
  Map<BooruType, BooruBuilder Function()> builders,
  BooruConfigAuth config,
) {
  final booruBuilderFunc = builders[config.booruType];
  final booruBuilder = booruBuilderFunc != null ? booruBuilderFunc() : null;

  return booruBuilder?.tagColorBuilder;
}
