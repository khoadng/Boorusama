// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:xml/xml.dart';

// Project imports:
import 'gelbooru_client_favorites.dart';
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

  Uri? getTestPostUri({
    required String userId,
    required String apiKey,
  }) =>
      Uri.tryParse(_dio.options.baseUrl)?.replace(
        queryParameters: {
          'page': 'dapi',
          's': 'post',
          'q': 'index',
          'json': '1',
          if (userId.isNotEmpty) 'user_id': userId,
          if (apiKey.isNotEmpty) 'api_key': apiKey,
        },
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
          final Map m => () {
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

  Future<PostDto?> getPost(int id) async {
    final response = await _dio.get(
      '/index.php',
      queryParameters: {
        'page': 'dapi',
        's': 'post',
        'q': 'index',
        'json': '1',
        'id': id,
        if (userId != null) 'user_id': userId,
        if (apiKey != null) 'api_key': apiKey,
      },
    );

    final data = response.data;
    if (data == null) return null;

    final baseUrl = _dio.options.baseUrl;
    return switch (data) {
      final Map m => m.containsKey('post')
          ? (m['post'] as List)
              .map((item) => PostDto.fromJson(item, baseUrl))
              .firstOrNull
          : null,
      _ => null,
    };
  }

  Future<List<AutocompleteDto>> autocomplete({
    required String term,
    int? limit,
  }) async {
    try {
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
        final List l =>
          l.map((item) => AutocompleteDto.fromJson(item)).toList(),
        final String s => (jsonDecode(s) as List<dynamic>)
            .map((item) => AutocompleteDto.fromJson(item))
            .toList(),
        _ => <AutocompleteDto>[],
      };
    } on Exception catch (_) {
      return [];
    }
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

  Future<List<CommentDto>> getCommentsFromPostId({
    required int postId,
    int? page,
  }) async {
    // Calculate pid (0-based pagination where page 1 = pid 0, page 2 = pid 10)
    final pid = page == null ? null : (page - 1) * 10;

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
        if (pid != null) 'pid': pid,
      },
    );

    final document = parse(response.data);
    final comments = <CommentDto>[];

    final commentBodies = document.getElementsByClassName('commentBody');

    for (final div in commentBodies) {
      try {
        // Extract username
        final usernameElement = div.querySelector('b');
        final username = usernameElement?.text ?? 'Unknown';

        // Find the comment ID from text
        final fullText = div.text;
        final idMatch = RegExp(r'#(\d+)').firstMatch(fullText);
        final commentId = idMatch?.group(1) ?? '';

        // Extract timestamp
        final timestampMatch =
            RegExp(r'commented at ([\d-]+ [\d:]+)').firstMatch(fullText);
        final timestamp = timestampMatch?.group(1) ?? '';

        // Get user ID from href
        final userLink = div.querySelector('a')?.attributes['href'] ?? '';
        final userIdMatch = RegExp(r'id=(\d+)').firstMatch(userLink);
        final userId = userIdMatch?.group(1) ?? '';

        final quoteElement = div.querySelector('div.quote');
        final quote = quoteElement?.text ?? '';

        final texts = div.nodes.whereType<Text>().toList();
        final body = texts.length >= 3 ? texts[2].text : '';
        final effectiveBody =
            quote.isNotEmpty ? '[quote]\n$quote[/quote]\n\n$body' : body;

        if (commentId.isNotEmpty) {
          comments.add(CommentDto(
            id: commentId,
            body: effectiveBody,
            creator: username,
            creatorId: userId,
            createdAt: timestamp,
            postId: postId.toString(),
          ));
        }
      } catch (e) {
        continue;
      }
    }

    return comments;
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
    final xmlDocument = XmlDocument.parse(value.data);
    final tags = xmlDocument.findAllElements('tag');
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
