// Dart imports:
import 'dart:async';

// Package imports:
import 'package:booru_clients/src/shimmie2/auth_token_manager.dart';
import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

// Project imports:
import 'types/types.dart';

const _kApiKeyParam = 'api_key';
const _kAuthTokenParam = 'auth_token';

class Shimmie2Client {
  Shimmie2Client({
    Dio? dio,
    this.apiKey,
    this.username,
    required String baseUrl,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl,
             ),
           ),
       _tokenManager = switch ((apiKey, username)) {
         (final key?, final name?) when key.isNotEmpty && name.isNotEmpty =>
           AuthTokenManager.create(
             dio:
                 dio ??
                 Dio(
                   BaseOptions(
                     baseUrl: baseUrl,
                   ),
                 ),
             username: name,
             authParams: {
               _kApiKeyParam: key,
             },
           ),
         _ => null,
       };

  final Dio _dio;
  final String? apiKey;
  final String? username;
  final AuthTokenManager? _tokenManager;

  Map<String, String> get _authParams => {
    if (apiKey case final key? when key.isNotEmpty) ...{
      _kApiKeyParam: key,
    },
  };

  Future<List<PostDto>> getPosts({
    List<String>? tags,
    int? page,
    int? limit,
  }) async {
    final isEmpty = tags?.join(' ').isEmpty ?? true;

    final response = await _dio.get(
      '/api/danbooru/find_posts',
      queryParameters: {
        if (!isEmpty) 'tags': tags?.join(' '),
        'page': ?page,
        'limit': ?limit,
        ..._authParams,
      },
    );

    return _parsePosts(
      response,
      baseUrl: _dio.options.baseUrl,
    );
  }

  Future<List<AutocompleteDto>> getAutocomplete({
    required String query,
  }) async {
    if (query.isEmpty) return [];

    final response = await _dio.get(
      '/api/internal/autocomplete',
      queryParameters: {
        's': query,
        ..._authParams,
      },
    );

    try {
      return switch (response.data) {
        final Map m =>
          m.entries
              .map(
                (e) => AutocompleteDto(
                  value: e.key,
                  count: switch (e.value) {
                    final int n => n,
                    final Map m => _parseCount(m['count']),
                    _ => throw Exception(
                      'Failed to parse autocomplete count, unknown type >> ${e.value}',
                    ),
                  },
                ),
              )
              .toList(),
        _ => const [],
      };
    } catch (e) {
      throw Exception('Failed to parse autocomplete >> $e >> ${response.data}');
    }
  }

  Future<bool> addFavorite({
    required int postId,
  }) => _performFavoriteAction(
    postId: postId,
    endpoint: '/favourite/add/$postId',
  );

  Future<bool> removeFavorite({
    required int postId,
  }) => _performFavoriteAction(
    postId: postId,
    endpoint: '/favourite/remove/$postId',
  );

  Future<bool> _performFavoriteAction({
    required int postId,
    required String endpoint,
  }) async {
    if (_tokenManager case final manager?) {
      if (await manager.getToken() case final token?) {
        return _postFavorite(
          endpoint: endpoint,
          token: token,
          manager: manager,
        );
      }
    }
    return false;
  }

  Future<bool> _postFavorite({
    required String endpoint,
    required String token,
    required AuthTokenManager manager,
  }) async {
    try {
      await _dio.post(
        endpoint,
        queryParameters: _authParams,
        data: {
          _kAuthTokenParam: token,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode != 403) return false;

      manager.invalidate();
      if (await manager.getToken(forceRefresh: true) case final newToken?) {
        try {
          await _dio.post(
            endpoint,
            queryParameters: _authParams,
            data: {
              _kAuthTokenParam: newToken,
            },
            options: Options(
              contentType: Headers.formUrlEncodedContentType,
            ),
          );
          return true;
        } catch (_) {
          return false;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  bool get canFavorite =>
      apiKey != null &&
      apiKey!.isNotEmpty &&
      username != null &&
      username!.isNotEmpty;
}

FutureOr<List<PostDto>> _parsePosts(
  Response value, {
  String? baseUrl,
}) {
  final dtos = <PostDto>[];
  final xmlDocument = XmlDocument.parse(value.data);
  final posts = xmlDocument.findAllElements('tag');
  for (final item in posts) {
    dtos.add(
      PostDto.fromXml(
        item,
        baseUrl: baseUrl,
      ),
    );
  }
  return dtos;
}

int? _parseCount(dynamic value) => switch (value) {
  null => null,
  final String s => int.tryParse(s),
  final int n => n,
  _ => null,
};
