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
          if (token != null)
            'Authorization': '${token.tokenType} ${token.accessToken}',
        },
      ),
    );

    final data = response.data;

    return (data as List).map((e) => PostDto.fromJson(e)).toList();
  }

  Future<List<TagDto>> getAutocomplete({
    required String query,
  }) async {
    final response = await _dio.get(
      '/tags',
      queryParameters: {
        'name': query,
      },
    );

    return (response.data as List).map((e) => TagDto.fromJson(e)).toList();
  }
}
