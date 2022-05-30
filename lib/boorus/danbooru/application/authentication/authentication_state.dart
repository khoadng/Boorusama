part of 'authentication_state_notifier.dart';

class AuthenticationState {
  final Account? account;
  final AccountState state;
  AuthenticationState({
    this.account,
    required this.state,
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
