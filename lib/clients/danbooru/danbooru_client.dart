// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'danbooru_client_artists.dart';
import 'danbooru_client_comments.dart';
import 'danbooru_client_explores.dart';
import 'danbooru_client_favorite_groups.dart';
import 'danbooru_client_favorites.dart';
import 'danbooru_client_forums.dart';
import 'danbooru_client_pools.dart';
import 'danbooru_client_posts.dart';
import 'danbooru_client_reports.dart';
import 'danbooru_client_saved_searches.dart';
import 'danbooru_client_tags.dart';
import 'danbooru_client_users.dart';
import 'types/autocomplete_dto.dart';
import 'types/note_dto.dart';
import 'types/wiki_dto.dart';

String _encodeAuthHeader(String login, String apiKey) =>
    base64Encode(utf8.encode('$login:$apiKey'));

class DanbooruClient
    with
        DanbooruClientPosts,
        DanbooruClientArtists,
        DanbooruClientComments,
        DanbooruClientExplores,
        DanbooruClientFavoriteGroups,
        DanbooruClientFavorites,
        DanbooruClientForums,
        DanbooruClientPools,
        DanbooruClientReports,
        DanbooruClientSavedSearches,
        DanbooruClientTags,
        DanbooruClientUsers {
  DanbooruClient({
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

  @override
  Dio get dio => _dio;

  Future<Response> getProfile() async {
    final response = await dio.get(
      '/profile.json',
    );

    return response;
  }

  Future<List<NoteDto>> getNotes({
    required int postId,
    int limit = 200,
    int? page,
  }) async {
    final response = await dio.get(
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

  Future<int?> countPosts({
    List<String>? tags,
  }) async {
    try {
      final response = await dio.get(
        '/counts/posts.json',
        queryParameters: {
          if (tags != null && tags.isNotEmpty) 'tags': tags.join(' '),
        },
      );

      return response.data['counts']['posts'];
    } catch (e) {
      return null;
    }
  }

  Future<WikiDto> getWiki(String subject) async {
    final response = await dio.get('/wiki_pages/$subject.json');

    return WikiDto.fromJson(response.data);
  }

  Future<List<AutocompleteDto>> autocomplete({
    required String query,
    int? limit,
  }) async {
    final response = await dio.get(
      '/autocomplete.json',
      queryParameters: {
        'search[query]': query,
        'search[type]': 'tag_query',
        'limit': limit ?? 20,
      },
    );

    return (response.data as List)
        .map((item) => AutocompleteDto.fromJson(item))
        .toList();
  }
}
