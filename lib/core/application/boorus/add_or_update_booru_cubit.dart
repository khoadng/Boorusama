// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/boorus/add_or_update_booru_state.dart';
import 'package:boorusama/core/domain/boorus.dart';

typedef AddOrUpdateBooruBuider
    = BlocBuilder<AddOrUpdateBooruCubit, AddOrUpdateBooruState>;

class AddOrUpdateBooruCubit extends Cubit<AddOrUpdateBooruState> {
  AddOrUpdateBooruCubit({
    required this.booruFactory,
    BooruConfig? initialConfig,
  }) : super(initialConfig == null
            ? AddOrUpdateBooruState.initial(booruFactory)
            : AddOrUpdateBooruState.fromConfig(
                config: initialConfig,
                factory: booruFactory,
              ));

  final BooruFactory booruFactory;

  void changeLogin(String newLogin) {
    emit(state.copyWith(login: newLogin));
  }

  void changeApiKey(String newApiKey) {
    emit(state.copyWith(apiKey: newApiKey));
  }

  void changeUrl(String newUrl) {
    final booruType = getBooruType(newUrl, booruFactory.booruData);
    final booru = booruFactory.from(type: booruType);

    emit(state.copyWith(
      url: newUrl,
      selectedBooru: booru,
    ));
  }

  void changeRatingFilter(BooruConfigRatingFilter? ratingFilter) {
    if (ratingFilter == null) return;

    emit(state.copyWith(ratingFilter: ratingFilter));
  }

  void changeConfigName(String newConfigName) {
    emit(state.copyWith(configName: newConfigName));
  }

  void toggleApiKey() {
    emit(state.copyWith(revealKey: !state.revealKey));
  }

  void toggleDeleted() {
    final value =
        state.deletedItemBehavior == BooruConfigDeletedItemBehavior.hide
            ? BooruConfigDeletedItemBehavior.show
            : BooruConfigDeletedItemBehavior.hide;
    emit(state.copyWith(deletedItemBehavior: value));
  }
}

mixin AddOrUpdateBooruCubitMixin<T extends StatefulWidget> on State<T> {
  AddOrUpdateBooruCubit get addOrUpdateBooruCubit =>
      context.read<AddOrUpdateBooruCubit>();

  void changeLogin(String newLogin) =>
      addOrUpdateBooruCubit.changeLogin(newLogin);

  void changeApiKey(String newApiKey) =>
      addOrUpdateBooruCubit.changeApiKey(newApiKey);

  void changeUrl(String newUrl) => addOrUpdateBooruCubit.changeUrl(newUrl);

  void changeConfigName(String newConfigName) =>
      addOrUpdateBooruCubit.changeConfigName(newConfigName);

  void toggleApiKey() => addOrUpdateBooruCubit.toggleApiKey();

  void toggleDeleted() => addOrUpdateBooruCubit.toggleDeleted();

  void changeRatingFilter(BooruConfigRatingFilter? ratingFilter) =>
      addOrUpdateBooruCubit.changeRatingFilter(ratingFilter);
}
