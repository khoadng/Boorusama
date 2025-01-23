// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../settings/providers.dart';
import '../tags/tag/providers.dart';
import 'colors.dart';
import 'utils.dart';

final booruChipColorsProvider = Provider<BooruChipColors>(
  (ref) {
    return BooruChipColors.colorScheme(
      ref.watch(colorSchemeProvider),
      harmonizeWithPrimary: ref.watch(enableDynamicColoringProvider),
    );
  },
  dependencies: [
    enableDynamicColoringProvider,
    colorSchemeProvider,
  ],
  name: 'booruChipColorsProvider',
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
