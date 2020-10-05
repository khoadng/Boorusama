part of 'get_all_accounts_bloc.dart';

abstract class GetAllAccountsEvent extends Equatable {
  const GetAllAccountsEvent();

  @override
  List<Object> get props => [];
}

class GetAllAccountsRequested extends GetAllAccountsEvent {}
