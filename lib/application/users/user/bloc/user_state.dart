part of 'user_bloc.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserEmpty extends UserState {}

class UserLoading extends UserState {}

class UserFetched extends UserState {
  final User user;

  UserFetched({
    @required this.user,
  });

  @override
  List<Object> get props => [user];
}
