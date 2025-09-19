import 'booru_config.dart';

class DefaultBooruLoginDetails
    with UnrestrictedBooruLoginDetails
    implements BooruLoginDetails {
  const DefaultBooruLoginDetails({
    required this.login,
    required this.apiKey,
    required this.url,
  });

  final String? login;
  final String? apiKey;
  final String url;

  @override
  bool hasLogin() {
    if (login == null || apiKey == null) return false;
    if (login!.isEmpty && apiKey!.isEmpty) return false;

    return true;
  }
}

class ApiAndCookieBasedLoginDetails
    with UnrestrictedBooruLoginDetails
    implements BooruLoginDetails {
  ApiAndCookieBasedLoginDetails({
    required this.config,
  });

  final BooruConfigAuth config;

  @override
  bool hasLogin() => switch (config) {
    // Cookies based auth
    BooruConfigAuth(passHash: final passHash?) => passHash.isNotEmpty,

    // API key based auth so user must provide both username and api key
    BooruConfigAuth(login: final username?, apiKey: final apiKey?) =>
      username.isNotEmpty && apiKey.isNotEmpty,

    // No auth details
    _ => false,
  };
}
