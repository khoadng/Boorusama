part of 'get_all_accounts_bloc.dart';

abstract class GetAllAccountsState extends Equatable {
  const GetAllAccountsState();

  @override
  List<Object> get props => [];
}

class GetAllAccountsInitial extends GetAllAccountsState {}

class GetAllAccountsInProgress extends GetAllAccountsState {}

class GetAllAccountsSuccess extends GetAllAccountsState {
  final List<Account> accounts;

  GetAllAccountsSuccess({this.accounts});
}
