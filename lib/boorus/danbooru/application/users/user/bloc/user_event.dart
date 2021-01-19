part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

//TODO: should handle multiple users?
class UserRequested extends UserEvent {}
