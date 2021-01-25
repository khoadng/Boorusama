// Package imports:
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/account.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/users/user_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/services/scrapper_service.dart';
import 'package:boorusama/core/application/scraper/i_scrapper_service.dart';

part 'authentication_state.dart';
part 'authentication_state_notifier.freezed.dart';

final authenticationStateNotifierProvider =
    StateNotifierProvider<AuthenticationNotifier>((ref) {
  return AuthenticationNotifier(ref);
});

final _account = Provider<Account>(
    (ref) => ref.watch(authenticationStateNotifierProvider.state).account);

final _accountState = Provider<AccountState>(
    (ref) => ref.watch(authenticationStateNotifierProvider.state).state);

final currentAccountProvider = Provider<Account>((ref) => ref.watch(_account));

final accountStateProvider = Provider<AccountState>((ref) {
  final state = ref.watch(_accountState);
  return state;
});

final blacklistedTagsProvider = FutureProvider<List<String>>((ref) async {
  final account = ref.watch(_account);
  final userRepository = ref.watch(userProvider);
  final settingRepository = ref.watch(settingsProvider);

  final user = await userRepository.getUserById(account.id);
  //TODO: WARNING error prone code, need serialization
  final settings = await settingRepository.load();
  final blacklistedTags = user.blacklistedTags.join("\n");
  settings.blacklistedTags = blacklistedTags;
  await settingRepository.save(settings);

  return user.blacklistedTags;
});

class AuthenticationNotifier extends StateNotifier<AuthenticationState> {
  final IScrapperService _scrapperService;
  final IAccountRepository _accountRepository;

  AuthenticationNotifier(ProviderReference ref)
      : _scrapperService = ref.read(scrapperProvider),
        _accountRepository = ref.read(accountProvider),
        super(AuthenticationState.initial());

  void logIn([String username, String password]) async {
    return state.state.when(
        unknown: () async {
          final accounts = await _accountRepository.getAll();
          if (accounts != null && accounts.isNotEmpty) {
            state = state.copyWith(
              account: accounts.first,
              state: AccountState.loggedIn(),
            );
            return accounts.first;
          } else {
            state = state.copyWith(
              account: null,
              state: AccountState.loggedOut(),
            );
          }
        },
        authenticating: () {},
        error: () {},
        loggedIn: () => state.account,
        loggedOut: () async {
          try {
            state = state.copyWith(
              state: AccountState.authenticating(),
            );
            final account =
                await _scrapperService.crawlAccountData(username, password);
            await _accountRepository.add(account);
            state = state.copyWith(
              account: account,
              state: AccountState.loggedIn(),
            );
          } on InvalidUsernameOrPassword {
            state = state.copyWith(
              state: AccountState.error(),
            );
          } on Error {
            state = state.copyWith(
              state: AccountState.error(),
            );
          }
        });
  }

  void logOut() async {
    final account = state.account;
    await _accountRepository.remove(account.id);

    state = state.copyWith(
      account: null,
      state: AccountState.loggedOut(),
    );
  }
}
