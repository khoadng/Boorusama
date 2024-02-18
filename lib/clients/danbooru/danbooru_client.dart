// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'danbooru_client_artists.dart';
import 'danbooru_client_comments.dart';
import 'danbooru_client_dmails.dart';
import 'danbooru_client_explores.dart';
import 'danbooru_client_favorite_groups.dart';
import 'danbooru_client_favorites.dart';
import 'danbooru_client_forums.dart';
import 'danbooru_client_notes.dart';
import 'danbooru_client_pools.dart';
import 'danbooru_client_posts.dart';
import 'danbooru_client_reports.dart';
import 'danbooru_client_saved_searches.dart';
import 'danbooru_client_tags.dart';
import 'danbooru_client_uploads.dart';
import 'danbooru_client_users.dart';
import 'danbooru_client_versions.dart';
import 'types/source_dto.dart';
import 'types/types.dart';

String _encodeAuthHeader(String login, String apiKey) =>
    base64Encode(utf8.encode('$login:$apiKey'));

class DanbooruClient
    with
        DanbooruClientArtists,
        DanbooruClientComments,
        DanbooruClientDmails,
        DanbooruClientExplores,
        DanbooruClientFavoriteGroups,
        DanbooruClientFavorites,
        DanbooruClientForums,
        DanbooruClientNotes,
        DanbooruClientPools,
        DanbooruClientPosts,
        DanbooruClientReports,
        DanbooruClientSavedSearches,
        DanbooruClientTags,
        DanbooruClientUploads,
        DanbooruClientUsers,
        DanbooruClientVersions {
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

  Future<SourceDto> getSource(String source) async {
    final response = await dio.get(
      '/source.json',
      queryParameters: {
        'url': source,
      },
    );

    return SourceDto.fromJson(response.data);
  }

  Future<List<IqdbResultDto>> iqdb({
    required int mediaAssetId,
    double? similarity = 50,
    double? highSimilarity = 70,
    int? limit = 5,
  }) async {
    final response = await dio.get(
      '/iqdb_queries.json',
      queryParameters: {
        'media_asset_id': mediaAssetId,
        'similarity': similarity,
        'high_similarity': highSimilarity,
        'limit': limit,
      },
    );

    return (response.data as List)
        .map((item) => IqdbResultDto.fromJson(item))
        .toList();
  }
}
