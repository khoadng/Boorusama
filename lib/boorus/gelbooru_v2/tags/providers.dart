// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/search/queries/query.dart';
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/tag/tag.dart';
import '../../../foundation/riverpod/riverpod.dart';
import '../client_provider.dart';
import 'parser.dart';
import 'query_composer.dart';

final gelbooruV2TagsFromIdProvider = FutureProvider.autoDispose
    .family<List<Tag>, (BooruConfigAuth, int)>(
      (ref, params) async {
        ref.cacheFor(const Duration(minutes: 5));

        final (config, id) = params;
        final client = ref.watch(gelbooruV2ClientProvider(config));

        final data = await client.getTagsFromPostId(postId: id);

        return data.map(mapGelbooruV2TagDtoToTag).toList();
      },
    );

final gelbooruV2TagQueryComposerProvider =
    Provider.family<TagQueryComposer, BooruConfigSearch>(
      (ref, config) => GelbooruV2TagQueryComposer(config: config),
    );

final gelbooruV2TagExtractorProvider =
    Provider.family<TagExtractor, BooruConfigAuth>(
      (ref, config) {
        return TagExtractorBuilder(
          sorter: TagSorter.defaults(),
          fetcher: (post, options) async {
            final tags = await ref.read(
              gelbooruV2TagsFromIdProvider((config, post.id)).future,
            );

            return tags;
          },
        );
      },
    );

final gelbooruV2AutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>((ref, config) {
      final client = ref.watch(gelbooruV2ClientProvider(config));

      return AutocompleteRepositoryBuilder(
        autocomplete: (query) async {
          final dtos = await client.autocomplete(term: query.text, limit: 20);

          return dtos
              .map(mapGelbooruV2AutocompleteDtoToData)
              .where((e) => e != AutocompleteData.empty)
              .toList();
        },
        persistentStorageKey:
            '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
      );
    });
