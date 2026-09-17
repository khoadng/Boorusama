// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../sankaku_idol/sankaku_idol_client.dart';
import 'types/types.dart';

const _kFakeBrowserHeader =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/111.0';

const _kSankakuApiHeaders = {
  'Content-Type': 'application/json',
  'Accept': 'application/vnd.sankaku.api+json;v=2',
  'Origin': 'https://sankaku.app',
};

const _kSankakuApiUrl = 'https://sankakuapi.com';

const _kSankakuKnownUrls = [
  'chan.sankakucomplex.com',
  'beta.sankakucomplex.com',
  'sankaku.app',
  'sankakucomplex.com',
];

String _convertBaseUrlToApiUrl(String url) {
  for (final knownUrl in _kSankakuKnownUrls) {
    if (url.contains(knownUrl)) {
      return _kSankakuApiUrl;
    }
  }

  return url;
}

class SankakuClient {
  SankakuClient({
    required String baseUrl,
    Map<String, dynamic>? headers,
    Dio? dio,
    AuthStore? authStore,
    this.username,
    this.password,
  }) {
    _dio = dio ?? Dio();
    _baseUrl = baseUrl;

    final mergedHeaders = <String, dynamic>{
      ..._kSankakuApiHeaders,
      ..._dio.options.headers,
      ...?headers,
    };
    if (!mergedHeaders.keys.any((key) => key.toLowerCase() == 'user-agent')) {
      mergedHeaders['User-Agent'] = _kFakeBrowserHeader;
    }

    _dio.options
      ..baseUrl = _convertBaseUrlToApiUrl(baseUrl)
      ..headers = mergedHeaders;

    _authStore = authStore ?? InMemoryAuthStore();
  }

  factory SankakuClient.extended({
    required String baseUrl,
    Map<String, dynamic>? headers,
    Dio? dio,
    AuthStore? authStore,
    String? username,
    String? password,
  }) {
    final isIdol = baseUrl.contains('idol.') || baseUrl.contains('idolcomplex');

    return isIdol
        ? SankakuIdolClient(
            baseUrl: baseUrl,
            headers: headers,
            dio: dio,
            username: username,
            password: password,
          )
        : SankakuClient(
            baseUrl: baseUrl,
            headers: headers,
            dio: dio,
            authStore: authStore,
            username: username,
            password: password,
          );
  }

  late Dio _dio;
  late AuthStore _authStore;
  Future<Token>? _authenticationInFlight;
  var _authenticationGeneration = 0;
  final String? username;
  final String? password;

  late String _baseUrl;
  String get originalUrl => _baseUrl;

  Future<Token> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/token',
      data: {
        'login': username,
        'password': password,
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const SankakuAuthenticationException(
        'Invalid authentication response',
      );
    }

    final token = Token.fromJson(data);
    if (token.success != true ||
        token.tokenType == null ||
        token.tokenType!.isEmpty ||
        token.accessToken == null ||
        token.accessToken!.isEmpty) {
      final message = switch (data) {
        {'error': final String error} when error.isNotEmpty => error,
        {'code': final String code} when code.isNotEmpty => code,
        _ => 'Authentication failed',
      };
      throw SankakuAuthenticationException(message);
    }

    await _authStore.saveToken(token);
    _authenticationGeneration++;

