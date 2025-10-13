// Package imports:
import 'package:booru_clients/eshuushuu.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/search/selected_tags/tag.dart';
import '../client_provider.dart';
import 'parser.dart';
import 'types.dart';

class EshuushuuSearchState extends Equatable {
  const EshuushuuSearchState({
    this.tagIdCache = const {},
  });

  final Map<EshuushuuSearchRequest, List<int>> tagIdCache;

  @override
  List<Object?> get props => [tagIdCache];

  EshuushuuSearchState copyWith({
    Map<EshuushuuSearchRequest, List<int>>? tagIdCache,
  }) {
    return EshuushuuSearchState(
      tagIdCache: tagIdCache ?? this.tagIdCache,
    );
  }

  List<int>? getCachedIds(EshuushuuSearchRequest request) =>
      tagIdCache[request];

  bool hasCachedIds(EshuushuuSearchRequest request) =>
      tagIdCache.containsKey(request);

  EshuushuuSearchState setCachedIds(
    EshuushuuSearchRequest request,
    List<int> ids,
  ) {
    return copyWith(
      tagIdCache: {...tagIdCache, request: ids},
    );
  }
}

class EshuushuuSearchNotifier
    extends FamilyNotifier<EshuushuuSearchState, BooruConfigAuth> {
  @override
  EshuushuuSearchState build(BooruConfigAuth arg) =>
      const EshuushuuSearchState();

  EShuushuuClient get _client => ref.read(eshuushuuClientProvider(arg));

  Future<List<EshuushuuPost>> search(
    EshuushuuSearchRequest request, {
    int? page,
    int? limit,
  }) async {
    final dtos = switch (request.isEmpty) {
      true => await _client.getHomePage(page: page),
      false => await _fetchPostsWithTagIds(request, page),
    };

    return dtos
        .map(
          (e) => postDtoToPost(
            e,
            PostMetadata(
              page: page,
              search: request.allTags.join(' '),
              limit: limit,
            ),
          ),
        )
        .toList();
  }

  Future<List<PostDto>> _fetchPostsWithTagIds(
    EshuushuuSearchRequest request,
    int? page,
  ) async {
    final tagIds = await _getOrFetchTagIds(request);
    return tagIds.isEmpty ? [] : _client.getPosts(tagIds: tagIds, page: page);
  }

  Future<List<int>> _getOrFetchTagIds(EshuushuuSearchRequest request) async {
    final cached = state.getCachedIds(request);
    if (cached != null) return cached;

    final ids = await _client.getTagIds(request);

    state = state.setCachedIds(request, ids);
    return ids;
  }

  Future<List<EshuushuuPost>> searchByTags(
    List<String> tags, {
    required int page,
    int? limit,
  }) => search(
    EshuushuuSearchRequest(tags: tags.map(_wrapWithQuotes).join(' ')),
    page: page,
    limit: limit,
  );

  Future<List<EshuushuuPost>> searchByController(
    SearchTagSet controller, {
    required int page,
    int? limit,
  }) {
    final request = _buildSearchRequest(controller);
    return search(request, page: page, limit: limit);
  }
}

EshuushuuSearchRequest _buildSearchRequest(SearchTagSet tagSet) {
  final characters = tagSet.tags.where(
    (t) => t.category == TagType.character.valueStr,
  );
  final artists = tagSet.tags.where(
    (t) => t.category == TagType.artist.valueStr,
  );
  final sources = tagSet.tags.where(
    (t) => t.category == TagType.source.valueStr,
  );
  final general = tagSet.tags.where(
    (t) => t.category == TagType.tag.valueStr,
  );
  return EshuushuuSearchRequest(
    tags: general.map(_wrapItemWithQuotes).join(' '),
    character: characters.map(_wrapItemWithQuotes).join(' '),
    artist: artists.map(_wrapItemWithQuotes).join(' '),
    source: sources.map(_wrapItemWithQuotes).join(' '),
  );
}

String _wrapWithQuotes(String tag) => '"${tag.replaceAll('_', ' ')}"';

String _wrapItemWithQuotes(TagSearchItem tag) =>
    _wrapWithQuotes(tag.originalTag);

final eshuushuuPostSearchProvider =
    NotifierProviderFamily<
      EshuushuuSearchNotifier,
      EshuushuuSearchState,
      BooruConfigAuth
    >(EshuushuuSearchNotifier.new);
