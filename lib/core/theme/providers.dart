// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../configs/current.dart';
import '../premiums/providers.dart';
import '../settings/providers.dart';
import '../tags/tag/providers.dart';
import 'colors.dart';
import 'theme_configs.dart';
import 'utils.dart';

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

final customColorsProvider = Provider<ColorSettings?>(
  (ref) {
    final hasPremium = ref.watch(hasPremiumProvider);

    final settingsColors = ref.watch(settingsProvider.select((v) => v.colors));

    final configColors = ref.watch(
      currentReadOnlyBooruConfigThemeProvider.select((v) => v?.colors),
    );

    return hasPremium ? configColors ?? settingsColors : null;
  },
  name: 'colorsProvider',
);

final chipColorsFromTagStringProvider = Provider.family<ChipColors?, String?>(
  (ref, tag) {
    final color = tag != null ? ref.watch(tagColorProvider(tag)) : null;
    final booruChipColors = ref.watch(booruChipColorsProvider);

    return booruChipColors.fromColor(color);
  },
  dependencies: [
    booruChipColorsProvider,
    tagColorProvider,
  ],
  name: 'booruChipColorsFromTagStringProvider',
);
