import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/users/i_user_repository.dart';
import 'package:boorusama/domain/users/user.dart';
import 'package:equatable/equatable.dart';

part 'user_list_event.dart';
part 'user_list_state.dart';

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  final IUserRepository _userRepository;

  UserListBloc(this._userRepository) : super(UserListInitial());

  @override
  Stream<UserListState> mapEventToState(
    UserListEvent event,
  ) async* {
    if (event is UserListRequested) {
      yield UserListLoading();
      final users =
          await _userRepository.getUsersByIdStringComma(event.idStringComma);
      yield UserListFetched(users);
    }
  }
}
