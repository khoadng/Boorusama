// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../sankaku_idol/sankaku_idol_client.dart';
import 'types/types.dart';

const _kFakeBrowserHeader =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/111.0';

const _kFallbackSankakuHeader = {
  'User-Agent': _kFakeBrowserHeader,
  'Content-Type': 'application/json',
  'Accept': 'application/json',
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

    _dio.options = BaseOptions(
      baseUrl: _convertBaseUrlToApiUrl(baseUrl),
      headers: headers ?? _kFallbackSankakuHeader,
    );

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
    final isIdol = baseUrl.contains('idol.');

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

    final token = Token.fromJson(data);

    await _authStore.saveToken(token);

    return token;
  }

  Future<List<PostDto>> getPosts({
    List<String>? tags,
    int? page = 1,
    int? limit = 60,
  }) async {
    var token = await _authStore.getToken();

    if (token == null && username != null && password != null) {
      token = await login(
        username: username!,
        password: password!,
      );
    }

    final response = await _dio.get(
      '/posts',
      queryParameters: {
        'lang': 'english',
        'page': page,
        'limit': limit,
        if (tags != null && tags.isNotEmpty) 'tags': tags.join(' '),
      },
      options: Options(
        headers: {
          if (token != null &&
              token.accessToken != null &&
              token.tokenType != null)
            'Authorization': '${token.tokenType} ${token.accessToken}',
        },
      ),
    );

    final data = response.data;

    return (data as List).map((e) => PostDto.fromJson(e)).toList();
  }

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
}
