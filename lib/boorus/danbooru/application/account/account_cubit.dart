// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/account.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';

class AccountCubit extends Cubit<AsyncLoadState<Account>> {
  AccountCubit({
    required this.accountRepository,
  }) : super(AsyncLoadState.initial());

  final IAccountRepository accountRepository;

  void setAccount(Account account) {
    TryAsync<void>(
        action: () => accountRepository.add(account),
        onLoading: () => emit(AsyncLoadState.loading()),
        onFailure: (stackTrace, error) => emit(AsyncLoadState.failure()),
        onSuccess: (_) {
          emit(AsyncLoadState.success(account));
        });
  }

  void removeAccount() {
    TryAsync<void>(
        action: () async {
          final account = await accountRepository.get();
          return accountRepository.remove(account.id);
        },
        onLoading: () => emit(AsyncLoadState.loading()),
        onFailure: (stackTrace, error) => emit(AsyncLoadState.failure()),
        onSuccess: (_) {
          emit(AsyncLoadState.success(Account.empty));
        });
  }

  void getCurrentAccount() {
    TryAsync<Account>(
        action: () => accountRepository.get(),
        onLoading: () => emit(AsyncLoadState.loading()),
        onFailure: (stackTrace, error) => emit(AsyncLoadState.failure()),
        onSuccess: (acc) {
          emit(AsyncLoadState.success(acc));
        });
  }
}