    return token;
  }

  Future<List<PostDto>> getPosts({
    List<String>? tags,
    int? page = 1,
    int? limit = 60,
  }) async {
    final response = await _getWithAuthenticationRecovery(
      (token) => _dio.get(
        '/posts',
        queryParameters: {
          'lang': 'english',
          'page': page,
          'limit': limit,
          if (tags != null && tags.isNotEmpty) 'tags': tags.join(' '),
        },
        options: _authOptions(token),
      ),
    );

    final data = response.data;

    return (data as List).map((e) => PostDto.fromJson(e)).toList();
  }

  Future<PostDto?> getPost({
    required String id,
  }) async {
    final response = await _getWithAuthenticationRecovery(
      (token) => _dio.get(
        '/posts/$id',
        options: _authOptions(token),
      ),
    );

    final data = response.data;

    return PostDto.fromJson(data);
  }

  Future<bool> addToFavorites({
    required SankakuId postId,
  }) => _runAuthenticatedMutation(
    (token) => _dio.post(
      '/posts/${Uri.encodeComponent(postId.valueString)}/favorite',
      options: _authOptions(token),
    ),
  );

  Future<bool> removeFromFavorites({
    required SankakuId postId,
  }) => _runAuthenticatedMutation(
    (token) => _dio.delete(
      '/posts/${Uri.encodeComponent(postId.valueString)}/favorite',
      options: _authOptions(token),
    ),
  );

  // Only a single global autocomplete request per client is allowed for now
  CancelToken? _autocompleteCancelToken;

  Future<List<TagDto>> getAutocomplete({
    required String query,
  }) async {
    _autocompleteCancelToken?.cancel('Cancelled due to new request being made');
    _autocompleteCancelToken = CancelToken();

    try {
      final response = await _dio.get(
        '/tags/autosuggestCreating',
        queryParameters: {
          'lang': 'english',
          'tag': query,
          'show_meta': 1,
        },
        options: Options(
          receiveTimeout: Duration(seconds: 15),
        ),
        cancelToken: _autocompleteCancelToken,
      );

      return (response.data as List).map((e) => TagDto.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return [];
      } else if (e.type == DioExceptionType.receiveTimeout) {
        // Too slow, return empty list, don't throw
        return [];
      }
      rethrow;
    }
  }

  Future<List<TagDto>> getTags({
    required String query,
  }) async {
    try {
      final response = await _dio.get(
        '/tags',
        queryParameters: {
          'name': query,
        },
        options: Options(
          receiveTimeout: Duration(seconds: 15),
        ),
      );

      return (response.data as List).map((e) => TagDto.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout) {
        // Too slow, return empty list, don't throw
        return [];
      }
      rethrow;
    }
  }

  Future<Token?> _getToken() async {
    final token = await _authStore.getToken();

    if (token != null) return token;

    if (username == null || password == null) return null;

    return _authenticateOnce();
  }

  Future<Token> _authenticateOnce() async {
    final inFlight = _authenticationInFlight;
    if (inFlight != null) return inFlight;

    final authentication = login(
      username: username!,
      password: password!,
    );
    _authenticationInFlight = authentication;

    try {
      return await authentication;
    } finally {
      if (identical(_authenticationInFlight, authentication)) {
        _authenticationInFlight = null;
      }
    }
  }

  Future<Response<dynamic>> _getWithAuthenticationRecovery(
    Future<Response<dynamic>> Function(Token? token) request,
  ) async {
    final token = await _getToken();
    final generation = _authenticationGeneration;

    try {
      final response = await request(token);
      if (token == null || !_hasInvalidAuthenticationCode(response.data)) {
        return response;
      }
    } on DioException catch (error) {
      if (token == null || !_isInvalidAuthenticationError(error)) rethrow;
    }

    final recoveredToken = await _recoverAuthentication(token, generation);
    final response = await request(recoveredToken);
    if (_hasInvalidAuthenticationCode(response.data)) {
      throw const SankakuAuthenticationException(
        'Authentication failed after retry',
      );
    }

    return response;
  }

  Future<Token?> _recoverAuthentication(
    Token rejectedToken,
    int requestGeneration,
  ) async {
    await _invalidateAuthentication(rejectedToken, requestGeneration);
    return _getToken();
  }

  Future<void> _invalidateAuthentication(
    Token rejectedToken,
    int requestGeneration,
  ) async {
    if (_authenticationGeneration != requestGeneration) return;

    final currentToken = await _authStore.getToken();
    if (currentToken != null &&
        currentToken.accessToken != rejectedToken.accessToken) {
      return;
    }

    await _authStore.clearToken();
  }

  Future<bool> _runAuthenticatedMutation(
    Future<Response<dynamic>> Function(Token token) request,
  ) async {
    final token = await _getToken();
    if (token == null) return false;

    final generation = _authenticationGeneration;
    try {
      final response = await request(token);
      if (_hasInvalidAuthenticationCode(response.data)) {
        await _invalidateAuthentication(token, generation);
        return false;
      }

      return switch (response.data) {
        {'success': false} => false,
        _ => true,
      };
    } on DioException catch (error) {
      if (_isInvalidAuthenticationError(error)) {
        await _invalidateAuthentication(token, generation);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  bool _isInvalidAuthenticationError(DioException error) =>
      error.response?.statusCode == 401 ||
      _hasInvalidAuthenticationCode(error.response?.data);

  bool _hasInvalidAuthenticationCode(Object? data) {
    final code = switch (data) {
      {'code': final String code} => code,
      _ => null,
    };

    return code != null &&
        (code.endsWith('unauthorized') ||
            code.endsWith('invalid-token') ||
            code.endsWith('invalid_token'));
  }

  Options _authOptions(Token? token) => Options(
    headers: {
      if (token != null && token.accessToken != null && token.tokenType != null)
        'Authorization': '${token.tokenType} ${token.accessToken}',
    },
  );
}

class SankakuAuthenticationException implements Exception {
  const SankakuAuthenticationException(this.message);

  final String message;

  @override
  String toString() => 'SankakuAuthenticationException: $message';
}
