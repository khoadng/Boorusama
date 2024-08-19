// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:xml/xml.dart';

// Project imports:
import 'package:boorusama/clients/gelbooru/gelbooru_client_favorites.dart';
import 'types/types.dart';

const _kGelbooruUrl = 'https://gelbooru.com/';

typedef GelbooruPosts = ({
  List<PostDto> posts,
  int? count,
});

class GelbooruClient
    with GelbooruClientFavorites, RequestDeduplicator<GelbooruPosts> {
  GelbooruClient({
    String? baseUrl,
    Map<String, String>? headers,
    this.userId,
    this.apiKey,
    this.passHash,
    Dio? dio,
  }) : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl ?? '',
              headers: headers ?? {},
            ));

  factory GelbooruClient.gelbooru({
    Dio? dio,
    String? login,
    String? apiKey,
    String? passHash,
  }) =>
      GelbooruClient(
        baseUrl: _kGelbooruUrl,
        dio: dio,
        userId: login,
        apiKey: apiKey,
        passHash: passHash,
      );

  factory GelbooruClient.custom({
    Dio? dio,
    String? login,
    String? apiKey,
    String? passHash,
    required String baseUrl,
  }) =>
      GelbooruClient(
        baseUrl: baseUrl,
        dio: dio,
        userId: login,
        apiKey: apiKey,
        passHash: passHash,
      );

  final Dio _dio;
  @override
  final String? userId;
  final String? apiKey;
  @override
  final String? passHash;
  @override
  Dio get dio => _dio;

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

  Future<List<NoteDto>> getNotesFromPostId({
    required int postId,
  }) async {
    final crawlerDio = Dio(
      BaseOptions(
        baseUrl: _dio.options.baseUrl,
        headers: _dio.options.headers,
      ),
    );

    final response = await crawlerDio.get(
      '/index.php',
      queryParameters: {
        'page': 'post',
        's': 'view',
        'id': postId,
      },
    );

    final html = parse(response.data);

    final noteContainer = html.getElementById('notes');

    // grab all article elements
    final noteElements = noteContainer?.getElementsByTagName('article');

    final notes = noteElements?.map((e) {
      final id = int.tryParse(e.attributes['data-id'] ?? '');
      final width = int.tryParse(e.attributes['data-width'] ?? '');
      final height = int.tryParse(e.attributes['data-height'] ?? '');
      final x = int.tryParse(e.attributes['data-x'] ?? '');
      final y = int.tryParse(e.attributes['data-y'] ?? '');
      final body = e.attributes['data-body'];

      return NoteDto(
        id: id,
        width: width,
        height: height,
        x: x,
        y: y,
        body: body,
      );
    }).toList();

    return notes ?? [];
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
