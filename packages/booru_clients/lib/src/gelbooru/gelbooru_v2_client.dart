// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:xml/xml.dart';

// Project imports:
import 'gelbooru_client_favorites.dart';
import 'types/types.dart';

typedef GelbooruV2Posts = ({List<PostV2Dto> posts, int? count});

class GelbooruV2Client with GelbooruClientFavorites {
  GelbooruV2Client({
    String? baseUrl,
    Map<String, String>? headers,
    this.userId,
    this.apiKey,
    this.passHash,
    Dio? dio,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: '',
               headers: headers ?? {},
             ),
           ),
       _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;
  @override
  final String? userId;
  final String? apiKey;
  @override
  final String? passHash;
  @override
  Dio get dio => _dio;

  String _path(String path) {
    if (_baseUrl == null || _baseUrl.isEmpty) return path;
    return '$_baseUrl$path';
  }

  String _pathAutocomplete(String path) {
    if (_baseUrl == null || _baseUrl.isEmpty) return path;

    //FIXME: Hotfix for this specific site since they are using subdomain for autocomplete, need to find a better way to handle this
    return _baseUrl.contains('rule34.xxx')
        ? () {
            final uri = Uri.tryParse(_baseUrl);

            if (uri == null) return path;
            final authority = uri.authority;
            // if the authority is using any subdomain, we need to remove it
            final removedSubdomain = authority.split('.').length > 2
                ? authority.split('.').sublist(1).join('.')
                : authority;
            final withSubdomain = 'api.$removedSubdomain';

            return uri
                .replace(
                  host: withSubdomain,
                  path: path,
                )
                .toString();
          }()
        : _path(path);
  }

  Future<GelbooruV2Posts> getPosts({
    int? page,
    int? limit,
    List<String>? tags,
  }) async {
    final baseUrl = _dio.options.baseUrl;

    final response = await _dio.get(
      _path('/index.php'),
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
                    .map((item) => PostV2Dto.fromJson(item, baseUrl))
                    .toList()
              : <PostV2Dto>[],
          count: count,
        );
      }(),
      final List l => (
        posts: l.map((item) => PostV2Dto.fromJson(item, baseUrl)).toList(),
        count: null,
      ),
      final String s => (
        posts: (jsonDecode(s) as List<dynamic>)
            .map<PostV2Dto>((item) => PostV2Dto.fromJson(item, baseUrl))
            .toList(),
        count: null,
      ),
      _ => (
        posts: <PostV2Dto>[],
        count: null,
      ),
    };

    final filterNulls = result.posts.where((e) => e.hash != null).toList();

    return (
      posts: filterNulls,
      count: result.count,
    );
  }

  Future<PostV2Dto?> getPost(int id) async {
    final response = await _dio.get(
      _path('/index.php'),
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
      final List l =>
        l.map((item) => PostV2Dto.fromJson(item, baseUrl)).toList().firstOrNull,
      final Map m =>
        m is Map<String, dynamic> ? PostV2Dto.fromJson(m, baseUrl) : null,
      _ => null,
    };
  }

  Future<List<AutocompleteDto>> autocomplete({
    required String term,
    int? limit,
  }) async {
    try {
      final response = await _dio.get(
        _pathAutocomplete('/autocomplete.php'),
        queryParameters: {
          'q': term,
          if (userId != null) 'user_id': userId,
          if (apiKey != null) 'api_key': apiKey,
        },
      );

      return switch (response.data) {
        final List l =>
          l.map((item) => AutocompleteDto.fromJson(item)).toList(),
        final String s =>
          (jsonDecode(s) as List<dynamic>)
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
      _path('/index.php'),
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
        baseUrl: _baseUrl ?? '',
        headers: _dio.options.headers,
      ),
    );

    final response = await crawlerDio.get(
      _path('/index.php'),
      queryParameters: {
        'page': 'post',
        's': 'view',
        'id': postId,
      },
    );

    final html = parse(response.data);

    final noteContainer = html.getElementById('note-container');

    final notes = noteContainer?.getElementsByClassName('note-box').map((e) {
      final style = e.attributes['style'];
      final idString = e.attributes['id'];

      if (style == null || idString == null) return null;
      final width = int.tryParse(
        RegExp(r'width: (\d+)px;').firstMatch(style)?.group(1) ?? '',
      );
      final height = int.tryParse(
        RegExp(r'height: (\d+)px;').firstMatch(style)?.group(1) ?? '',
      );
      final top = int.tryParse(
        RegExp(r'top: (\d+)px;').firstMatch(style)?.group(1) ?? '',
      );
      final left = int.tryParse(
        RegExp(r'left: (\d+)px;').firstMatch(style)?.group(1) ?? '',
      );
      final id = int.tryParse(
        RegExp(r'note-box-(\d+)').firstMatch(idString)?.group(1) ?? '',
      );

      return NoteDto(
        id: id,
        width: width,
        height: height,
        y: top,
        x: left,
      );
    }).toList();
    final notesWithBody = notes?.where((e) => e != null).map((e) => e!).map((
      e,
    ) {
      final body = html.getElementById('note-body-${e.id}')?.text;

      return e.copyWith(
        body: () => body,
      );
    }).toList();

    return notesWithBody ?? [];
  }

  Future<List<TagDto>> getTagsFromPostId({required int postId}) async {
    final crawlerDio = Dio(
      BaseOptions(
        baseUrl: _baseUrl ?? '',
        headers: _dio.options.headers,
      ),
    );

    final response = await crawlerDio.get(
      _path('/index.php'),
      queryParameters: {
        'page': 'post',
        's': 'view',
        'id': postId,
      },
    );

    final html = parse(response.data);
    final sideBar = html.getElementById('tag-sidebar');
    final copyrightTags =
        sideBar?.querySelectorAll('li.tag-type-copyright') ?? [];
    final characterTags =
        sideBar?.querySelectorAll('li.tag-type-character') ?? [];
    final artistTags = sideBar?.querySelectorAll('li.tag-type-artist') ?? [];
    final generalTags = sideBar?.querySelectorAll('li.tag-type-general') ?? [];

    final metaTags = sideBar?.querySelectorAll('li.tag-type-meta') ?? [];
    final metadataTags =
        sideBar?.querySelectorAll('li.tag-type-metadata') ?? [];
    final effectiveMetaTags = metaTags.isNotEmpty ? metaTags : metadataTags;

    return [
      for (final tag in artistTags) TagDto.fromHtml(tag, 1),
      for (final tag in copyrightTags) TagDto.fromHtml(tag, 3),
      for (final tag in characterTags) TagDto.fromHtml(tag, 4),
      for (final tag in generalTags) TagDto.fromHtml(tag, 0),
      for (final tag in effectiveMetaTags) TagDto.fromHtml(tag, 5),
    ];
  }
}

FutureOr<List<CommentDto>> _parseCommentDtos(Response value) {
  final dtos = <CommentDto>[];
  final xmlDocument = XmlDocument.parse(value.data);
  final comments = xmlDocument.findAllElements('comment');
  for (final item in comments) {
    dtos.add(CommentDto.fromXml(item));
  }
  return dtos;
}
