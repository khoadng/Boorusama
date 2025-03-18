import 'package:dio/dio.dart';
import 'dart:convert';
import '../sankaku/sankaku_client.dart';
import 'types/post_dto.dart';
import '../sankaku/types/types.dart';
import 'types/type_converters.dart';

const _kFallbackSankakuIdolHeader = {
  'User-Agent': 'SCChannelApp/4.2 (Android; idol)',
  'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
  'Accept': 'application/json',
  'Accept-Encoding': 'gzip',
};

const _kSankakuIdolApiUrl = 'https://iapi.sankakucomplex.com';

const _kSankakuIdolKnownUrls = [
  'idol.sankakucomplex.com',
];

String _convertBaseUrlToApiUrl(String url) {
  for (final knownUrl in _kSankakuIdolKnownUrls) {
    if (url.contains(knownUrl)) {
      return _kSankakuIdolApiUrl;
    }
  }

  return url;
}

class SankakuIdolClient implements SankakuClient {
  SankakuIdolClient({
    required String baseUrl,
    Map<String, dynamic>? headers,
    Dio? dio,
    this.username,
    this.password,
  }) {
    _dio = dio ?? Dio();
    _baseUrl = baseUrl;
    _token = '';

    final effectiveHeaders = {...headers ?? _kFallbackSankakuIdolHeader};

    effectiveHeaders['User-Agent'] = 'SCChannelApp/4.2 (Android; idol)';
    effectiveHeaders['Content-Type'] =
        'application/x-www-form-urlencoded; charset=UTF-8';
    effectiveHeaders['Accept'] = 'application/json';
    effectiveHeaders['Accept-Encoding'] = 'gzip';

    _dio.options = BaseOptions(
      baseUrl: _convertBaseUrlToApiUrl(baseUrl),
      headers: effectiveHeaders,
    );
  }

  late final Dio _dio;
  late final String _baseUrl;
  late String _token;
  @override
  final String? username;
  @override
  final String? password;

  @override
  String get originalUrl => _baseUrl;
  bool get isAuthenticated => _token.isNotEmpty;

  @override
  Future<List<PostDto>> getPosts({
    List<String>? tags,
    int? page = 1,
    int? limit,
  }) async {
    final idolPosts = await getIdolPosts(tags: tags, page: page, limit: limit);
    return idolPosts.map((e) => e.toSankakuPost()).toList();
  }

  Future<List<PostIdolDto>> getIdolPosts({
    List<String>? tags,
    int? page = 1,
    int? limit,
  }) async {
    if (!isAuthenticated && username != null && password != null) {
      await login(username: username!, password: password!);
    }

    final response = await _dio.get(
      '/posts.json',
      queryParameters: {
        'page': page,
        if (limit != null) 'limit': limit,
        if (tags != null && tags.isNotEmpty) 'tags': tags.join(' '),
      },
      options: Options(
        responseType: ResponseType.plain,
        headers: {
          if (_token.isNotEmpty) 'x-rails-token': _token,
        },
      ),
    );

    // Parse the response text as JSON
    final data = switch (response.data) {
      String str => json.decode(str),
      _ => response.data,
    };

    return (data as List).map((e) => PostIdolDto.fromJson(e)).toList();
  }

  CancelToken? _autocompleteCancelToken;

  @override
  Future<List<TagDto>> getAutocomplete({
    required String query,
  }) async {
    final idolTags = await getIdolAutocomplete(query: query);
    return idolTags.map((e) => e.toSankakuTag()).toList();
  }

  Future<List<TagIdolDto>> getIdolAutocomplete({
    required String query,
  }) async {
    _autocompleteCancelToken?.cancel('Cancelled due to new request being made');
    _autocompleteCancelToken = CancelToken();

    try {
      final response = await _dio.get(
        '/tags.json',
        queryParameters: {
          'name': query,
        },
        options: Options(
          responseType: ResponseType.plain,
          receiveTimeout: Duration(seconds: 15),
        ),
        cancelToken: _autocompleteCancelToken,
      );

      final data = switch (response.data) {
        String str => json.decode(str),
        _ => response.data,
      };

      return (data as List).map((e) => TagIdolDto.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return [];
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return [];
      }
      rethrow;
    }
  }

  @override
  Future<Token> login({
    required String username,
    required String password,
  }) async {
    final user = username;
    final pass = password;

    try {
      final response = await _dio.post(
        '/user/authenticate.json',
        data: {
          'login': user.toLowerCase(),
          'password': pass,
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        ),
      );

      if (response.statusCode == 200) {
        _token = response.data['access_token'] ?? '';
        return Token(
          accessToken: _token,
          tokenType: 'rails',
          success: true,
          refreshToken: null,
          currentUser: null,
        );
      }
      return const Token.empty();
    } catch (e) {
      return const Token.empty();
    }
  }
}
