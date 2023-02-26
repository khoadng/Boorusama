// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';

class UserState extends Equatable {
  const UserState({
    required this.user,
    required this.status,
  });

  factory UserState.initial() => UserState(
        user: User.placeholder(),
        status: LoadStatus.initial,
      );

  final User user;
  final LoadStatus status;

  UserState copyWith({
    User? user,
    LoadStatus? status,
  }) =>
      UserState(
        user: user ?? this.user,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props => [user, status];
}

abstract class UserEvent extends Equatable {
  const UserEvent();
}

class UserFetched extends UserEvent {
  const UserFetched({
    required this.uid,
  });

  final int uid;

  @override
  List<Object?> get props => [uid];
}

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc({
    required UserRepository userRepository,
  }) : super(UserState.initial()) {
    on<UserFetched>((event, emit) async {
      await tryAsync<User>(
        action: () => userRepository.getUserById(event.uid),
        onFailure: (error, stackTrace) =>
            emit(state.copyWith(status: LoadStatus.failure)),
        onUnknownFailure: (stackTrace, error) =>
            emit(state.copyWith(status: LoadStatus.failure)),
        onSuccess: (data) async {
          emit(state.copyWith(
            user: data,
            status: LoadStatus.success,
          ));
        },
      );
    });
  }
}
