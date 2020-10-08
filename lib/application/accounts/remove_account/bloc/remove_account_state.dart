part of 'remove_account_bloc.dart';

abstract class RemoveAccountState extends Equatable {
  const RemoveAccountState();

  @override
  List<Object> get props => [];
}

class RemoveAccountInitial extends RemoveAccountState {}

class RemoveAccountInProgress extends RemoveAccountState {}

class RemoveAccountSuccess extends RemoveAccountState {
  final Account account;

  RemoveAccountSuccess({this.account});
}
