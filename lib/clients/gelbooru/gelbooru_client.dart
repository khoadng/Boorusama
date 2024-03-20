// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

// Project imports:
import 'types/autocomplete_dto.dart';
import 'types/comment_dto.dart';
import 'types/post_dto.dart';
import 'types/tag_dto.dart';

const _kGelbooruUrl = 'https://gelbooru.com/';

typedef GelbooruPosts = ({
  List<PostDto> posts,
  int? count,
});

class GelbooruClient with RequestDeduplicator<GelbooruPosts> {
  GelbooruClient({
    String? baseUrl,
    Map<String, String>? headers,
    this.userId,
    this.apiKey,
    Dio? dio,
  }) : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl ?? '',
              headers: headers ?? {},
            ));

  final Dio _dio;
  final String? userId;
  final String? apiKey;

  factory GelbooruClient.gelbooru({
    Dio? dio,
    String? login,
    String? apiKey,
  }) =>
      GelbooruClient(
        baseUrl: _kGelbooruUrl,
        dio: dio,
        userId: login,
        apiKey: apiKey,
      );

  factory GelbooruClient.custom({
    Dio? dio,
    String? login,
    String? apiKey,
    required String baseUrl,
  }) =>
      GelbooruClient(
        baseUrl: baseUrl,
        dio: dio,
        userId: login,
        apiKey: apiKey,
      );

  Future<GelbooruPosts> getPosts({
    int? page,
    int? limit,
    List<String>? tags,
  }) async {
    final baseUrl = _dio.options.baseUrl;
    final key = '${baseUrl}_getPosts_${tags?.join(' ')}_${page ?? 1}';

    return deduplicate(
      key,
      () async {
        final response = await _dio.get(
          '/index.php',
          queryParameters: {
            'page': 'dapi',
            's': 'post',
            'q': 'index',
            'json': '1',
            if (tags != null && tags.isNotEmpty) 'tags': tags.join(' '),
            if (page != null) 'pid': page - 1,
            if (limit != null) 'limit': limit,
            if (userId != null) 'user_id': userId,
            if (apiKey != null) 'api_key': apiKey,
          },
        );

        final data = response.data;

        final result = switch (data) {
          Map m => () {
              final count = m['@attributes']['count'] as int?;

              return (
                posts: m.containsKey('post')
                    ? (m['post'] as List)
                        .map((item) => PostDto.fromJson(item, baseUrl))
                        .toList()
                    : <PostDto>[],
                count: count,
              );
            }(),
          _ => (posts: <PostDto>[], count: null),
        };

        final filterNulls = result.posts.where((e) => e.md5 != null).toList();

        return (
          posts: filterNulls,
          count: result.count,
        );
      },
    );
  }

  Future<List<AutocompleteDto>> autocomplete({
    required String term,
    int? limit,
  }) async {
    final response = await _dio.get(
      '/index.php',
      queryParameters: {
        'page': 'autocomplete2',
        'type': 'tag_query',
        'term': term,
        if (limit != null) 'limit': limit,
        if (userId != null) 'user_id': userId,
        if (apiKey != null) 'api_key': apiKey,
      },
    );

    return switch (response.data) {
      List l => l.map((item) => AutocompleteDto.fromJson(item)).toList(),
      String s => (jsonDecode(s) as List<dynamic>)
          .map((item) => AutocompleteDto.fromJson(item))
          .toList(),
      _ => <AutocompleteDto>[],
    };
  }

  Future<List<CommentDto>> getComments({
    required int postId,
  }) async {
    final response = await _dio.get(
      '/index.php',
      queryParameters: {
        'page': 'dapi',
        's': 'comment',
        'q': 'index',
        'post_id': postId,
        if (userId != null) 'user_id': userId,
        if (apiKey != null) 'api_key': apiKey,
      },
    );

    return _parseCommentDtos(response);
  }

  Future<List<TagDto>> getTags({
    required Set<String> tags,
    int? page,
  }) async {
    if (tags.isEmpty) {
      throw ArgumentError.value(tags, 'tags', 'Must not be empty');
    }

    final response = await _dio.get(
      '/index.php',
      queryParameters: {
        'page': 'dapi',
        's': 'tag',
        'q': 'index',
        'json': '1',
        'names': tags.join(' '),
        if (page != null) 'pid': page - 1,
        if (userId != null) 'user_id': userId,
        if (apiKey != null) 'api_key': apiKey,
      },
    );

    return _parseTags(response);
  }
}

List<TagDto> _parseTags(value) {
  final dtos = <TagDto>[];
  final contentType = (value.headers['content-type'] as List?)?.firstOrNull;

  if (contentType == null) return [];

  if (contentType.contains('text/xml') ||
      contentType.contains('application/xml')) {
    var xmlDocument = XmlDocument.parse(value.data);
    var tags = xmlDocument.findAllElements('tag');
    for (final item in tags) {
      dtos.add(TagDto.fromXml(item));
    }
  } else {
    final data = value.data['tag'];
    if (data == null) return [];

    for (final item in data) {
      dtos.add(TagDto.fromJson(item));
    }
  }

  return dtos;
}

FutureOr<List<CommentDto>> _parseCommentDtos(value) {
  final dtos = <CommentDto>[];
  final xmlDocument = XmlDocument.parse(value.data);
  final comments = xmlDocument.findAllElements('comment');
  for (final item in comments) {
    dtos.add(CommentDto.fromXml(item));
  }
  return dtos;
}

mixin RequestDeduplicator<T> {
  final _ongoingRequests = <String, Future<T>>{};

  Future<T> deduplicate(String key, Future<T> Function() request) {
    if (_ongoingRequests.containsKey(key)) {
      return _ongoingRequests[key]!;
    }

    _ongoingRequests[key] = request().whenComplete(() {
      _ongoingRequests.remove(key);
    });

    return _ongoingRequests[key]!;
  }
}
