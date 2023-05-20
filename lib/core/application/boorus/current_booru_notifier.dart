// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/provider.dart';

class CurrentBooruConfigNotifier extends Notifier<BooruConfig> {
  CurrentBooruConfigNotifier(
    this.initialConfig,
  ) : super();

  final BooruConfig initialConfig;

  @override
  BooruConfig build() {
    ref.read(authenticationProvider.notifier).logIn();
    return initialConfig;
  }

  Future<void> fetch() async {
    final booruConfig = await ref.read(currentBooruConfigRepoProvider).get();

    if (booruConfig == null) {
      state = BooruConfig.empty;
      return;
    }

    state = booruConfig;
  }

  Future<void> update(BooruConfig booruConfig) async {
    state = booruConfig;
    final settings = ref
        .read(settingsProvider)
        .copyWith(currentBooruConfigId: booruConfig.id);
    ref.read(settingsProvider.notifier).updateSettings(settings);
    ref.read(authenticationProvider.notifier).logIn();
    ref.read(loggerProvider).logI('Booru', 'Current booru config updated');
  }
}
