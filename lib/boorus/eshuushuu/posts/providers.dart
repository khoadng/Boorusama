// Package imports:
import 'package:booru_clients/eshuushuu.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/posts/post/providers.dart';
import '../../../core/search/queries/providers.dart';
import '../../../core/search/selected_tags/tag.dart';
import '../../../core/settings/providers.dart';
import '../client_provider.dart';
import 'parser.dart';
import 'types.dart';

final eshuushuuPostRepoProvider =
    Provider.family<PostRepository, BooruConfigSearch>(
      (ref, config) {
        final client = ref.watch(eshuushuuClientProvider(config.auth));
        final tagComposer = ref.watch(defaultTagQueryComposerProvider(config));

        Future<PostResult<EshuushuuPost>> fetch(
          EshuushuuSearchRequest request,
          int page, {
          int? limit,
          PostFetchOptions? options,
        }) async {
          final posts = await client.search(
            request,
            page: page,
          );

          return posts
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
              .toList()
              .toResult();
        }

        return PostRepositoryBuilder(
          tagComposer: tagComposer,
          getSettings: () async => ref.read(imageListingSettingsProvider),
          fetchSingle: (id, {options}) {
            // e-shuushuu doesn't support fetching single post by ID
            return Future.value();
          },
          fetch: (tags, page, {limit, options}) {
            return fetch(
              EshuushuuSearchRequest(
                tags: tags.map((e) => '"$e"').join(' '),
              ),
              page,
              limit: limit,
              options: options,
            );
          },
          fetchFromController: (controller, page, {limit, options}) => fetch(
            _buildSearchRequest(controller),
            page,
            limit: limit,
            options: options,
          ),
        );
      },
    );

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
  final general = tagSet.tags.where((t) => t.category == TagType.tag.valueStr);
  return EshuushuuSearchRequest(
    tags: general.map(_wrapWithQuotes).join(' '),
    character: characters.map(_wrapWithQuotes).join(' '),
    artist: artists.map(_wrapWithQuotes).join(' '),
    source: sources.map(_wrapWithQuotes).join(' '),
  );
}

String _wrapWithQuotes(TagSearchItem tag) => '"${tag.originalTag}"';
