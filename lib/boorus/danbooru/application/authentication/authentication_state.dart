part of 'authentication_state_notifier.dart';

class AuthenticationState {
  final Account account;
  final AccountState state;
  AuthenticationState({
    Account this.account,
    AccountState this.state,
  });
}

enum AccountState {
  unknown,
  authenticating,
  errorUnknown,
  errorInvalidPasswordOrUser,
  loggedIn,
  loggedOut,
}

enum ErrorType {
  invalidUsernameOrPassword,
  unknown,
}
