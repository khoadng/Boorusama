// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/boorus/boorus.dart';
import 'package:boorusama/core/provider.dart';

class CurrentBooruConfigNotifier extends Notifier<BooruConfig> {
  CurrentBooruConfigNotifier({
    required this.initialConfig,
  }) : super();

  final BooruConfig initialConfig;

  @override
  BooruConfig build() {
    return initialConfig;
  }

  Future<void> update(BooruConfig booruConfig) async {
    final old = state;
    state = booruConfig;
    final settings = ref
        .read(settingsProvider)
        .copyWith(currentBooruConfigId: booruConfig.id);
    ref.read(settingsProvider.notifier).updateSettings(settings);
    ref.read(loggerProvider).logI('Booru',
        'Current booru config updated from ${intToBooruType(old.booruId)} to ${intToBooruType(booruConfig.booruId)}');
  }
}
