// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/application/common.dart';
import 'package:boorusama/core/domain/boorus.dart';

class ManageBooruUserState extends Equatable {
  const ManageBooruUserState({
    required this.users,
  });

  factory ManageBooruUserState.initial() =>
      const ManageBooruUserState(users: []);

  final List<BooruConfig>? users;

  ManageBooruUserState copyWith({
    List<BooruConfig>? Function()? users,
  }) =>
      ManageBooruUserState(
        users: users != null ? users() : this.users,
      );

  @override
  List<Object?> get props => [users];
}

abstract class ManageBooruUserEvent extends Equatable {
  const ManageBooruUserEvent();
}

class ManageBooruUserFetched extends ManageBooruUserEvent {
  const ManageBooruUserFetched();

  @override
  List<Object?> get props => [];
}

class ManageBooruUserAdded extends ManageBooruUserEvent {
  const ManageBooruUserAdded({
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
  });

  final String login;
  final String apiKey;
  final BooruType booru;
  final String configName;
  final bool hideDeleted;
  final bool ratingFilter;
}

class ManageBooruUserRemoved extends ManageBooruUserEvent {
  const ManageBooruUserRemoved({
    required this.user,
    required this.onFailure,
  });

  final BooruConfig user;
  final void Function(String message)? onFailure;

  @override
  List<Object?> get props => [user, onFailure];
}

class ManageBooruUserBloc
    extends Bloc<ManageBooruUserEvent, ManageBooruUserState> {
  ManageBooruUserBloc({
    required BooruConfigRepository userBooruRepository,
    required BooruUserIdentityProvider booruUserIdentityProvider,
    required BooruFactory booruFactory,
  }) : super(ManageBooruUserState.initial()) {
    on<ManageBooruUserFetched>((event, emit) async {
      await tryAsync<List<BooruConfig>>(
        action: () => userBooruRepository.getAll(),
        onSuccess: (data) async {
          emit(state.copyWith(
            users: () => data,
          ));
        },
      );
    });

    on<ManageBooruUserAdded>((event, emit) async {
      try {
        final booru = booruFactory.from(type: event.config.booru);

        if (event.config.login.isEmpty && event.config.apiKey.isEmpty) {
          final booruConfigData = BooruConfigData.anonymous(
            booru: event.config.booru,
            filter: event.config.ratingFilter
                ? BooruConfigRatingFilter.hideNSFW
                : BooruConfigRatingFilter.none,
            name: event.config.configName,
          );

          final user = await userBooruRepository.add(booruConfigData);
          final users = state.users ?? [];

          if (user == null) {
            event.onFailure
                ?.call('Fail to add account. Account might be incorrect');

            return;
          }

          event.onSuccess?.call(user);

          emit(state.copyWith(
            users: () => [
              ...users,
              user,
            ],
          ));
        } else {
          final id = await booruUserIdentityProvider.getAccountId(
            login: event.config.login,
            apiKey: event.config.apiKey,
            booru: booru,
          );
          final booruConfigData = BooruConfigData.withAccount(
            login: event.config.login,
            apiKey: event.config.apiKey,
            booruUserId: id,
            booru: event.config.booru,
            deletedItemBehavior: event.config.hideDeleted
                ? BooruConfigDeletedItemBehavior.hide
                : BooruConfigDeletedItemBehavior.show,
            filter: event.config.ratingFilter
                ? BooruConfigRatingFilter.hideNSFW
                : BooruConfigRatingFilter.none,
            name: event.config.configName,
          );

          if (booruConfigData == null) {
            event.onFailure
                ?.call('Fail to add account. Account might be incorrect');

            return;
          }

          final user = await userBooruRepository.add(booruConfigData);

          if (user == null) {
            event.onFailure
                ?.call('Fail to add account. Account might be incorrect');

            return;
          }

          final users = state.users ?? [];

          event.onSuccess?.call(user);

          emit(state.copyWith(
            users: () => [
              ...users,
              user,
            ],
          ));
        }
      } catch (e) {
        event.onFailure?.call('Failed to add account');
      }
    });

    on<ManageBooruUserRemoved>((event, emit) async {
      if (state.users == null) {
        event.onFailure?.call('User does not exists');

        return;
      }

      final users = [...state.users!];

      await tryAsync<void>(
        action: () => userBooruRepository.remove(event.user),
        onFailure: (error, stackTrace) =>
            event.onFailure?.call(error.toString()),
        onUnknownFailure: (stackTrace, error) =>
            event.onFailure?.call(error.toString()),
        onSuccess: (_) async {
          users.remove(event.user);
          emit(state.copyWith(
            users: () => users,
          ));
        },
      );
    });
  }
}
