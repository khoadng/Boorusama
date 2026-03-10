// Package imports:
import 'package:booru_clients/eshuushuu.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/posts/post/types.dart';
import '../client_provider.dart';
import 'parser.dart';
import 'types.dart';

class EshuushuuSearchState extends Equatable {
  const EshuushuuSearchState({
    this.tagIdCache = const {},
  });

  final Map<String, List<int>> tagIdCache;

  @override
  List<Object?> get props => [tagIdCache];

  List<int>? getCachedIds(String key) => tagIdCache[key];

  EshuushuuSearchState setCachedIds(String key, List<int> ids) {
    return EshuushuuSearchState(
      tagIdCache: {...tagIdCache, key: ids},
    );
  }
}

class EshuushuuSearchNotifier
    extends FamilyNotifier<EshuushuuSearchState, BooruConfigAuth> {
  @override
  EshuushuuSearchState build(BooruConfigAuth arg) =>
      const EshuushuuSearchState();

  EShuushuuClient get _client => ref.read(eshuushuuClientProvider(arg));

  Future<List<EshuushuuPost>> searchByTags(
    List<String> tags, {
    required int page,
    int? limit,
  }) async {
    if (tags.isEmpty) {
      final dtos = await _client.getPosts(page: page);
      return _mapToPosts(dtos, page: page, tags: tags, limit: limit);
    }

    final tagIds = await _resolveTagIds(tags);
    if (tagIds.isEmpty) return [];

    final dtos = await _client.getPosts(tagIds: tagIds, page: page);
    return _mapToPosts(dtos, page: page, tags: tags, limit: limit);
  }

  Future<List<int>> _resolveTagIds(List<String> tags) async {
    final cacheKey = tags.join('+');
    final cached = state.getCachedIds(cacheKey);
    if (cached != null) return cached;

    final ids = await _client.resolveTagIds(tags);
    state = state.setCachedIds(cacheKey, ids);
    return ids;
  }

  List<EshuushuuPost> _mapToPosts(
    List<PostDto> dtos, {
    int? page,
    List<String>? tags,
    int? limit,
  }) {
    return dtos
        .map(
          (e) => postDtoToPost(
            e,
            PostMetadata(
              page: page,
              search: tags?.join(' '),
              limit: limit,
            ),
          ),
        )
        .toList();
  }
}

final eshuushuuPostSearchProvider =
    NotifierProviderFamily<
      EshuushuuSearchNotifier,
      EshuushuuSearchState,
      BooruConfigAuth
    >(EshuushuuSearchNotifier.new);
