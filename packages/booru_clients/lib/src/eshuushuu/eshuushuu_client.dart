import 'dart:convert';

import 'package:coreutils/coreutils.dart';
import 'package:dio/dio.dart';
import 'types/auth_dto.dart';
import 'types/autocomplete_dto.dart';
import 'types/comment_dto.dart';
import 'types/favorite_dto.dart';
import 'types/post_dto.dart';
import 'types/user_dto.dart';

const _apiBase = '/api/v1';

class EShuushuuClient {
  EShuushuuClient({
    Dio? dio,
  }) : _dio = dio ?? Dio(BaseOptions(baseUrl: 'https://e-shuushuu.net'));

  EShuushuuClient.withBaseUrl(String baseUrl)
    : _dio = Dio(BaseOptions(baseUrl: baseUrl));

  final Dio _dio;

  String get baseUrl => _dio.options.baseUrl;

  Future<UserDto?> getUser(int id) async {
    final response = await _dio.get('$_apiBase/users/$id');

    return switch (response.data) {
      final Map<String, dynamic> json => UserDto.fromJson(json),
      _ => null,
    };
  }

  Future<List<PostDto>> getPosts({
    List<int>? tagIds,
    int? favoritedByUserId,
    int? userId,
    int? page,
    int? perPage,
  }) async {
    final response = await _dio.get(
      '$_apiBase/images',
      queryParameters: {
        if (tagIds != null && tagIds.isNotEmpty) 'tags': tagIds.join('+'),
        'favorited_by_user_id': ?favoritedByUserId,
        'user_id': ?userId,
        if (page != null && page > 1) 'page': page,
        'per_page': ?perPage,
      },
    );

    return switch (response.data) {
      {'images': final List images} =>
        images.whereType<Map<String, dynamic>>().map(PostDto.fromJson).toList(),
      _ => [],
    };
  }

  Future<List<CommentDto>> getComments({
    required int imageId,
    int? page,
    int? perPage,
  }) async {
    final response = await _dio.get(
      '$_apiBase/comments',
      queryParameters: {
        'image_id': imageId,
        if (page != null && page > 1) 'page': page,
        'per_page': ?perPage,
      },
    );

    return switch (response.data) {
      {'comments': final List comments} =>
        comments
            .whereType<Map<String, dynamic>>()
            .map(CommentDto.fromJson)
            .toList(),
      _ => [],
    };
  }

  Future<List<AutocompleteDto>> getAutocomplete({
    required String query,
    int limit = 10,
  }) async {
    final response = await _dio.get(
      '$_apiBase/tags/',
      queryParameters: {
        'search': query,
        'limit': limit,
      },
    );

    return parseAutocompleteFromApi(response.data);
  }

  Future<List<int>> resolveTagIds(List<String> tagNames) async {
    final ids = <int>[];
    for (final name in tagNames) {
      final results = await getAutocomplete(query: name, limit: 1);
      if (results.firstOrNull case AutocompleteDto(:final tagId?)) {
        ids.add(tagId);
      }
    }
    return ids;
  }

  Future<AuthTokens?> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post(
      '$_apiBase/auth/login',
      data: {
        'username': username,
        'password': password,
      },
      options: Options(contentType: Headers.jsonContentType),
    );

    return extractTokensFromResponse(response);
  }

  Future<AuthTokens?> refresh({
    required String refreshToken,
  }) async {
    final response = await _dio.post(
      '$_apiBase/auth/refresh',
      options: Options(
        headers: {
          'cookie': 'refresh_token=$refreshToken',
        },
      ),
    );

    return extractTokensFromResponse(response);
  }

  Future<FavoriteResponseDto?> addFavorite(int imageId) async {
    final response = await _dio.post('$_apiBase/images/$imageId/favorite');

    return switch (response.data) {
      final Map<String, dynamic> json => FavoriteResponseDto.fromJson(json),
      _ => null,
    };
  }

  Future<FavoriteResponseDto?> removeFavorite(int imageId) async {
    final response = await _dio.delete('$_apiBase/images/$imageId/favorite');

    return switch (response.data) {
      final Map<String, dynamic> json => FavoriteResponseDto.fromJson(json),
      _ => null,
    };
  }

  static AuthTokens? extractTokensFromResponse(Response response) {
    final setCookies = response.headers.map['set-cookie'];
    if (setCookies == null) return null;

    final cookies = CookieUtils.extractValuesFromSetCookieHeaders(setCookies);
    var accessToken = cookies['access_token'];
    final refreshToken = cookies['refresh_token'];
    if (refreshToken == null) return null;

    final body = response.data;
    final expiresIn = switch (body) {
      {'expires_in': final int v} => v,
      _ => null,
    };

    accessToken ??= switch (body) {
      {'access_token': final String v} => v,
      _ => null,
    };

    if (accessToken == null) return null;

    final refreshTokenExpiry = CookieUtils.extractExpiryFromSetCookieHeaders(
      setCookies,
      'refresh_token',
    );

    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
      userId: extractUserIdFromJwt(accessToken),
      refreshTokenExpiry: refreshTokenExpiry,
    );
  }

  static int? extractUserIdFromJwt(String token) => _decodeJwtPayload(
    token,
    (payload) => switch (payload) {
      {'user_id': final int id} => id,
      {'uid': final int id} => id,
      {'sub': final int id} => id,
      {'sub': final String id} => int.tryParse(id),
      _ => null,
    },
  );

  static DateTime? extractExpiryFromJwt(String token) => _decodeJwtPayload(
    token,
    (payload) => switch (payload) {
      {'exp': final int exp} => DateTime.fromMillisecondsSinceEpoch(exp * 1000),
      _ => null,
    },
  );

  static T? _decodeJwtPayload<T>(
    String token,
    T? Function(Map<String, dynamic> payload) extract,
  ) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(decoded);

      return payload is Map<String, dynamic> ? extract(payload) : null;
    } catch (_) {
      return null;
    }
  }
}
