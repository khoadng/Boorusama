/// Thrown when a site rejects the credentials of the current profile.
abstract interface class AuthenticationFailure implements Exception {
  String get message;
}
