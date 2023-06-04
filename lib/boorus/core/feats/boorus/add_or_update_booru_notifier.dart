// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/provider.dart';

sealed class AddOrUpdateBooruArg extends Equatable {}

final class UpdateConfig extends AddOrUpdateBooruArg {
  UpdateConfig(this.oldConfig);
  final BooruConfig oldConfig;

  @override
  List<Object?> get props => [oldConfig];
}

final class AddNewConfig extends AddOrUpdateBooruArg {
  AddNewConfig(this.uri);
  final Uri uri;

  @override
  List<Object?> get props => [uri];
}

final addOrUpdateBooruProvider = NotifierProvider.autoDispose.family<
    AddOrUpdateBooruNotifier, AddOrUpdateBooruState, AddOrUpdateBooruArg>(
  AddOrUpdateBooruNotifier.new,
  dependencies: [
    booruFactoryProvider,
  ],
);

class AddOrUpdateBooruNotifier extends AutoDisposeFamilyNotifier<
    AddOrUpdateBooruState, AddOrUpdateBooruArg> {
  @override
  AddOrUpdateBooruState build(AddOrUpdateBooruArg arg) {
    final booruFactory = ref.read(booruFactoryProvider);

    return switch (arg) {
      UpdateConfig a => AddOrUpdateBooruState.fromConfig(
          config: a.oldConfig,
          factory: booruFactory,
        ).copyWith(
          unverifiedBooru:
              intToBooruType(a.oldConfig.booruId) == BooruType.unknown,
        ),
      AddNewConfig a => AddOrUpdateBooruState.initial(booruFactory).copyWith(
          selectedBooru: booruFactory.from(
              type: getBooruType(a.uri.toString(), booruFactory.booruData)),
          url: a.uri.toString(),
          unverifiedBooru:
              getBooruType(a.uri.toString(), booruFactory.booruData) ==
                  BooruType.unknown,
        )
    };
  }

  void changeLogin(String newLogin) {
    state = state.copyWith(login: newLogin);
  }

  void changeApiKey(String newApiKey) {
    state = state.copyWith(apiKey: newApiKey);
  }

  void changeUrl(String newUrl) {
    final booruDataList = ref.read(booruFactoryProvider).booruData;
    final booru = getBooruType(newUrl, booruDataList);
    state = state.copyWith(
      url: newUrl,
    );
    changeBooru(booru);
  }

  void changeBooru(BooruType booruType) {
    final booru = ref.watch(booruFactoryProvider).from(type: booruType);
    state = state.copyWith(
      selectedBooru: booru,
    );
  }

  void changeBooruEngine(BooruEngine? engine) {
    if (engine == null) return;
    final booru = booruEngineToBooruType(engine);
    changeBooru(booru);
  }

  void changeRatingFilter(BooruConfigRatingFilter? ratingFilter) {
    if (ratingFilter == null) return;

    state = state.copyWith(ratingFilter: ratingFilter);
  }

  void changeConfigName(String newConfigName) {
    state = state.copyWith(configName: newConfigName);
  }

  void toggleApiKey() {
    state = state.copyWith(revealKey: !state.revealKey);
  }

  void toggleDeleted() {
    final value =
        state.deletedItemBehavior == BooruConfigDeletedItemBehavior.hide
            ? BooruConfigDeletedItemBehavior.show
            : BooruConfigDeletedItemBehavior.hide;
    state = state.copyWith(deletedItemBehavior: value);
  }

  void submit({
    bool setCurrentBooruOnSubmit = false,
  }) {
    final newConfig =
        state.createNewBooruConfig(ref.read(booruFactoryProvider));
    switch (arg) {
      case UpdateConfig a:
        ref.read(booruConfigProvider.notifier).update(
              config: newConfig,
              oldConfig: a.oldConfig,
              id: a.oldConfig.id,
              onSuccess: (booruConfig) => ref
                  .read(currentBooruConfigProvider.notifier)
                  .update(booruConfig),
            );
        break;
      case AddNewConfig _:
        ref.read(booruConfigProvider.notifier).addFromAddBooruConfig(
              setAsCurrent: setCurrentBooruOnSubmit,
              newConfig: newConfig,
            );
        break;
    }
  }
}

mixin AddOrUpdateBooruNotifierMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  AddOrUpdateBooruArg get arg;

  void changeLogin(String newLogin) =>
      ref.read(addOrUpdateBooruProvider(arg).notifier).changeLogin(newLogin);

  void changeApiKey(String newApiKey) =>
      ref.read(addOrUpdateBooruProvider(arg).notifier).changeApiKey(newApiKey);

  void changeUrl(String newUrl) =>
      ref.read(addOrUpdateBooruProvider(arg).notifier).changeUrl(newUrl);

  void changeConfigName(String newConfigName) => ref
      .read(addOrUpdateBooruProvider(arg).notifier)
      .changeConfigName(newConfigName);

  void toggleApiKey() =>
      ref.read(addOrUpdateBooruProvider(arg).notifier).toggleApiKey();

  void toggleDeleted() =>
      ref.read(addOrUpdateBooruProvider(arg).notifier).toggleDeleted();

  void changeRatingFilter(BooruConfigRatingFilter? ratingFilter) => ref
      .read(addOrUpdateBooruProvider(arg).notifier)
      .changeRatingFilter(ratingFilter);

  void changeBooruEngine(BooruEngine? engine) => ref
      .read(addOrUpdateBooruProvider(arg).notifier)
      .changeBooruEngine(engine);

  void submit({
    bool setCurrentBooruOnSubmit = false,
  }) =>
      ref.read(addOrUpdateBooruProvider(arg).notifier).submit(
            setCurrentBooruOnSubmit: setCurrentBooruOnSubmit,
          );
}
