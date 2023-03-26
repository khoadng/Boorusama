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
    required this.login,
    required this.apiKey,
    required this.booru,
    this.onFailure,
    this.onSuccess,
  });

  final String login;
  final String apiKey;
  final BooruType booru;
  final void Function(String message)? onFailure;
  final void Function(BooruConfig booruConfig)? onSuccess;

  @override
  List<Object?> get props => [login, apiKey, booru, onFailure, onSuccess];
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
        final booru = booruFactory.from(type: event.booru);

        if (event.login.isEmpty && event.apiKey.isEmpty) {
          final credential = UserBooruCredential.anonymous(
            booru: event.booru,
          );

          final user = await userBooruRepository.add(credential);
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
            login: event.login,
            apiKey: event.apiKey,
            booru: booru,
          );
          final credential = UserBooruCredential.withAccount(
            login: event.login,
            apiKey: event.apiKey,
            booruUserId: id,
            booru: event.booru,
          );

          if (credential == null) {
            event.onFailure
                ?.call('Fail to add account. Account might be incorrect');

            return;
          }

          final user = await userBooruRepository.add(credential);

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
