import 'dart:async';
import 'package:coreutils/coreutils.dart';
import 'package:dio/dio.dart';

import 'types/types.dart';

final class AuthTokenManager {
  AuthTokenManager._({
    required Dio dio,
    required String username,
    required this.cookie,
    required Map<String, String> authParams,
  }) : _dio = dio,
       _username = username,
       _authParams = authParams;

  factory AuthTokenManager.create({
    required Dio dio,
    required String username,
    required String? cookie,
    required Map<String, String> authParams,
  }) => AuthTokenManager._(
    dio: dio,
    username: username,
    authParams: authParams,
    cookie: cookie,
  );

  final Dio _dio;
  final String _username;
  final Map<String, String> _authParams;
  final String? cookie;
  String? _cachedToken;

  Future<String?> getToken({bool forceRefresh = false}) async {
    final usernameToUse = _getUsernameFromCookieOrParam();
    if (usernameToUse.isEmpty) return null;

    if (!forceRefresh) {
      if (_cachedToken case final token?) return token;
    }

    try {
      final response = await _dio.get(
        '/user/$usernameToUse',
        queryParameters: _authParams,
        options: switch (cookie) {
          final c? => Options(
            headers: {
              'cookie': c,
            },
          ),
          _ => null,
        },
      );

      final regex = RegExp(r"name='auth_token'\s+value='([^']+)'");
      _cachedToken = regex.firstMatch(response.data)?.group(1);
      return _cachedToken;
    } catch (_) {
      return null;
    }
  }

  String _getUsernameFromCookieOrParam() {
    if (cookie case final c?) {
      final cookieMap = CookieUtils.parseCookieHeader(c);
      if (cookieMap[Shimmie2Cookies.username] case final cookieUsername?) {
        return cookieUsername;
      }
    }
    return _username;
  }

  void invalidate() => _cachedToken = null;
}
