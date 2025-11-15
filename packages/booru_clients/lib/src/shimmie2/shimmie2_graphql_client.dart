// Dart imports:
import 'dart:async';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'graphql/field_discovery.dart';
import 'graphql/graphql_cache.dart';
import 'graphql/graphql_client.dart';
import 'types/types.dart';

class Shimmie2GraphQLClient {
  Shimmie2GraphQLClient({
    required GraphQLClient client,
    GraphQLCache? cache,
  }) : _base = client,
       _cache = cache;

  factory Shimmie2GraphQLClient.fromDio({
    required Dio dio,
    required AuthParamsBuilder authParams,
    GraphQLCache? cache,
  }) {
    return Shimmie2GraphQLClient(
      client: GraphQLClient(dio: dio, authParams: authParams),
      cache: cache,
    );
  }

  final GraphQLClient _base;
  final GraphQLCache? _cache;

  late final FieldDiscovery _postFieldDiscovery = FieldDiscovery(
    client: _base,
    allFields: [..._coreFields, ..._extendedFields],
    coreFields: _coreFields.toSet(),
    buildDiscoveryQuery: _buildPostsDiscoveryQuery,
    discoveryVariables: {
      'tags': null,
      'offset': 0,
      'limit': 1,
    },
    cache: _cache,
  );

  static const _coreFields = [
    'post_id',
    'hash',
    'filename',
    'width',
    'height',
    'filesize',
    'posted',
    'source',
    'locked',
    'ext',
    'mime',
    'image_link',
    'thumb_link',
    'nice_name',
    'tooltip',
    'tags',
  ];

  static const _extendedFields = [
    'score',
    'votes',
    'my_vote',
    'comments',
    'favorites',
    'numeric_score',
    'rating',
    'notes',
    'parent_id',
    'has_children',
    'author',
    'title',
    'approved',
    'approved_by_id',
    'private',
    'trash',
  ];

  static String _buildPostsDiscoveryQuery(Iterable<String> fields) {
    final fieldsList = fields
        .where((f) => f != 'comments' && f != 'votes')
        .join('\n          ');
    final commentsField = fields.contains('comments')
        ? '''
          comments {
            comment_id
            comment
            posted
            owner {
              name
              id
            }
          }'''
        : '';
    final votesField = fields.contains('votes')
        ? '''
          votes {
            score
            user {
              name
              id
            }
          }'''
        : '';
    return '''
      query SearchPosts(\$tags: [String!], \$offset: Int!, \$limit: Int) {
        posts(tags: \$tags, offset: \$offset, limit: \$limit) {
          $fieldsList$commentsField$votesField
          owner {
            name
            join_date
          }
        }
      }
    ''';
  }

  Future<List<PostDto>> getPosts({
    List<String>? tags,
    int? offset,
    int? limit,
  }) async {
    return _executeWithFieldErrorRecovery(
      fetchFields: () => _postFieldDiscovery.ensureDiscovered(),
      buildQuery: _buildPostsDiscoveryQuery,
      variables: {
        if (tags != null) 'tags': tags,
        'offset': offset ?? 0,
        if (limit != null) 'limit': limit,
      },
      parseData: (data) => switch (data) {
        {'posts': final List posts} =>
          posts
              .map(
                (json) => PostDto.fromGraphQL(
                  json,
                  baseUrl: _base.baseUrl,
                ),
              )
              .toList(),
        _ => <PostDto>[],
      },
    );
  }

  Future<T> _executeWithFieldErrorRecovery<T>({
    required Future<Set<String>> Function() fetchFields,
    required String Function(Iterable<String>) buildQuery,
    required Map<String, dynamic> variables,
    required T Function(dynamic) parseData,
  }) async {
    try {
      final fields = await fetchFields();
      return await _base.executeQuery(
        query: buildQuery(fields),
        variables: variables,
        parseData: parseData,
      );
    } catch (e) {
      if (_isFieldError(e)) {
        await _postFieldDiscovery.rediscover();
        final fields = await fetchFields();
        return await _base.executeQuery(
          query: buildQuery(fields),
          variables: variables,
          parseData: parseData,
        );
      }
      rethrow;
    }
  }

  bool _isFieldError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('cannot query field') ||
        message.contains('field') && message.contains('not exist');
  }

  String _buildPostByIdQuery(Iterable<String> fields) {
    final fieldsList = fields
        .where((f) => f != 'comments' && f != 'votes')
        .join('\n          ');
    final commentsField = fields.contains('comments')
        ? '''
          comments {
            comment_id
            comment
            posted
            owner {
              name
              id
            }
          }'''
        : '';
    final votesField = fields.contains('votes')
        ? '''
          votes {
            score
            user {
              name
              id
            }
          }'''
        : '';
    return '''
      query GetPost(\$id: Int!) {
        post(post_id: \$id) {
          $fieldsList$commentsField$votesField
          owner {
            name
            join_date
          }
        }
      }
    ''';
  }

  Future<PostDto?> getPostById(int id) async {
    return _executeWithFieldErrorRecovery(
      fetchFields: () => _postFieldDiscovery.ensureDiscovered(),
      buildQuery: _buildPostByIdQuery,
      variables: {'id': id},
      parseData: (data) => switch (data) {
        {'post': final Map<String, dynamic> post} => PostDto.fromGraphQL(
          post,
          baseUrl: _base.baseUrl,
        ),
        _ => null,
      },
    );
  }

  Future<void> invalidateFieldDiscoveryCache() async {
    await _postFieldDiscovery.invalidateCache();
  }

  Future<void> rediscoverFields() async {
    await _postFieldDiscovery.rediscover();
  }
}
