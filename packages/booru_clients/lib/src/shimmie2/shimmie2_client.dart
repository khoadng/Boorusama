// Dart imports:
import 'dart:async';

// Package imports:
import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

// Project imports:
import 'auth_token_manager.dart';
import 'graphql/graphql_cache.dart';
import 'shimmie2_graphql_client.dart';
import 'types/types.dart';

const _kApiKeyParam = 'api_key';
const _kAuthTokenParam = 'auth_token';

class Shimmie2Client {
  Shimmie2Client({
    Dio? dio,
    this.apiKey,
    this.username,
    this.cookie,
    required String baseUrl,
    GraphQLCache? graphQLCache,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl,
             ),
           ),
       _tokenManager = AuthTokenManager.create(
         dio:
             dio ??
             Dio(
               BaseOptions(
                 baseUrl: baseUrl,
               ),
             ),
         username: username ?? '',
         authParams: {
           _kApiKeyParam: ?apiKey,
         },
         cookie: cookie,
       ) {
    _graphql = Shimmie2GraphQLClient.fromDio(
      dio: _dio,
      authParams: () => _authParams,
      cache: graphQLCache,
    );
  }

  final Dio _dio;
  final String? apiKey;
  final String? username;
  final String? cookie;
  final AuthTokenManager? _tokenManager;
  late final Shimmie2GraphQLClient _graphql;

  Map<String, String> get _authParams => {
    if (apiKey case final key? when key.isNotEmpty) ...{
      _kApiKeyParam: key,
    },
  };

  Map<String, String> get _authHeaders => {
    if (cookie case final c? when c.isNotEmpty) ...{
      'cookie': c,
    },
  };

  Future<List<PostDto>> getPosts({
    List<String>? tags,
    int? page,
    int? limit,
    bool useGraphQL = false,
  }) async {
    if (useGraphQL) {
      final offset = page != null ? (page - 1) * (limit ?? 100) : null;
      return _graphql.getPosts(
        tags: tags,
        offset: offset,
        limit: limit,
      );
    }

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

  Future<bool> bulkAction({
    required BulkAction action,
    required List<int> postIds,
    String? query,
  }) async {
    if (_tokenManager case final manager?) {
      if (await manager.getToken() case final token?) {
        return _postBulkAction(
          action: action,
          postIds: postIds,
          query: query,
          token: token,
          manager: manager,
        );
      }
    }
    return false;
  }

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
          headers: _authHeaders,
        ),
      );
      return true;
    } on DioException catch (e) {
      // Success redirects (302) are treated as errors by Dio
      if (e.response?.statusCode == 302) return true;
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
              headers: _authHeaders,
            ),
          );
          return true;
        } on DioException catch (e2) {
          // Success redirects (302) are treated as errors by Dio
          if (e2.response?.statusCode == 302) return true;
          return false;
        } catch (_) {
          return false;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _postBulkAction({
    required BulkAction action,
    required List<int> postIds,
    required String? query,
    required String token,
    required AuthTokenManager manager,
  }) async {
    try {
      await _dio.post(
        '/bulk_action',
        queryParameters: _authParams,
        data: {
          _kAuthTokenParam: token,
          'bulk_action': action.value,
          'bulk_selected_ids': '[${postIds.join(',')}]',
          if (query case final q? when q.isNotEmpty) 'bulk_query': q,
          'submit_button': switch (action) {
            BulkAction.favorite => 'Favorite',
            BulkAction.unfavorite => 'Unfavorite',
          },
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: _authHeaders,
        ),
      );
      return true;
    } on DioException catch (e) {
      // Success redirects (302) are treated as errors by Dio
      if (e.response?.statusCode == 302) return true;
      if (e.response?.statusCode != 403) return false;

      manager.invalidate();
      if (await manager.getToken(forceRefresh: true) case final newToken?) {
        try {
          await _dio.post(
            '/bulk_action',
            queryParameters: _authParams,
            data: {
              _kAuthTokenParam: newToken,
              'bulk_action': action.value,
              'bulk_selected_ids': '[${postIds.join(',')}]',
              if (query case final q? when q.isNotEmpty) 'bulk_query': q,
              'submit_button': switch (action) {
                BulkAction.favorite => 'Favorite',
                BulkAction.unfavorite => 'Unfavorite',
              },
            },
            options: Options(
              contentType: Headers.formUrlEncodedContentType,
              headers: _authHeaders,
            ),
          );
          return true;
        } on DioException catch (e2) {
          // Success redirects (302) are treated as errors by Dio
          if (e2.response?.statusCode == 302) return true;
          return false;
        } catch (_) {
          return false;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<ExtensionsResult> getExtensions() async {
    try {
      final response = await _dio.get(
        '/ext_doc',
        queryParameters: _authParams,
      );

      return ExtensionDto.parseFromHtml(
        response.data,
        baseUrl: _dio.options.baseUrl,
      );
    } on DioException catch (e) {
      // If the endpoint doesn't exist (404) or access is denied (403),
      // the instance doesn't support extension listing
      if (e.response?.statusCode == 404 || e.response?.statusCode == 403) {
        return ExtensionsNotSupported();
      }
      rethrow;
    } catch (_) {
      return ExtensionsNotSupported();
    }
  }
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
