import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/application/accounts/add_account/services/i_scrapper_service.dart';
import 'package:boorusama/domain/accounts/account.dart';
import 'package:boorusama/domain/accounts/i_account_repository.dart';
import 'package:equatable/equatable.dart';

part 'add_account_event.dart';
part 'add_account_state.dart';

class AddAccountBloc extends Bloc<AddAccountEvent, AddAccountState> {
  final IAccountRepository accountRepository;
  final IScrapperService scrapperService;

  AddAccountBloc({this.accountRepository, this.scrapperService})
      : super(AddAccountInitial());

  @override
  Stream<AddAccountState> mapEventToState(
    AddAccountEvent event,
  ) async* {
    if (event is AddAccountRequested) {
      yield AddAccountProcessing();
      final account = await scrapperService.crawlAccountData(
          event.username, event.password);
      await accountRepository.add(account);
      yield AddAccountDone(account: account);
    }
  }
}
