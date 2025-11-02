// Dart imports:

import 'dart:async';
import 'package:dio/dio.dart';

final class AuthTokenManager {
  AuthTokenManager._({
    required Dio dio,
    required String username,
    required Map<String, String> authParams,
  }) : _dio = dio,
       _username = username,
       _authParams = authParams;

  factory AuthTokenManager.create({
    required Dio dio,
    required String username,
    required Map<String, String> authParams,
  }) => AuthTokenManager._(
    dio: dio,
    username: username,
    authParams: authParams,
  );

  final Dio _dio;
  final String _username;
  final Map<String, String> _authParams;
  String? _cachedToken;

  Future<String?> getToken({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      if (_cachedToken case final token?) return token;
    }

    try {
      final response = await _dio.get(
        '/user/$_username',
        queryParameters: _authParams,
      );

      final regex = RegExp(r"name='auth_token'\s+value='([^']+)'");
      _cachedToken = regex.firstMatch(response.data)?.group(1);
      return _cachedToken;
    } catch (_) {
      return null;
    }
  }

  void invalidate() => _cachedToken = null;
}
