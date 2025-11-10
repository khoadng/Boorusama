// Package imports:
import 'package:booru_clients/shimmie2.dart';
import 'package:coreutils/coreutils.dart';

// Project imports:
import '../../../core/configs/config/types.dart';

class Shimmie2LoginDetails
    with UnrestrictedBooruLoginDetails
    implements BooruLoginDetails {
  Shimmie2LoginDetails({
    required this.config,
    required this.delegate,
  });

  final BooruLoginDetails delegate;
  final BooruConfigAuth config;

  @override
  bool hasLogin() => delegate.hasLogin();

  String? get username => switch (config) {
    BooruConfigAuth(login: final login?) => login,
    BooruConfigAuth(passHash: final cookie?) when cookie.isNotEmpty =>
      switch (CookieUtils.parseCookieHeader(cookie)[Shimmie2Cookies.username]) {
        final username? => username,
        _ => null,
      },
    _ => null,
  };
}
