part of 'user_list_bloc.dart';

abstract class UserListEvent extends Equatable {
  const UserListEvent();

  @override
  List<Object> get props => [];
}

class UserListRequested extends UserListEvent {
  final String idStringComma;

  UserListRequested(this.idStringComma);
}
