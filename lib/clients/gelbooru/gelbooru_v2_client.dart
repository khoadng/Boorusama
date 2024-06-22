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

class GelbooruV2Client with GelbooruClientFavorites {
  GelbooruV2Client({
    String? baseUrl,
    Map<String, String>? headers,
    this.userId,
    this.apiKey,
    this.passHash,
    Dio? dio,
  })  : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl ?? '',
              headers: headers ?? {},
            )),
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

  factory GelbooruV2Client.custom({
    Dio? dio,
    String? login,
    String? apiKey,
    String? passHash,
    required String baseUrl,
  }) =>
      GelbooruV2Client(
        baseUrl: baseUrl,
        dio: dio,
        userId: login,
        apiKey: apiKey,
        passHash: passHash,
      );

  Future<List<PostV2Dto>> getPosts({
    int? page,
    int? limit,
    List<String>? tags,
  }) async {
    final baseUrl = _dio.options.baseUrl;

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
      List l => l.map((item) => PostV2Dto.fromJson(item, baseUrl)).toList(),
      String s => (jsonDecode(s) as List<dynamic>)
          .map<PostV2Dto>((item) => PostV2Dto.fromJson(item, baseUrl))
          .toList(),
      _ => <PostV2Dto>[],
    };

    final filterNulls = result.where((e) => e.hash != null).toList();

    return filterNulls;
  }

  Future<List<AutocompleteDto>> autocomplete({
    required String term,
    int? limit,
  }) async {
    final response = await _dio.get(
      '/autocomplete.php',
      queryParameters: {
        'q': term,
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
        baseUrl: _baseUrl ?? '',
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

    final noteContainer = html.getElementById('note-container');

    final notes = noteContainer?.getElementsByClassName('note-box').map((e) {
      final style = e.attributes['style'];
      final idString = e.attributes['id'];

      if (style == null || idString == null) return null;
      final width = int.tryParse(
          RegExp(r'width: (\d+)px;').firstMatch(style)?.group(1) ?? '');
      final height = int.tryParse(
          RegExp(r'height: (\d+)px;').firstMatch(style)?.group(1) ?? '');
      final top = int.tryParse(
          RegExp(r'top: (\d+)px;').firstMatch(style)?.group(1) ?? '');
      final left = int.tryParse(
          RegExp(r'left: (\d+)px;').firstMatch(style)?.group(1) ?? '');
      final id = int.tryParse(
          RegExp(r'note-box-(\d+)').firstMatch(idString)?.group(1) ?? '');

      return NoteDto(
        id: id,
        width: width,
        height: height,
        y: top,
        x: left,
      );
    }).toList();
    final notesWithBody =
        notes?.where((e) => e != null).map((e) => e!).map((e) {
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
      '/index.php',
      queryParameters: {
        'page': 'post',
        's': 'view',
        'id': postId,
      },
    );

    final html = parse(response.data);
    final sideBar = html.getElementById('tag-sidebar');
    final copyrightTags =
        sideBar?.getElementsByClassName('tag-type-copyright tag');
    final characterTags =
        sideBar?.getElementsByClassName('tag-type-character tag');
    final artistTags = sideBar?.getElementsByClassName('tag-type-artist tag');
    final generalTags = sideBar?.getElementsByClassName('tag-type-general tag');
    final metaTags = sideBar?.getElementsByClassName('tag-type-meta tag');

    return [
      for (final tag in artistTags ?? []) TagDto.fromHtml(tag, 1),
      for (final tag in copyrightTags ?? []) TagDto.fromHtml(tag, 3),
      for (final tag in characterTags ?? []) TagDto.fromHtml(tag, 4),
      for (final tag in generalTags ?? []) TagDto.fromHtml(tag, 0),
      for (final tag in metaTags ?? []) TagDto.fromHtml(tag, 5),
    ];
  }
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
