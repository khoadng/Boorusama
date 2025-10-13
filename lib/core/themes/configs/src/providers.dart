// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/manage/providers.dart';
import '../../../premiums/providers.dart';
import '../../../settings/providers.dart';
import 'color_settings.dart';

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
