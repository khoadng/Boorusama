// Dart imports:
import 'dart:ui';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../boorus/engine/engine.dart';
import '../../../boorus/engine/providers.dart';
import '../../../configs/config.dart';
import '../../../configs/ref.dart';
import '../../../theme.dart';
import '../../../theme/providers.dart';
import 'tag_colors.dart';
import 'tag_repository.dart';
import 'tag_repository_impl.dart';

final emptyTagRepoProvider =
    Provider<TagRepository>((ref) => EmptyTagRepository());

final tagColorProvider = Provider.family<Color?, String>(
  (ref, tag) {
    final config = ref.watchConfigAuth;

    final colorBuilder = ref
        .watch(booruEngineRegistryProvider)
        .getBuilder(config.booruType)
        ?.tagColorBuilder;

    final colorsBuilder = ref
        .watch(booruEngineRegistryProvider)
        .getBuilder(config.booruType)
        ?.tagColorsBuilder;

    // In case the color builder is null, which means there is no config selected
    if (colorBuilder == null) return null;

    final colorScheme = ref.watch(colorSchemeProvider);

    final colors = colorsBuilder?.call(
          TagColorsOptions(
            brightness: colorScheme.brightness,
          ),
        ) ??
        TagColors.fromBrightness(colorScheme.brightness);

    final color = colorBuilder(
      TagColorOptions(
        tagType: tag,
        colors: colors,
      ),
    );

    final dynamicColors = ref.watch(enableDynamicColoringProvider);

    // If dynamic colors are disabled, return the color as is
    if (!dynamicColors) return color;

    return color?.harmonizeWith(colorScheme.primary);
  },
  dependencies: [
    enableDynamicColoringProvider,
    colorSchemeProvider,
  ],
);

final tagRepoProvider = Provider.family<TagRepository, BooruConfigAuth>(
  (ref, config) {
    final repo =
        ref.watch(booruEngineRegistryProvider).getRepository(config.booruType);

    final tagRepo = repo?.tag(config);

    if (tagRepo != null) {
      return tagRepo;
    }

    return ref.watch(emptyTagRepoProvider);
  },
);
