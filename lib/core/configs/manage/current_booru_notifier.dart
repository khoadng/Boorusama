// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';

class CurrentBooruConfigNotifier extends Notifier<BooruConfig> {
  CurrentBooruConfigNotifier({
    required this.initialConfig,
  }) : super();

  final BooruConfig initialConfig;

  @override
  BooruConfig build() {
    return initialConfig;
  }

  Future<void> setEmpty() async {
    return update(BooruConfig.empty);
  }

  Future<void> update(BooruConfig booruConfig) async {
    // if same config, do nothing
    if (booruConfig == state) return;

    final old = state;
    state = booruConfig;
    final settings = ref
        .read(settingsProvider)
        .copyWith(currentBooruConfigId: booruConfig.id);
    await ref.read(settingsProvider.notifier).updateSettings(settings);
    ref.read(loggerProvider).logI('Booru',
        'Current booru config updated from ${intToBooruType(old.booruId)} to ${intToBooruType(booruConfig.booruId)}');
  }
}
