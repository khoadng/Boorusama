import 'dart:async';

import 'package:dio/dio.dart';

import '../common/endpoint.dart';
import '../common/feature.dart';
import '../common/request_handler.dart';
import 'gelbooru_client_favorites.dart';
import 'parsers/response_parsers.dart';
import 'types/types.dart';

class GelbooruV2Client with GelbooruClientFavorites {
  static ResponseParser? resolveParser(String? parserName) {
    return switch (parserName) {
      'gelbooru-notes-html' => parseNotesHtml,
      'gelbooru-tags-sidebar' => parseTagsHtml,
      _ => null,
    };
  }

  static EndpointConfig defaultEndpoints({
    Map<String, String>? globalUserParams,
  }) {
    return EndpointConfig(
      globalUserParams: globalUserParams,
      endpoints: [
        Endpoint<GelbooruV2Posts>.fromFeature(
          feature: GelbooruV2Config.defaultFeatures[BooruFeatureId.posts]!,
          parser: parsePostsResponse,
        ),
        Endpoint<List<AutocompleteDto>>.fromFeature(
          feature:
              GelbooruV2Config.defaultFeatures[BooruFeatureId.autocomplete]!,
          parser: parseAutocompleteResponse,
        ),
        Endpoint<List<CommentDto>>.fromFeature(
          feature: GelbooruV2Config.defaultFeatures[BooruFeatureId.comments]!,
          parser: parseCommentsResponse,
        ),
        Endpoint<List<NoteDto>>.fromFeature(
          feature: GelbooruV2Config.defaultFeatures[BooruFeatureId.notes]!,
          parser: parseNotesHtml,
        ),
        Endpoint<List<TagDto>>.fromFeature(
          feature: GelbooruV2Config.defaultFeatures[BooruFeatureId.tags]!,
          parser: parseTagsHtml,
        ),
        Endpoint<List<PostFavoriteDto>>.fromFeature(
          feature: GelbooruV2Config.defaultFeatures[BooruFeatureId.favorites]!,
          parser: (response, context) => <PostFavoriteDto>[],
        ),
      ],
    );
  }

  GelbooruV2Client({
    String? baseUrl,
    Map<String, String>? headers,
    this.userId,
    this.apiKey,
    this.passHash,
    EndpointConfig? config,
    Dio? dio,
  }) : _dio = dio ?? Dio(BaseOptions(baseUrl: '', headers: headers ?? {})),
       _baseUrl = baseUrl ?? '',
       _config = config ?? defaultEndpoints() {
    _requestHandler = RequestHandler(
      dio: _dio,
      baseUrl: _baseUrl,
      config: _config,
      buildAuthParams: () => {
        if (userId != null) P.userId: userId!,
        if (apiKey != null) P.apiKey: apiKey!,
      },
      buildContext: (extra) => {'baseUrl': _baseUrl, ...?extra},
    );
  }

  final Dio _dio;
  final String _baseUrl;
  final EndpointConfig _config;
  late final RequestHandler _requestHandler;

  @override
  final String? userId;
  final String? apiKey;
  @override
  final String? passHash;
  @override
  Dio get dio => _dio;

  Future<GelbooruV2Posts> getPosts({
    int? page,
    int? limit,
    List<String>? tags,
  }) => _requestHandler.makeRequest(
    featureId: BooruFeatureId.posts,
    params: {
      if (tags?.isNotEmpty == true) P.tags: tags!.join(' '),
      if (page != null) P.page: page - 1,
      if (limit != null) P.limit: limit,
    },
  );

  Future<PostV2Dto?> getPost(int id) => _requestHandler.makeRequest(
    featureId: BooruFeatureId.post,
    params: {P.postId: id},
  );

  Future<List<AutocompleteDto>> autocomplete({
    required String term,
    int? limit,
  }) async {
    try {
      return await _requestHandler.makeRequest(
        featureId: BooruFeatureId.autocomplete,
        params: {
          P.query: term,
          if (limit != null) P.limit: limit,
        },
      );
    } on Exception catch (_) {
      return [];
    }
  }

  Future<List<CommentDto>> getComments({
    required int postId,
  }) => _requestHandler.makeRequest(
    featureId: BooruFeatureId.comments,
    params: {P.postId: postId},
  );

  Future<List<NoteDto>> getNotesFromPostId({required int postId}) =>
      _requestHandler.makeRequest(
        featureId: BooruFeatureId.notes,
        params: {P.postId: postId},
        context: {P.postId: postId},
      );

  Future<List<TagDto>> getTagsFromPostId({required int postId}) =>
      _requestHandler.makeRequest(
        featureId: BooruFeatureId.tags,
        params: {P.postId: postId},
        context: {P.postId: postId},
      );
}
