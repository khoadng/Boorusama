import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/accounts/i_account_repository.dart';
import 'package:boorusama/domain/users/i_user_repository.dart';
import 'package:boorusama/domain/users/user.dart';
import 'package:equatable/equatable.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final IAccountRepository _accountRepository;
  final IUserRepository _userRepository;

  UserBloc(this._accountRepository, this._userRepository)
      : super(UserInitial());

  @override
  Stream<UserState> mapEventToState(
    UserEvent event,
  ) async* {
    if (event is UserRequested) {
      yield UserLoading();
      final account = await _accountRepository.get();
      final user = await _userRepository.getUserById(account.id);
      yield UserFetched(user);
    }
  }
}
