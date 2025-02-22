// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

const _kFakeBrowserHeader =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/111.0';

const _kSankakuHeader = {
  'User-Agent': _kFakeBrowserHeader,
  'Content-Type': 'application/json',
  'Accept': 'application/json',
};

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

    var url = baseUrl;

    if (url.startsWith('https://chan.')) {
      url = url.replaceFirst('https://chan.', 'https://capi-v2.');
    } else if (url.startsWith('https://beta.')) {
      url = url.replaceFirst('https://beta.', 'https://capi-v2.');
    } else if (url == 'https://sankaku.app/') {
      url = 'https://capi-v2.sankakucomplex.com';
    } else if (url == 'https://sankakucomplex.com/') {
      url = 'https://capi-v2.sankakucomplex.com';
    }

    _dio.options = BaseOptions(
      baseUrl: url,
      headers: headers ?? _kSankakuHeader,
    );

    _authStore = authStore ?? InMemoryAuthStore();
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
        '/tags',
        queryParameters: {
          'name': query,
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
}
