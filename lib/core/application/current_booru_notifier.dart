import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentBooruConfigProvider =
    NotifierProvider<CurrentBooruConfigNotifier, BooruConfig>(
  () => throw UnimplementedError(),
  dependencies: [
    currentBooruConfigRepoProvider,
    settingsProvider,
    authenticationProvider,
  ],
);

final currentBooruProvider = Provider<Booru>(
  (ref) {
    final booruConfig = ref.watch(currentBooruConfigProvider);
    final booruFactory = ref.watch(booruFactoryProvider);
    final booru = booruFactory.from(type: intToBooruType(booruConfig.booruId));

    return booru;
  },
  dependencies: [
    currentBooruConfigProvider,
    booruFactoryProvider,
  ],
);

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
  }
}
