// Dart imports:
import 'dart:async';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'graphql/field_discovery.dart';
import 'graphql/graphql_client.dart';
import 'types/types.dart';

class Shimmie2GraphQLClient {
  Shimmie2GraphQLClient({
    required Dio dio,
    required Map<String, String> authParams,
  }) : _base = GraphQLClient(dio: dio, authParams: authParams);

  final GraphQLClient _base;
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
    final fieldsList = fields.join('\n          ');
    return '''
      query SearchPosts(\$tags: [String!], \$offset: Int!, \$limit: Int) {
        posts(tags: \$tags, offset: \$offset, limit: \$limit) {
          $fieldsList
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
    final fields = await _postFieldDiscovery.ensureDiscovered();

    return _base.executeQuery(
      query: _buildPostsDiscoveryQuery(fields),
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

  String _buildPostByIdQuery(Iterable<String> fields) {
    final fieldsList = fields.join('\n          ');
    return '''
      query GetPost(\$id: Int!) {
        post(post_id: \$id) {
          $fieldsList
          owner {
            name
            join_date
          }
        }
      }
    ''';
  }

  Future<PostDto?> getPostById(int id) async {
    final fields = await _postFieldDiscovery.ensureDiscovered();

    return _base.executeQuery(
      query: _buildPostByIdQuery(fields),
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
}
