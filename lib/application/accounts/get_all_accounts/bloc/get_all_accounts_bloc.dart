import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/accounts/account.dart';
import 'package:boorusama/domain/accounts/i_account_repository.dart';
import 'package:equatable/equatable.dart';

part 'get_all_accounts_event.dart';
part 'get_all_accounts_state.dart';

class GetAllAccountsBloc
    extends Bloc<GetAllAccountsEvent, GetAllAccountsState> {
  final IAccountRepository accountRepository;

  GetAllAccountsBloc(this.accountRepository) : super(GetAllAccountsInitial());

  @override
  Stream<GetAllAccountsState> mapEventToState(
    GetAllAccountsEvent event,
  ) async* {
    if (event is GetAllAccountsRequested) {
      yield GetAllAccountsInProgress();
      final accounts = await accountRepository.getAll();
      yield GetAllAccountsSuccess(accounts: accounts);
    }
  }
}
