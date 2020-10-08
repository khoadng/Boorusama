part of 'remove_account_bloc.dart';

abstract class RemoveAccountEvent extends Equatable {
  const RemoveAccountEvent();

  @override
  List<Object> get props => [];
}

class RemoveAccountRequested extends RemoveAccountEvent {
  final Account account;

  RemoveAccountRequested({this.account});
}
