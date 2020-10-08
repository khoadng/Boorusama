import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/accounts/account.dart';
import 'package:boorusama/domain/accounts/i_account_repository.dart';
import 'package:equatable/equatable.dart';

part 'remove_account_event.dart';
part 'remove_account_state.dart';

class RemoveAccountBloc extends Bloc<RemoveAccountEvent, RemoveAccountState> {
  final IAccountRepository _accountRepository;

  RemoveAccountBloc(this._accountRepository) : super(RemoveAccountInitial());

  @override
  Stream<RemoveAccountState> mapEventToState(
    RemoveAccountEvent event,
  ) async* {
    if (event is RemoveAccountRequested) {
      yield RemoveAccountInProgress();
      await _accountRepository.remove(event.account);
      yield RemoveAccountSuccess(account: event.account);
    }
  }
}
