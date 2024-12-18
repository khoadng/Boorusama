// Dart imports:
import 'dart:ui';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../boorus/engine/providers.dart';
import '../../../configs/config.dart';
import '../../../configs/current.dart';
import '../../../configs/ref.dart';
import '../../../settings/providers.dart';
import '../../../theme.dart';
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
