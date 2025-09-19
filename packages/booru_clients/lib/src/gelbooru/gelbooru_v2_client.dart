import 'dart:async';

import 'package:dio/dio.dart';

import '../common/endpoint.dart';
import '../common/feature.dart';
import '../common/request_handler.dart';
import 'gelbooru_client_favorites.dart';
import 'parsers/parsers.dart';
import 'types/types.dart';

class GelbooruV2Client with GelbooruClientFavorites {
  static EndpointConfig defaultEndpoints({
    Map<String, String>? globalUserParams,
  }) {
    return EndpointConfig(
      globalUserParams:
          globalUserParams ??
          {
            P.userId: 'user_id',
            P.apiKey: 'api_key',
          },
      endpoints: [
        Endpoint<GelbooruV2Posts>.fromFeature(
          feature: GelbooruV2Config.defaultFeatures[BooruFeatureId.posts]!,
          parser: parseGelPosts,
        ),
        Endpoint<PostV2Dto?>.fromFeature(
          feature: GelbooruV2Config.defaultFeatures[BooruFeatureId.post]!,
          parser: parseDefaultPostHtml,
        ),
        Endpoint<List<AutocompleteDto>>.fromFeature(
          feature:
              GelbooruV2Config.defaultFeatures[BooruFeatureId.autocomplete]!,
          parser: parseGelAutocomplete,
        ),
        Endpoint<List<CommentDto>>.fromFeature(
          feature: GelbooruV2Config.defaultFeatures[BooruFeatureId.comments]!,
          parser: parseGelComments,
        ),
        Endpoint<List<NoteDto>>.fromFeature(
          feature: GelbooruV2Config.defaultFeatures[BooruFeatureId.notes]!,
          parser: parseGelNotesHtml,
        ),
        Endpoint<List<TagDto>>.fromFeature(
          feature: GelbooruV2Config.defaultFeatures[BooruFeatureId.tags]!,
          parser: parseGelTagsHtml,
        ),
        Endpoint<GelbooruV2Posts>.fromFeature(
          feature: GelbooruV2Config.defaultFeatures[BooruFeatureId.favorites]!,
          parser: parseDefaultFavoritePostsHtml,
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
    this.paginationType = PaginationType.page,
    this.fixedLimit,
  }) : _dio = dio ?? Dio(BaseOptions(baseUrl: '', headers: headers ?? {})),
       _baseUrl = baseUrl ?? '',
       _config = config ?? defaultEndpoints() {
    _requestHandler = RequestHandler(
      dio: _dio,
      baseUrl: _baseUrl,
      config: _config,
      buildAuthParams: () => switch ((userId, apiKey)) {
        (final u?, final a?) => {
          P.userId: u,
          P.apiKey: a,
        },
        _ => const {},
      },

      buildContext: (extra) => {
        'baseUrl': _baseUrl,
        ...?extra,
      },
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

  final PaginationType paginationType;
  final int? fixedLimit;

  Future<GelbooruV2Posts> getPosts({
    int? page,
    int? limit,
    List<String>? tags,
  }) => _requestHandler.makeRequest(
    featureId: BooruFeatureId.posts,
    params: {
      if (tags?.isNotEmpty == true) P.tags: tags!.join(' '),
      if (page != null)
        P.page: paginationType.calculatePage(
          page: page,
          limit: fixedLimit ?? limit,
        ),
      if (fixedLimit == null) P.limit: ?limit,
    },
  );

  Future<PostV2Dto?> getPost(int id) => _requestHandler.makeRequest(
    featureId: BooruFeatureId.post,
    params: {P.postId: id},
    context: {P.postId: id},
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

  Future<GelbooruV2Posts> getFavorites({
    required String uid,
    required PaginationType? paginationType,
    required int? fixedLimit,
    int? page,
  }) {
    final p = paginationType ?? this.paginationType;
    final l = fixedLimit ?? this.fixedLimit;

    return _requestHandler.makeRequest(
      featureId: BooruFeatureId.favorites,
      params: {
        P.userId: uid,
        if (page != null)
          P.page: p.calculatePage(
            page: page,
            limit: l,
          ),
      },
      context: {P.userId: uid},
    );
  }
}
