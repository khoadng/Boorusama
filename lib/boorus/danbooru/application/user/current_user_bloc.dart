// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';

class CurrentUserState extends Equatable {
  const CurrentUserState({
    required this.user,
  });

  factory CurrentUserState.initial() => const CurrentUserState(user: null);

  final UserSelf? user;

  CurrentUserState copyWith({
    UserSelf? Function()? user,
  }) =>
      CurrentUserState(
        user: user != null ? user() : this.user,
      );

  @override
  List<Object?> get props => [user];
}

abstract class CurrentUserEvent extends Equatable {
  const CurrentUserEvent();
}

class CurrentUserFetched extends CurrentUserEvent {
  const CurrentUserFetched();

  @override
  List<Object?> get props => [];
}

class CurrentUserBloc extends Bloc<CurrentUserEvent, CurrentUserState> {
  CurrentUserBloc({
    required UserRepository userRepository,
    required AccountRepository accountRepository,
  }) : super(CurrentUserState.initial()) {
    on<CurrentUserFetched>((event, emit) async {
      final account = await accountRepository.get();

      if (account == Account.empty) {
        return;
      }

      await tryAsync<UserSelf?>(
        action: () => userRepository.getUserSelfById(account.id),
        onSuccess: (data) async {
          emit(state.copyWith(
            user: () => data,
          ));
        },
      );
    });
  }
}
