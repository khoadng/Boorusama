// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

String _encodeAuthHeader(String login, String apiKey) =>
    base64Encode(utf8.encode('$login:$apiKey'));

String _dateToE621Date(DateTime date) =>
    '${date.year}-${date.month}-${date.day}';

class E621Client {
  E621Client({
    required String baseUrl,
    String? login,
    String? apiKey,
    Dio? dio,
  }) {
    _dio = dio ??
        Dio(BaseOptions(
          baseUrl: baseUrl,
        ));

    if (login != null && apiKey != null) {
      _dio.options.headers['Authorization'] =
          'Basic ${_encodeAuthHeader(login, apiKey)}';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  late Dio _dio;

  Future<List<PostDto>> getPosts({
    List<String>? tags,
    int? page,
    int? limit,
  }) async {
    final response = await _dio.get(
      '/posts.json',
      queryParameters: {
        if (tags != null && tags.isNotEmpty) 'tags': tags.join(' '),
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
    );

    final data = response.data['posts'];

    return (data as List).map((item) => PostDto.fromJson(item)).toList();
  }

  Future<bool> addToFavorites({
    required int postId,
  }) async {
    try {
      final _ = await _dio.post(
        '/favorites.json',
        queryParameters: {
          'post_id': postId,
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFromFavorites({
    required int postId,
  }) async {
    try {
      final _ = await _dio.delete(
        '/favorites/$postId.json',
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<CommentDto>> getComments({
    required int postId,
    int? page,
    int? limit,
  }) async {
    final response = await _dio.get(
      '/comments.json',
      queryParameters: {
        'group_by': 'comment',
        'search[post_id]': postId,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
    );

    return (response.data as List)
        .map((item) => CommentDto.fromJson(item))
        .toList();
  }

  Future<ArtistDto> getArtist({
    required String nameOrID,
  }) async {
    final response = await _dio.get(
      '/artists/$nameOrID.json',
    );

    return ArtistDto.fromJson(response.data);
  }

  Future<List<ArtistDto>> getArtists({
    required String name,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      '/artists.json',
      queryParameters: {
        'search[name]': name,
      },
      cancelToken: cancelToken,
    );

    return (response.data as List)
        .map((item) => ArtistDto.fromJson(item))
        .toList();
  }

  Future<List<PostDto>> getPopularPosts(
      {required DateTime date, required TimeScale scale}) async {
    final response = await _dio.get(
      '/popular.json',
      queryParameters: {
        'date': _dateToE621Date(date),
        'scale': scale.name,
      },
    );

    final data = response.data['posts'];

    return (data as List).map((item) => PostDto.fromJson(item)).toList();
  }

  Future<List<TagDto>> getTags({
    required String name,
    TagSortOrder order = TagSortOrder.count,
    int? page,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      '/tags.json',
      queryParameters: {
        'search[name_matches]': '$name*',
        'search[order]': order.name,
        if (page != null) 'page': page,
        'limit': limit,
      },
      cancelToken: cancelToken,
    );

    return (response.data as List)
        .map((item) => TagDto.fromJson(item))
        .toList();
  }

  Future<List<AutocompleteDto>> getAutocomplete({
    required String query,
  }) =>
      switch (query.length) {
        0 || 1 => Future.value(<AutocompleteDto>[]),
        2 => getTags(name: query).then((value) => value
            .map((e) => AutocompleteDto(
                  id: e.id,
                  name: e.name,
                  postCount: e.postCount,
                  category: e.category,
                ))
            .toList()),
        _ => _autocomplete(query: query),
      };

  Future<List<AutocompleteDto>> _autocomplete({
    required String query,
  }) async {
    final response = await _dio.get(
      '/tags/autocomplete.json',
      queryParameters: {
        'search[name_matches]': query,
        'expiry': 7,
      },
    );

    return (response.data as List)
        .map((item) => AutocompleteDto.fromJson(item))
        .toList();
  }

  Future<List<NoteDto>> getNotes({
    required int postId,
    int limit = 200,
    int? page,
  }) async {
    final response = await _dio.get(
      '/notes.json',
      queryParameters: {
        'search[post_id]': postId,
        'limit': limit,
        if (page != null) 'page': page,
      },
    );

    return (response.data as List)
        .map((item) => NoteDto.fromJson(item))
        .toList();
  }
}
