// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/account.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';

class AccountCubit extends Cubit<AsyncLoadState<Account>> {
  AccountCubit({
    required this.accountRepository,
  }) : super(const AsyncLoadState.initial());

  final IAccountRepository accountRepository;

  void setAccount(Account account) {
    tryAsync<void>(
        action: () => accountRepository.add(account),
        onLoading: () => emit(const AsyncLoadState.loading()),
        onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
        onSuccess: (_) {
          emit(AsyncLoadState.success(account));
        });
  }

  void removeAccount() {
    tryAsync<void>(
        action: () async {
          final account = await accountRepository.get();
          return accountRepository.remove(account.id);
        },
        onLoading: () => emit(const AsyncLoadState.loading()),
        onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
        onSuccess: (_) {
          emit(const AsyncLoadState.success(Account.empty));
        });
  }

  void getCurrentAccount() {
    tryAsync<Account>(
        action: accountRepository.get,
        onLoading: () => emit(const AsyncLoadState.loading()),
        onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
        onSuccess: (acc) {
          emit(AsyncLoadState.success(acc));
        });
  }
}
