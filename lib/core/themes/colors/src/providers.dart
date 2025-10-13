// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/config/types.dart';
import '../../../premiums/providers.dart';
import '../../../settings/providers.dart';
import '../../../tags/tag/providers.dart';
import '../../configs/providers.dart';
import 'utils.dart';

final enableDynamicColoringProvider = Provider<bool>(
  (ref) {
    final settingsValue = ref.watch(
      settingsProvider.select((value) => value.enableDynamicColoring),
    );

    final settingsColorsValue = ref.watch(
      settingsProvider.select((value) => value.colors?.enableDynamicColoring),
    );

    final hasPremium = ref.watch(hasPremiumProvider);

    return !hasPremium ? settingsValue : settingsColorsValue ?? settingsValue;
  },
  name: 'enableDynamicColoringProvider',
  dependencies: [settingsProvider],
);

final booruChipColorsProvider = Provider<BooruChipColors>(
  (ref) {
    final customColors = ref.watch(customColorsProvider);

    return BooruChipColors.colorScheme(
      ref.watch(colorSchemeProvider),
      harmonizeWithPrimary: customColors != null
          ? customColors.harmonizeWithPrimary
          : ref.watch(enableDynamicColoringProvider),
    );
  },
  dependencies: [
    enableDynamicColoringProvider,
    colorSchemeProvider,
  ],
  name: 'booruChipColorsProvider',
);

final chipColorsFromTagStringProvider =
    Provider.family<ChipColors?, (BooruConfigAuth, String?)>(
      (ref, params) {
        final (config, tag) = params;
        final color = tag != null
            ? ref.watch(tagColorProvider((config, tag)))
            : null;
        final booruChipColors = ref.watch(booruChipColorsProvider);

        return booruChipColors.fromColor(color);
      },
      dependencies: [
        booruChipColorsProvider,
        tagColorProvider,
      ],
      name: 'booruChipColorsFromTagStringProvider',
    );

final dynamicColorSupportProvider = Provider<bool>(
  (ref) {
    throw UnimplementedError();
  },
  name: 'dynamicColorSupportProvider',
);

final colorSchemeProvider = Provider<ColorScheme>(
  (ref) {
    throw UnimplementedError();
  },
  name: 'colorSchemeProvider',
);
