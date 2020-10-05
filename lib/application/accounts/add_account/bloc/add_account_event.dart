part of 'add_account_bloc.dart';

abstract class AddAccountEvent extends Equatable {
  const AddAccountEvent();

  @override
  List<Object> get props => [];
}

class AddAccountRequested extends AddAccountEvent {
  final String username;
  final String password;

  AddAccountRequested({this.username, this.password});
}
