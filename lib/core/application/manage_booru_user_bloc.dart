// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/application/common.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/utils/collection_utils.dart';

class ManageBooruState extends Equatable {
  const ManageBooruState({
    required this.configs,
  });

  factory ManageBooruState.initial() => const ManageBooruState(configs: []);

  final List<BooruConfig>? configs;

  ManageBooruState copyWith({
    List<BooruConfig>? Function()? configs,
  }) =>
      ManageBooruState(
        configs: configs != null ? configs() : this.configs,
      );

  @override
  List<Object?> get props => [configs];
}

abstract class ManageBooruEvent extends Equatable {
  const ManageBooruEvent();
}

class ManageBooruFetched extends ManageBooruEvent {
  const ManageBooruFetched();

  @override
  List<Object?> get props => [];
}

class ManageBooruAdded extends ManageBooruEvent {
  const ManageBooruAdded({
    required this.config,
    this.onFailure,
    this.onSuccess,
  });

  final AddNewBooruConfig config;
  final void Function(String message)? onFailure;
  final void Function(BooruConfig booruConfig)? onSuccess;

  @override
  List<Object?> get props => [
        config,
        onFailure,
        onSuccess,
      ];
}

class AddNewBooruConfig {
  AddNewBooruConfig({
    required this.login,
    required this.apiKey,
    required this.booru,
    required this.configName,
    required this.hideDeleted,
    required this.ratingFilter,
    required this.url,
  });

  final String login;
  final String apiKey;
  final BooruType booru;
  final String configName;
  final bool hideDeleted;
  final BooruConfigRatingFilter ratingFilter;
  final String url;
}

class ManageBooruRemoved extends ManageBooruEvent {
  const ManageBooruRemoved({
    required this.user,
    required this.onFailure,
  });

  final BooruConfig user;
  final void Function(String message)? onFailure;

  @override
  List<Object?> get props => [user, onFailure];
}

class ManageBooruUpdated extends ManageBooruEvent {
  const ManageBooruUpdated({
    required this.config,
    required this.oldConfig,
    required this.id,
    this.onFailure,
    this.onSuccess,
  });

  final AddNewBooruConfig config;
  final BooruConfig oldConfig;
  final int id;
  final void Function(String message)? onFailure;
  final void Function(BooruConfig booruConfig)? onSuccess;

  @override
  List<Object?> get props => [
        id,
        config,
        oldConfig,
        onFailure,
        onSuccess,
      ];
}

class ManageBooruBloc extends Bloc<ManageBooruEvent, ManageBooruState> {
  ManageBooruBloc({
    required BooruConfigRepository userBooruRepository,
    required BooruUserIdentityProvider booruUserIdentityProvider,
    required BooruFactory booruFactory,
  }) : super(ManageBooruState.initial()) {
    on<ManageBooruFetched>((event, emit) async {
      await tryAsync<List<BooruConfig>>(
        action: () => userBooruRepository.getAll(),
        onSuccess: (data) async {
          emit(state.copyWith(
            configs: () => data,
          ));
        },
      );
    });

    on<ManageBooruAdded>((event, emit) async {
      try {
        if (event.config.login.isEmpty && event.config.apiKey.isEmpty) {
          final booruConfigData = BooruConfigData.anonymous(
            booru: event.config.booru,
            filter: event.config.ratingFilter,
            name: event.config.configName,
            url: event.config.url,
          );

          final config = await userBooruRepository.add(booruConfigData);
          final configs = state.configs ?? [];

          if (config == null) {
            event.onFailure
                ?.call('Fail to add account. Account might be incorrect');

            return;
          }

          event.onSuccess?.call(config);

          emit(state.copyWith(
            configs: () => [
              ...configs,
              config,
            ],
          ));
        } else {
          final booruConfigData = BooruConfigData(
            login: event.config.login,
            apiKey: event.config.apiKey,
            deletedItemBehavior: event.config.hideDeleted
                ? BooruConfigDeletedItemBehavior.hide.index
                : BooruConfigDeletedItemBehavior.show.index,
            ratingFilter: event.config.ratingFilter.index,
            name: event.config.configName,
            url: event.config.url,
            booruId: event.config.booru.index,
          );

          final config = await userBooruRepository.add(booruConfigData);

          if (config == null) {
            event.onFailure
                ?.call('Fail to add account. Account might be incorrect');

            return;
          }

          final configs = state.configs ?? [];

          event.onSuccess?.call(config);

          emit(state.copyWith(
            configs: () => [
              ...configs,
              config,
            ],
          ));
        }
      } catch (e) {
        event.onFailure?.call('Failed to add account');
      }
    });

    on<ManageBooruUpdated>((event, emit) async {
      final booruConfigData = event.oldConfig.hasLoginDetails()
          ? BooruConfigData(
              login: event.config.login,
              apiKey: event.config.apiKey,
              deletedItemBehavior: event.config.hideDeleted
                  ? BooruConfigDeletedItemBehavior.hide.index
                  : BooruConfigDeletedItemBehavior.show.index,
              ratingFilter: event.config.ratingFilter.index,
              name: event.config.configName,
              url: event.config.url,
              booruId: event.config.booru.index,
            )
          : BooruConfigData(
              login: event.config.login,
              apiKey: event.config.apiKey,
              booruId: event.config.booru.index,
              deletedItemBehavior: event.config.hideDeleted
                  ? BooruConfigDeletedItemBehavior.hide.index
                  : BooruConfigDeletedItemBehavior.show.index,
              ratingFilter: event.config.ratingFilter.index,
              name: event.config.configName,
              url: event.config.url,
            );

      final configs = state.configs;

      if (configs == null) {
        event.onFailure?.call('Failed to update account');

        return;
      }

      final config =
          await userBooruRepository.update(event.id, booruConfigData);

      if (config == null) {
        event.onFailure?.call('Failed to update account');

        return;
      }

      final newConfigs =
          configs.replaceFirst(config, (item) => item.id == event.id);

      event.onSuccess?.call(config);

      emit(state.copyWith(
        configs: () => newConfigs,
      ));
    });

    on<ManageBooruRemoved>((event, emit) async {
      if (state.configs == null) {
        event.onFailure?.call('User does not exists');

        return;
      }

      final configs = [...state.configs!];

      await tryAsync<void>(
        action: () => userBooruRepository.remove(event.user),
        onFailure: (error, stackTrace) =>
            event.onFailure?.call(error.toString()),
        onUnknownFailure: (stackTrace, error) =>
            event.onFailure?.call(error.toString()),
        onSuccess: (_) async {
          configs.remove(event.user);
          emit(state.copyWith(
            configs: () => configs,
          ));
        },
      );
    });
  }
}
