// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/account.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/profile/i_profile_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/profile/profile_repository.dart';

part 'authentication_state.dart';

final isLoggedInProvider = Provider<bool>((ref) {
  final notifier = ref.watch(authenticationStateNotifierProvider.state);
  final isLoggedIn = notifier.state == AccountState.loggedIn;
  return isLoggedIn;
});

final authenticationStateNotifierProvider =
    StateNotifierProvider<AuthenticationNotifier>((ref) {
  throw UnimplementedError("Override needed");
});

final _account = Provider<Account?>(
    (ref) => ref.watch(authenticationStateNotifierProvider.state).account);

final _accountState = Provider<AccountState>(
    (ref) => ref.watch(authenticationStateNotifierProvider.state).state);

final currentAccountProvider = Provider<Account?>((ref) => ref.watch(_account));

final accountStateProvider = Provider<AccountState>((ref) {
  final state = ref.watch(_accountState);
  return state;
});

class AuthenticationNotifier extends StateNotifier<AuthenticationState> {
  AuthenticationNotifier(
      ProviderReference ref, IProfileRepository profileRepository)
      : _accountRepository = ref.read(accountProvider),
        _profileRepository = profileRepository,
        super(AuthenticationState(
          account: Account.empty,
          state: AccountState.unknown,
        ));

  final IAccountRepository _accountRepository;
  final IProfileRepository _profileRepository;

  void logIn([String username = '', String password = '']) async {
    if (state.state == AccountState.unknown) {
      final account = await _accountRepository.get();
      if (account != Account.empty) {
        state =
            AuthenticationState(account: account, state: AccountState.loggedIn);
      } else {
        state =
            AuthenticationState(account: null, state: AccountState.loggedOut);
      }
    } else if (state.state == AccountState.loggedIn) {
    } else {
      try {
        state = AuthenticationState(
            account: state.account, state: AccountState.authenticating);
        // Obsolete due to Cloudfare DDoS protection
        // final account =
        //     await _scrapperService.crawlAccountData(username, password);
        var profile = await _profileRepository.getProfile(
            username: username, apiKey: password);
        var account = new Account.create(username, password, profile!.id);

        await _accountRepository.add(account);
        state =
            AuthenticationState(account: account, state: AccountState.loggedIn);
      } on InvalidUsernameOrPassword {
        state = AuthenticationState(
            account: state.account,
            state: AccountState.errorInvalidPasswordOrUser);
      } on Exception {
        state = AuthenticationState(
            account: state.account, state: AccountState.errorUnknown);
      }
    }
  }

  void logOut() async {
    final account = state.account;
    await _accountRepository.remove(account!.id);

    state = AuthenticationState(account: null, state: AccountState.loggedOut);
  }
}
