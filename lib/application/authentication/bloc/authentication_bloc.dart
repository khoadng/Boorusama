import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/application/authentication/services/i_scrapper_service.dart';
import 'package:boorusama/domain/accounts/account.dart';
import 'package:boorusama/domain/accounts/i_account_repository.dart';
import 'package:boorusama/infrastructure/services/scrapper_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final IAccountRepository _accountRepository;
  final IScrapperService _scrapperService;

  AuthenticationBloc({
    @required IAccountRepository accountRepository,
    @required IScrapperService scrapperService,
  })  : _accountRepository = accountRepository,
        _scrapperService = scrapperService,
        super(AuthenticationUnknown());

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (state is AuthenticationUnknown) {
      if (event is AuthenticationRequested) {
        yield Authenticating();
        final accounts = await _accountRepository.getAll();
        if (accounts != null && accounts.isNotEmpty) {
          yield Authenticated(account: accounts.first);
        } else {
          yield Unauthenticated(accountId: null);
        }
      }
    } else if (state is Authenticated) {
      if (event is UserLoggedOut) {
        yield Authenticating();
        await _accountRepository.remove(event.accountId);
        yield Unauthenticated(accountId: event.accountId);
      }
    } else if (state is Unauthenticated) {
      if (event is UserLoggedIn) {
        yield Authenticating();
        try {
          final account = await _scrapperService.crawlAccountData(
              event.username, event.password);
          await _accountRepository.add(account);
          yield Authenticated(account: account);
        } on InvalidUsernameOrPassword catch (e) {
          yield AuthenticationError(
            error: "Login error",
            message: "Invalid username or password",
          );
          yield Unauthenticated(accountId: 0);
        }
      }
    } else if (state is Authenticating) {
      // Authentication in progress, skip all event
    } else {
      throw UnknownStateException();
    }
  }
}

class UnknownStateException implements Exception {}
